import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:trip_planner/core/database/database.dart';
import 'package:trip_planner/core/utils/image_storage.dart';

class AnitabiImportResult {
  final String animeId;
  final String animeName;
  final int poisImported;
  final int poisSkipped;
  final int coversDownloaded;

  const AnitabiImportResult({
    required this.animeId,
    required this.animeName,
    required this.poisImported,
    required this.poisSkipped,
    required this.coversDownloaded,
  });
}

class AnitabiApiService {
  static const String _apiBaseUrl = 'https://api.anitabi.cn';

  /// Fetch POIs for a bangumi subject from Anitabi, upsert the Anime row by
  /// bangumi_id (so re-import dedupes), insert each POI, link them via the
  /// PoiAnimes junction, then download each POI's cover image to local
  /// storage so the rest of the app (which renders `coverImageUri` via
  /// `Image.file`) keeps working offline.
  ///
  /// The optional [client] parameter exists so tests can inject a single
  /// shared `MockClient` that answers both the Anitabi API calls and the
  /// later image-download calls.
  static Future<AnitabiImportResult?> importBangumiSubject(
    AppDatabase db,
    String subjectId, {
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    final ownsClient = client == null;

    try {
      final animeName = await _fetchSubjectTitle(subjectId, httpClient);
      final pointsUrl = Uri.parse(
        '$_apiBaseUrl/bangumi/$subjectId/points/detail?haveImage=true',
      );

      List<dynamic> jsonList;
      try {
        final response = await httpClient
            .get(pointsUrl)
            .timeout(const Duration(seconds: 15));
        if (response.statusCode != 200) return null;
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body is! List) return null;
        jsonList = body;
      } catch (_) {
        return null;
      }

      if (jsonList.isEmpty) return null;

      final animeId = await db.upsertAnimeByBangumiId(
        bangumiId: subjectId,
        name: animeName,
      );

      int imported = 0;
      int skipped = 0;
      // Track (poiId, remote URL) pairs so we can download covers after the
      // transaction commits — keeping downloads outside the transaction
      // means an HTTP hiccup on one image cannot abort the entire insert.
      final pendingDownloads = <_PendingCover>[];

      await db.transaction(() async {
        for (final raw in jsonList) {
          if (raw is! Map<String, dynamic>) {
            skipped++;
            continue;
          }

          final companion = _parsePoi(raw);
          if (companion == null) {
            skipped++;
            continue;
          }

          try {
            await db.into(db.pois).insert(
                  companion,
                  mode: InsertMode.insertOrIgnore,
                );
            await db.addAnimeToPoi(companion.id.value, animeId);
            imported++;

            final url = companion.coverImageUri.value;
            if (url != null && url.isNotEmpty) {
              pendingDownloads.add(
                _PendingCover(poiId: companion.id.value, url: url),
              );
            }
          } catch (_) {
            skipped++;
          }
        }
      });

      int coversDownloaded = 0;
      for (final pending in pendingDownloads) {
        final localPath = await downloadCoverImage(
          pending.url,
          client: httpClient,
        );
        if (localPath == null) continue;
        await (db.update(db.pois)..where((p) => p.id.equals(pending.poiId)))
            .write(PoisCompanion(coverImageUri: Value(localPath)));
        coversDownloaded++;
      }

      return AnitabiImportResult(
        animeId: animeId,
        animeName: animeName,
        poisImported: imported,
        poisSkipped: skipped,
        coversDownloaded: coversDownloaded,
      );
    } finally {
      if (ownsClient) httpClient.close();
    }
  }

  static Future<String> _fetchSubjectTitle(
    String subjectId,
    http.Client httpClient,
  ) async {
    try {
      final response = await httpClient
          .get(Uri.parse('$_apiBaseUrl/bangumi/$subjectId'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body is Map<String, dynamic>) {
          final title = body['title'];
          if (title is String && title.isNotEmpty) return title;
        }
      }
    } catch (_) {
      // fall through to fallback
    }
    return 'Bangumi $subjectId';
  }

  static PoisCompanion? _parsePoi(Map<String, dynamic> json) {
    final rawId = json['id'];
    if (rawId == null) return null;
    final id = rawId.toString();
    if (id.isEmpty) return null;

    final geo = json['geo'];
    if (geo is! List || geo.length < 2) return null;
    final lat = (geo[0] as num?)?.toDouble();
    final lng = (geo[1] as num?)?.toDouble();
    if (lat == null || lng == null) return null;

    final name = (json['cn'] ?? json['name'] ?? '').toString();
    if (name.isEmpty) return null;

    var imageUrl = (json['image'] ?? '').toString();
    imageUrl = imageUrl.replaceAll('?plan=h160', '?plan=h360');

    final seconds = (json['s'] as num?)?.toInt() ?? 0;
    final timeString =
        '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

    final origin = (json['origin'] ?? 'Unknown').toString();
    final originUrl = (json['originURL'] ?? '').toString();
    final ep = json['ep'];
    final description =
        'Ep $ep - $timeString\nSource: $origin\n$originUrl'.trim();

    return PoisCompanion(
      id: Value(const Uuid().v4()),
      name: Value(name),
      lat: Value(lat),
      lng: Value(lng),
      coverImageUri: Value(imageUrl.isEmpty ? null : imageUrl),
      description: Value(description),
      address: const Value(null),
      businessHours: const Value(null),
      contactInfo: const Value(null),
      roiId: const Value(null),
    );
  }
}

class _PendingCover {
  final String poiId;
  final String url;

  const _PendingCover({required this.poiId, required this.url});
}
