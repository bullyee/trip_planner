import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';

class JsonSync {
  final AppDatabase db;

  JsonSync(this.db);

  Future<String> exportToJson() async {
    final rois = await db.getAllRois();
    final animes = await db.getAllAnimes();
    final tags = await db.getAllTags();
    final allPois = await db.getAllPois();

    final poisList = <Map<String, dynamic>>[];
    for (final poi in allPois) {
      final chunks = await db.getTimeChunksByPoi(poi.id);
      final media = await db.getMediaAssetsByPoi(poi.id);
      final poiAnimes = await db.watchAnimesForPoi(poi.id).first;
      final poiTags = await db.watchTagsForPoi(poi.id).first;

      poisList.add({
        'id': poi.id,
        'roi_id': poi.roiId,
        'name': poi.name,
        'description': poi.description,
        'address': poi.address,
        'lat': poi.lat,
        'lng': poi.lng,
        'business_hours': poi.businessHours,
        'contact_info': poi.contactInfo,
        'cover_image_uri': poi.coverImageUri,
        'anime_ids': poiAnimes.map((a) => a.id).toList(),
        'tag_ids': poiTags.map((t) => t.id).toList(),
        'time_chunks': chunks
            .map((c) => {
                  'id': c.id,
                  'date': c.date,
                  'start_time': c.startTime,
                  'end_time': c.endTime,
                  'status': c.status,
                })
            .toList(),
        'media_assets': media
            .map((m) => {
                  'id': m.id,
                  'type': m.type,
                  'local_uri': m.localUri,
                  'remote_url': m.remoteUrl,
                  'metadata': m.metadata,
                })
            .toList(),
      });
    }

    final payload = {
      'export_version': '2.0',
      'exported_at': DateTime.now().toIso8601String(),
      'rois': rois
          .map((roi) => {
                'id': roi.id,
                'name': roi.name,
                'description': roi.description,
                'is_offline_cached': roi.isOfflineCached,
                'created_at': roi.createdAt,
              })
          .toList(),
      'animes': animes
          .map((a) => {
                'id': a.id,
                'name': a.name,
                'description': a.description,
                'bangumi_id': a.bangumiId,
                'created_at': a.createdAt,
              })
          .toList(),
      'tags': tags
          .map((t) => {
                'id': t.id,
                'name': t.name,
                'description': t.description,
                'created_at': t.createdAt,
              })
          .toList(),
      'pois': poisList,
    };

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<void> importFromJson(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final version = data['export_version'] as String? ?? '1.0';

    if (version == '1.0') {
      await _importV1(data);
    } else {
      await _importV2(data);
    }
  }

  Future<void> _importV2(Map<String, dynamic> data) async {
    // Order matters: parents (rois, animes, tags) before children (pois, junctions).
    final rois = (data['rois'] as List<dynamic>?) ?? const [];
    final animes = (data['animes'] as List<dynamic>?) ?? const [];
    final tags = (data['tags'] as List<dynamic>?) ?? const [];
    final pois = (data['pois'] as List<dynamic>?) ?? const [];

    for (final r in rois) {
      final m = r as Map<String, dynamic>;
      await db.into(db.rois).insertOnConflictUpdate(RoisCompanion.insert(
            id: m['id'] as String,
            name: m['name'] as String,
            description: Value(m['description'] as String?),
            isOfflineCached: Value(m['is_offline_cached'] as int? ?? 0),
            createdAt: Value(m['created_at'] as int? ??
                DateTime.now().millisecondsSinceEpoch),
          ));
    }

    for (final a in animes) {
      final m = a as Map<String, dynamic>;
      await db.into(db.animes).insertOnConflictUpdate(AnimesCompanion.insert(
            id: m['id'] as String,
            name: m['name'] as String,
            description: Value(m['description'] as String?),
            bangumiId: Value(m['bangumi_id'] as String?),
            createdAt: Value(m['created_at'] as int? ??
                DateTime.now().millisecondsSinceEpoch),
          ));
    }

    for (final t in tags) {
      final m = t as Map<String, dynamic>;
      await db.into(db.tags).insertOnConflictUpdate(TagsCompanion.insert(
            id: m['id'] as String,
            name: m['name'] as String,
            description: Value(m['description'] as String?),
            createdAt: Value(m['created_at'] as int? ??
                DateTime.now().millisecondsSinceEpoch),
          ));
    }

    for (final p in pois) {
      final m = p as Map<String, dynamic>;
      final poiId = m['id'] as String;

      await db.into(db.pois).insertOnConflictUpdate(PoisCompanion.insert(
            id: poiId,
            name: m['name'] as String,
            lat: m['lat'] as double,
            lng: m['lng'] as double,
            roiId: Value(m['roi_id'] as String?),
            description: Value(m['description'] as String?),
            address: Value(m['address'] as String?),
            businessHours: Value(m['business_hours'] as String?),
            contactInfo: Value(m['contact_info'] as String?),
            coverImageUri: Value(m['cover_image_uri'] as String?),
          ));

      final animeIds = (m['anime_ids'] as List<dynamic>?)?.cast<String>() ?? [];
      await db.setAnimesForPoi(poiId, animeIds);

      final tagIds = (m['tag_ids'] as List<dynamic>?)?.cast<String>() ?? [];
      await db.setTagsForPoi(poiId, tagIds);

      final chunks = (m['time_chunks'] as List<dynamic>?) ?? const [];
      for (final c in chunks) {
        final cm = c as Map<String, dynamic>;
        await db
            .into(db.timeChunks)
            .insertOnConflictUpdate(TimeChunksCompanion.insert(
              id: cm['id'] as String,
              poiId: poiId,
              date: Value(cm['date'] as String?),
              startTime: Value(cm['start_time'] as String?),
              endTime: Value(cm['end_time'] as String?),
              status: Value(cm['status'] as String? ?? 'backlog'),
            ));
      }

      final media = (m['media_assets'] as List<dynamic>?) ?? const [];
      for (final ma in media) {
        final mm = ma as Map<String, dynamic>;
        await db
            .into(db.mediaAssets)
            .insertOnConflictUpdate(MediaAssetsCompanion.insert(
              id: mm['id'] as String,
              poiId: poiId,
              type: mm['type'] as String,
              localUri: mm['local_uri'] as String,
              remoteUrl: Value(mm['remote_url'] as String?),
              metadata: Value(mm['metadata'] as String?),
            ));
      }
    }
  }

  /// Legacy import for export_version 1.0 — flat tags string, flat anime_series_ref.
  /// Reconstructs Animes/Tags rows by name and links via junctions.
  Future<void> _importV1(Map<String, dynamic> data) async {
    final rois = data['rois'] as List<dynamic>;
    final animeNameToId = <String, String>{};
    final tagNameToId = <String, String>{};

    for (final roiData in rois) {
      final roi = roiData as Map<String, dynamic>;
      await db.into(db.rois).insertOnConflictUpdate(RoisCompanion.insert(
            id: roi['id'] as String,
            name: roi['name'] as String,
            description: Value(roi['description'] as String?),
            isOfflineCached: Value(roi['is_offline_cached'] as int? ?? 0),
            createdAt: Value(roi['created_at'] as int? ??
                DateTime.now().millisecondsSinceEpoch),
          ));

      final pois = (roi['pois'] as List<dynamic>?) ?? const [];
      for (final poiData in pois) {
        final poi = poiData as Map<String, dynamic>;
        final poiId = poi['id'] as String;

        await db.into(db.pois).insertOnConflictUpdate(PoisCompanion.insert(
              id: poiId,
              name: poi['name'] as String,
              lat: poi['lat'] as double,
              lng: poi['lng'] as double,
              roiId: Value(roi['id'] as String),
              description: Value(poi['description'] as String?),
              address: Value(poi['address'] as String?),
              businessHours: Value(poi['business_hours'] as String?),
              contactInfo: Value(poi['contact_info'] as String?),
              coverImageUri: Value(poi['cover_image_uri'] as String?),
            ));

        // Backfill anime
        final animeName = (poi['anime_series_ref'] as String?)?.trim();
        if (animeName != null && animeName.isNotEmpty) {
          final animeId = await _ensureAnimeByName(animeName, animeNameToId);
          await db.addAnimeToPoi(poiId, animeId);
        }

        // Backfill tags
        final tagStr = (poi['tags'] as String?)?.trim();
        if (tagStr != null && tagStr.isNotEmpty) {
          for (final raw in tagStr.split(',')) {
            final tagName = raw.trim();
            if (tagName.isEmpty) continue;
            final tagId = await _ensureTagByName(tagName, tagNameToId);
            await db.addTagToPoi(poiId, tagId);
          }
        }

        final chunks = (poi['time_chunks'] as List<dynamic>?) ?? const [];
        for (final c in chunks) {
          final cm = c as Map<String, dynamic>;
          await db
              .into(db.timeChunks)
              .insertOnConflictUpdate(TimeChunksCompanion.insert(
                id: cm['id'] as String,
                poiId: poiId,
                date: Value(cm['date'] as String?),
                startTime: Value(cm['start_time'] as String?),
                endTime: Value(cm['end_time'] as String?),
                status: Value(cm['status'] as String? ?? 'backlog'),
              ));
        }

        final media = (poi['media_assets'] as List<dynamic>?) ?? const [];
        for (final ma in media) {
          final mm = ma as Map<String, dynamic>;
          await db
              .into(db.mediaAssets)
              .insertOnConflictUpdate(MediaAssetsCompanion.insert(
                id: mm['id'] as String,
                poiId: poiId,
                type: mm['type'] as String,
                localUri: mm['local_uri'] as String,
                remoteUrl: Value(mm['remote_url'] as String?),
                metadata: Value(mm['metadata'] as String?),
              ));
        }
      }
    }
  }

  Future<String> _ensureAnimeByName(
    String name,
    Map<String, String> cache,
  ) async {
    final cached = cache[name];
    if (cached != null) return cached;
    final id = _newUuid();
    cache[name] = id;
    await db.insertAnime(AnimesCompanion.insert(
      id: id,
      name: name,
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return id;
  }

  Future<String> _ensureTagByName(
    String name,
    Map<String, String> cache,
  ) async {
    final cached = cache[name];
    if (cached != null) return cached;
    final id = _newUuid();
    cache[name] = id;
    await db.insertTag(TagsCompanion.insert(
      id: id,
      name: name,
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
    return id;
  }
}

String _newUuid() => const Uuid().v4();
