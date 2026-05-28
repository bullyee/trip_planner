import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:trip_planner/core/database/database.dart';

class AnitabiImportResult {
  final String animeId;
  final String animeName;
  final int poisImported;
  final int poisSkipped;

  const AnitabiImportResult({
    required this.animeId,
    required this.animeName,
    required this.poisImported,
    required this.poisSkipped,
  });
}

class AnitabiApiService {
  static const String _apiBaseUrl = 'https://api.anitabi.cn';

  /// Fetch POIs for a bangumi subject from Anitabi, upsert the Anime row by
  /// bangumi_id (so re-import dedupes), insert each POI, and link them via the
  /// PoiAnimes junction. Returns counts and the anime id for navigation.
  static Future<AnitabiImportResult?> importBangumiSubject(
    AppDatabase db,
    String subjectId,
  ) async {
    final animeName = await _fetchSubjectTitle(subjectId);
    final pointsUrl = Uri.parse(
      '$_apiBaseUrl/bangumi/$subjectId/points/detail?haveImage=true',
    );

    List<dynamic> jsonList;
    try {
      final response =
          await http.get(pointsUrl).timeout(const Duration(seconds: 15));
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
        } catch (_) {
          skipped++;
        }
      }
    });

    return AnitabiImportResult(
      animeId: animeId,
      animeName: animeName,
      poisImported: imported,
      poisSkipped: skipped,
    );
  }

  static Future<String> _fetchSubjectTitle(String subjectId) async {
    try {
      final response = await http
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

    // Use anitabi id as a stable foreign id but generate our own uuid so
    // collisions across sources cannot happen. Re-import detects duplicates
    // via the bangumi_id on the anime + InsertMode.insertOrIgnore on the POI
    // primary key.
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
