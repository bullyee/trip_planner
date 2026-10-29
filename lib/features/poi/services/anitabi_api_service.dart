import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:trip_planner/core/database/database.dart';
import 'package:trip_planner/core/utils/image_storage.dart';

import 'anitabi_static_data.dart';


class AnitabiImportResult {
  final String animeId;
  final String animeName;
  final int poisImported;
  final int poisSkipped;

  /// Spots Anitabi lists without map coordinates. POIs require lat/lng, so
  /// these are left out of the import.
  final int poisWithoutCoordinates;

  /// Number of POIs whose cover image will be fetched in the background.
  /// Reflects the queue size when this result was returned — downloads
  /// happen asynchronously via [coverDownloadCompletion].
  final int coversPending;

  /// Completes once every queued cover download has either succeeded or
  /// failed. The Future's int is the number of covers that successfully
  /// landed on local storage; failures silently leave the original URL
  /// on the POI. Callers can ignore this if they're happy to let covers
  /// appear via Drift's reactive streams as each download finishes.
  final Future<void> coverDownloadCompletion;

  const AnitabiImportResult({
    required this.animeId,
    required this.animeName,
    required this.poisImported,
    required this.poisSkipped,
    required this.poisWithoutCoordinates,
    required this.coversPending,
    required this.coverDownloadCompletion,
  });
}

/// Thrown when Anitabi can't be reached (network error or repeated
/// timeouts), as distinct from a subject that simply has no POIs. Lets the
/// UI tell "check your connection" apart from "this anime has none".
class AnitabiUnavailableException implements Exception {
  final String message;

  /// True when Anitabi's Cloudflare front refused the request (HTTP 403 or
  /// 429): this network's IP is temporarily blocked, so "check your
  /// connection" would mislead and retrying right away prolongs the block.
  final bool blocked;

  const AnitabiUnavailableException({
    this.message = 'Anitabi is unreachable',
    this.blocked = false,
  });
  @override
  String toString() => 'AnitabiUnavailableException: $message';
}

/// Thrown when Anitabi lists spots for a subject but none of them carry map
/// coordinates, so nothing can become a POI.
class AnitabiNoCoordinatesException implements Exception {
  final int spotCount;
  const AnitabiNoCoordinatesException(this.spotCount);
  @override
  String toString() =>
      'AnitabiNoCoordinatesException: $spotCount spots without coordinates';
}

class AnitabiApiService {
  static const int _coverDownloadConcurrency = 5;

  /// Sent on every Anitabi request, cover downloads included. Anitabi's
  /// maintainers ask clients to identify themselves; anonymous library UAs
  /// look like scrapers to their Cloudflare rules.
  static const String userAgent =
      'trip_planner (+https://github.com/bullyee/trip_planner)';

  /// Fetch POIs for a bangumi subject from Anitabi, upsert the Anime row by
  /// bangumi_id (so re-import dedupes), insert each POI, link them via the
  /// PoiAnimes junction, then kick off cover-image downloads in the
  /// background. The returned result is yielded as soon as the database
  /// rows are in place — covers stream in afterwards and the POI screens
  /// pick them up via Drift's reactive watches.
  ///
  /// Spots come from Anitabi's static map data ([AnitabiStaticData]): the
  /// open API (api.anitabi.cn) no longer returns spot coordinates and caps
  /// the spot list, and it Cloudflare-blocks callers of undocumented paths
  /// (#57), so it isn't used at all.
  ///
  /// The optional [client] parameter exists so tests can inject a single
  /// shared `MockClient` that answers both the data and the later
  /// image-download calls; [cacheDir] likewise replaces the on-disk cache.
  static Future<AnitabiImportResult?> importBangumiSubject(
    AppDatabase db,
    String subjectId, {
    required String authorId,
    String? fallbackName,
    http.Client? client,
    Future<Directory> Function()? cacheDir,
  }) async {
    final httpClient = _UserAgentClient(client ?? http.Client());
    final ownsClient = client == null;
    var handedOff = false;

    try {
      final AnitabiStaticWork? work;
      try {
        work = await AnitabiStaticData(
          client: httpClient,
          cacheDir: cacheDir ?? _defaultCacheDir,
        ).work(subjectId);
      } on AnitabiStaticDataUnavailableException catch (e) {
        throw AnitabiUnavailableException(blocked: e.blocked);
      }
      if (work == null || work.spots.isEmpty) return null;

      // Parse before touching the database so a subject whose spots are all
      // unusable doesn't leave an empty Anime row behind.
      final parsed = <(PoisCompanion, Map<String, dynamic>)>[];
      int skipped = 0;
      int withoutCoordinates = 0;
      for (final raw in work.spots) {
        final geo = _parseGeo(raw['geo']);
        if (geo == null) {
          withoutCoordinates++;
          continue;
        }
        PoisCompanion? companion;
        try {
          companion = _parsePoi(raw, authorId, geo);
        } catch (e, st) {
          debugPrint('[AnitabiApiService] Parse Error: $e\n$st');
        }
        if (companion == null) {
          skipped++;
          continue;
        }
        parsed.add((companion, raw));
      }
      if (parsed.isEmpty) {
        if (withoutCoordinates > 0) {
          throw AnitabiNoCoordinatesException(withoutCoordinates);
        }
        return null;
      }

      // Anitabi's title is the Japanese name, which matches the POI data, so
      // it stays the source of truth. Without it, fall back to the name the
      // caller already has from Bangumi search (its original/Japanese
      // `name`, not the Chinese `name_cn`) before a placeholder.
      final animeName = _nonEmpty(work.title) ??
          _nonEmpty(fallbackName) ??
          'Bangumi $subjectId';
      final animeId = await db.upsertAnimeByBangumiId(
        bangumiId: subjectId,
        name: animeName,
        authorId: authorId,
      );

      int imported = 0;
      final pendingDownloads = <_PendingCover>[];

      await db.transaction(() async {
        for (final (companion, raw) in parsed) {
          try {
            final poiId = companion.id.value;
            final alreadyImported = await (db.select(db.pois)
                  ..where((t) => t.id.equals(poiId)))
                .getSingleOrNull();

            await db.into(db.pois).insert(
                  companion,
                  mode: InsertMode.insertOrIgnore,
                );

            await db.addAnimeToPoi(poiId, animeId);

            if (alreadyImported != null) {
              skipped++;
              continue;
            }
            imported++;

            final rawImage = (raw['image'] ?? '').toString();
            if (rawImage.isNotEmpty) {
              final url = rawImage.replaceAll('?plan=h160', '?plan=h360');
              pendingDownloads.add(_PendingCover(
                poiId: poiId,
                url: url,
                metadata: _referenceMetadata(raw),
              ));
            }
          } catch (e, st) {
            // CRITICAL FIX: Log the database exception instead of swallowing it silently
            debugPrint('[AnitabiApiService] Database Insert Error for POI ${companion.id.value}: $e\n$st');
            skipped++;
          }
        }
      });

      // Hand the client off to the background downloader; it closes the
      // client (when we own it) once every worker is done.
      final completion = _downloadCoversInBackground(
        db: db,
        pending: pendingDownloads,
        httpClient: httpClient,
        closeClientWhenDone: ownsClient,
        authorId: animeId,
      );
      handedOff = true;

      return AnitabiImportResult(
        animeId: animeId,
        animeName: animeName,
        poisImported: imported,
        poisSkipped: skipped,
        poisWithoutCoordinates: withoutCoordinates,
        coversPending: pendingDownloads.length,
        coverDownloadCompletion: completion,
      );
    } finally {
      if (ownsClient && !handedOff) httpClient.close();
    }
  }

  static Future<Directory> _defaultCacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'anitabi_static'));
    await dir.create(recursive: true);
    return dir;
  }

  /// Drains the cover queue with [_coverDownloadConcurrency] simultaneous
  /// workers. Each worker pulls the next pending download off the shared
  /// queue, fetches the bytes, writes them locally, and updates the POI
  /// row's `coverImageUri`. Per-item failures are swallowed so one bad
  /// CDN response cannot stop the rest of the queue.
  static Future<void> _downloadCoversInBackground({
    required AppDatabase db,
    required List<_PendingCover> pending,
    required http.Client httpClient,
    required bool closeClientWhenDone,
    required String authorId,
  }) async {


    final queue = Queue<_PendingCover>.from(pending);

    Future<void> worker(int workerId) async {
  while (queue.isNotEmpty) {
    // O(1) operation using dart:collection Queue
    final next = queue.removeFirst();

    try {
      final localPath = await downloadCoverImage(
            next.url,
            subdir: 'reference_images',
            client: httpClient,
          ) ??
          await _downloadFromImageMirror(next.url, httpClient);

      if (localPath != null) {
        // Fetch or assign the required user ID

        await db.insertReferenceImage(
          ReferenceImagesCompanion.insert(
            id: const Uuid().v4(),
            poiId: next.poiId,
            authorId: authorId, // CRITICAL: Required for the new model
            localPath: Value(localPath), // CRITICAL: Wrap in Value for nullable column
            remoteUrl: Value(next.url),
            metadata: Value(next.metadata),
            createdAt: Value(DateTime.now().millisecondsSinceEpoch), // CRITICAL: Missing timestamp
          ),
        );
      }
    } catch (e, st) {
      debugPrint('[Worker $workerId] Failed to process reference image for POI ${next.poiId}: $e');
      debugPrint(st.toString());
    }
  }
}

    try {
      await Future.wait(
        List.generate(_coverDownloadConcurrency, (i) => worker(i)),
      );
    } finally {
      if (closeClientWhenDone) httpClient.close();
    }
  }

  /// Anitabi's image mirror. The official image host sits behind the same
  /// Cloudflare block as the rest of Anitabi, so a refused cover is retried
  /// here; the reference image keeps the official URL either way.
  static const String _imageMirrorHost = 'img-tc.anitabi.cn';

  static Future<String?> _downloadFromImageMirror(
    String url,
    http.Client client,
  ) async {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host != 'image.anitabi.cn') return null;
    return downloadCoverImage(
      uri.replace(host: _imageMirrorHost).toString(),
      subdir: 'reference_images',
      client: client,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static (double, double)? _parseGeo(dynamic geo) {
    if (geo is! List || geo.length < 2) return null;
    final lat = _toDouble(geo[0]);
    final lng = _toDouble(geo[1]);
    if (lat == null || lng == null) return null;
    return (lat, lng);
  }

  static String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  static PoisCompanion? _parsePoi(
    Map<String, dynamic> json,
    String authorId,
    (double, double) geo,
  ) {
    final rawId = json['id'];
    if (rawId == null) return null;
    final id = rawId.toString();
    if (id.isEmpty) return null;

    final (lat, lng) = geo;

    // The original-language name (usually Japanese, matching the signs on
    // site); the Chinese translation only when there is none.
    final name = (json['name'] ?? json['cn'] ?? '').toString();
    if (name.isEmpty) return null;

    // "Ep 3 - 04:12", leaving out whatever the data doesn't have.
    final ep = _nonEmpty(json['ep']?.toString());
    final seconds = _toInt(json['s']);
    final timeString = seconds > 0
        ? '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}'
        : null;
    final scene = [if (ep != null) 'Ep $ep', ?timeString].join(' - ');

    final origin = (json['origin'] ?? 'Unknown').toString();
    final originUrl = (json['originURL'] ?? '').toString();
    final description = [
      if (scene.isNotEmpty) scene,
      ?_nonEmpty(json['mark']?.toString()),
      'Source: $origin\n$originUrl'.trim(),
    ].join('\n');

    return PoisCompanion(
      id: Value('anitabi:$id'),
      name: Value(name),
      lat: Value(lat),
      lng: Value(lng),
      localCoverImagePath: const Value(null),
      description: Value(description),
      address: const Value(null),
      businessHours: const Value(null),
      contactInfo: const Value(null),
      roiId: const Value(null),

      // ADDED: Required fields for the new synchronization schema
      authorId: Value(authorId),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      isShared: const Value(false),
    );
  }

  /// Pulls the Anitabi-side fields we want to carry along with the
  /// downloaded reference image: episode and timestamp let future screens
  /// sort or filter without re-fetching.
  static String _referenceMetadata(Map<String, dynamic> json) {
    return jsonEncode({
      'source': 'anitabi',
      // FIXED: Removed invalid syntax '?' before map access
      'ep': json['ep'],
      's': json['s'],
    });
  }
}

class _PendingCover {
  final String poiId;
  final String url;
  final String metadata;

  const _PendingCover({
    required this.poiId,
    required this.url,
    required this.metadata,
  });
}

/// Stamps every request with [AnitabiApiService.userAgent] — the data
/// downloads and the cover downloads that share the client.
class _UserAgentClient extends http.BaseClient {
  final http.Client _inner;

  _UserAgentClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['User-Agent'] = AnitabiApiService.userAgent;
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
