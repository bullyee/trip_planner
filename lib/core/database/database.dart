import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'connection/connection.dart' as db_connection;
import 'tables.dart';

part 'database.g.dart';


@DriftDatabase(tables: [
  Rois,
  Pois,
  Animes,
  Tags,
  PoiAnimes,
  PoiTags,
  TimeChunks,
  MediaAssets,
  ReferenceImages,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(db_connection.openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(referenceImages);
          }
          if (from < 3) {
            await m.addColumn(mediaAssets, mediaAssets.referenceImageId);
          }
          if (from < 4) {
            await _migrateToEntityTables(m);
          }
          if (from < 5) {
            await _addCreatedAtColumns();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _migrateToEntityTables(Migrator m) async {
    // Step 1: create the four new tables.
    await m.createTable(animes);
    await m.createTable(tags);
    await m.createTable(poiAnimes);
    await m.createTable(poiTags);

    // Step 2: backfill from the legacy columns BEFORE they are dropped.
    final now = DateTime.now().millisecondsSinceEpoch;
    const uuid = Uuid();
    final animeNameToId = <String, String>{};
    final tagNameToId = <String, String>{};

    final legacyRows = await customSelect(
      'SELECT id, anime_series_ref, tags FROM pois',
    ).get();

    for (final row in legacyRows) {
      final poiId = row.read<String>('id');

      final animeName = row.readNullable<String>('anime_series_ref')?.trim();
      if (animeName != null && animeName.isNotEmpty) {
        var animeId = animeNameToId[animeName];
        if (animeId == null) {
          animeId = uuid.v4();
          animeNameToId[animeName] = animeId;
          await customStatement(
            'INSERT INTO animes (id, name, created_at) VALUES (?, ?, ?)',
            [animeId, animeName, now],
          );
        }
        await customStatement(
          'INSERT OR IGNORE INTO poi_animes (poi_id, anime_id) VALUES (?, ?)',
          [poiId, animeId],
        );
      }

      final tagStr = row.readNullable<String>('tags')?.trim();
      if (tagStr != null && tagStr.isNotEmpty) {
        for (final raw in tagStr.split(',')) {
          final tagName = raw.trim();
          if (tagName.isEmpty) continue;
          var tagId = tagNameToId[tagName];
          if (tagId == null) {
            tagId = uuid.v4();
            tagNameToId[tagName] = tagId;
            await customStatement(
              'INSERT INTO tags (id, name, created_at) VALUES (?, ?, ?)',
              [tagId, tagName, now],
            );
          }
          await customStatement(
            'INSERT OR IGNORE INTO poi_tags (poi_id, tag_id) VALUES (?, ?)',
            [poiId, tagId],
          );
        }
      }
    }

    // Step 3: drop legacy columns and relax roi_id to nullable.
    // ignore: experimental_member_use
    await m.alterTable(TableMigration(pois));
  }

  /// v4 -> v5: add the non-nullable `created_at` column to pois,
  /// reference_images and media_assets.
  ///
  /// These columns are declared with a Dart-side `clientDefault` only, so the
  /// generated DDL carries no SQL default. A plain `addColumn` would emit
  /// `ADD COLUMN created_at INTEGER NOT NULL`, which SQLite rejects on tables
  /// that already contain rows. We add each column with an explicit SQL default
  /// equal to the migration timestamp so existing rows are backfilled.
  Future<void> _addCreatedAtColumns() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final table in const ['pois', 'reference_images', 'media_assets']) {
      await customStatement(
        'ALTER TABLE $table ADD COLUMN created_at INTEGER NOT NULL DEFAULT $now',
      );
    }
  }

  // --- ROI Queries ---
  Future<List<Roi>> getAllRois() => select(rois).get();

  Stream<List<Roi>> watchAllRois() => select(rois).watch();

  Future<Roi> getRoiById(String id) =>
      (select(rois)..where((r) => r.id.equals(id))).getSingle();

  Stream<Roi?> watchRoiById(String id) =>
      (select(rois)..where((r) => r.id.equals(id))).watchSingleOrNull();

  Future<int> insertRoi(RoisCompanion roi) => into(rois).insert(roi);

  Future<bool> updateRoi(RoisCompanion roi) => update(rois).replace(roi);

  Future<int> deleteRoi(String id) =>
      (delete(rois)..where((r) => r.id.equals(id))).go();

  // --- POI Queries ---
  Future<List<Poi>> getPoisByRoi(String roiId) =>
      (select(pois)..where((p) => p.roiId.equals(roiId))).get();

  Future<List<Poi>> getPoisByDate(String date) {
    final query = select(pois).join([
      innerJoin(timeChunks, timeChunks.poiId.equalsExp(pois.id)),
    ])
      ..where(timeChunks.date.equals(date))
      ..groupBy([pois.id]);
    return query.map((row) => row.readTable(pois)).get();
  }

  Stream<List<Poi>> watchPoisByRoi(String roiId) =>
      (select(pois)..where((p) => p.roiId.equals(roiId))).watch();

  Stream<List<Poi>> watchPoisWithoutRoi() =>
      (select(pois)..where((p) => p.roiId.isNull())).watch();

  Future<Poi> getPoiById(String id) =>
      (select(pois)..where((p) => p.id.equals(id))).getSingle();

  Stream<Poi> watchPoiById(String id) =>
      (select(pois)..where((p) => p.id.equals(id))).watchSingle();

  Stream<List<Poi>> watchAllPois() => select(pois).watch();

  Future<int> insertPoi(PoisCompanion poi) => into(pois).insert(poi);

  Future<bool> updatePoi(PoisCompanion poi) => update(pois).replace(poi);

  Future<List<Poi>> getAllPois() => select(pois).get();

  Future<int> deletePoi(String id) =>
      (delete(pois)..where((p) => p.id.equals(id))).go();

  // --- Anime Queries ---
  Future<List<Anime>> getAllAnimes() => select(animes).get();

  Stream<List<Anime>> watchAllAnimes() =>
      (select(animes)..orderBy([(a) => OrderingTerm.asc(a.name)])).watch();

  Future<Anime?> getAnimeById(String id) =>
      (select(animes)..where((a) => a.id.equals(id))).getSingleOrNull();

  Stream<Anime?> watchAnimeById(String id) =>
      (select(animes)..where((a) => a.id.equals(id))).watchSingleOrNull();

  Future<Anime?> getAnimeByBangumiId(String bangumiId) =>
      (select(animes)..where((a) => a.bangumiId.equals(bangumiId)))
          .getSingleOrNull();

  Future<int> insertAnime(AnimesCompanion anime) =>
      into(animes).insert(anime);

  Future<bool> updateAnime(AnimesCompanion anime) async {
    final current = await getAnimeById(anime.id.value);
    if (current == null) return false;
    return update(animes).replace(
      Anime(
        id: anime.id.value,
        name: anime.name.present ? anime.name.value : current.name,
        description: anime.description.present
            ? anime.description.value
            : current.description,
        bangumiId: anime.bangumiId.present
            ? anime.bangumiId.value
            : current.bangumiId,
        createdAt:
            anime.createdAt.present ? anime.createdAt.value : current.createdAt,
        // ADDED: Preserve existing authorId and isShared during update if not provided
        authorId: anime.authorId.present ? anime.authorId.value : current.authorId,
        isShared: anime.isShared.present ? anime.isShared.value : current.isShared,
      ),
    );
  }

  Future<int> deleteAnime(String id) =>
      (delete(animes)..where((a) => a.id.equals(id))).go();

  /// Insert anime if bangumiId not present; otherwise return existing.
  /// Returns the anime id (existing or newly created).
  Future<String> upsertAnimeByBangumiId({
    required String bangumiId,
    required String name,
    required String authorId,
    String? description,
  }) async {
    final existing = await getAnimeByBangumiId(bangumiId);
    if (existing != null) return existing.id;
    final id = const Uuid().v4();
    await insertAnime(AnimesCompanion.insert(
      id: id,
      name: name,
      description: Value(description),
      bangumiId: Value(bangumiId),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
      // ADDED: Required by the updated schema for new insertions
      authorId: authorId,
    ));
    return id;
  }

  // --- Tag Queries ---
  Future<List<Tag>> getAllTags() => select(tags).get();

  Stream<List<Tag>> watchAllTags() =>
      (select(tags)..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();

  Future<Tag?> getTagById(String id) =>
      (select(tags)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Tag?> watchTagById(String id) =>
      (select(tags)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<int> insertTag(TagsCompanion tag) => into(tags).insert(tag);

  Future<bool> updateTag(TagsCompanion tag) async {
    final current = await getTagById(tag.id.value);
    if (current == null) return false;
    return update(tags).replace(
      Tag(
        id: tag.id.value,
        name: tag.name.present ? tag.name.value : current.name,
        description: tag.description.present
            ? tag.description.value
            : current.description,
        createdAt:
            tag.createdAt.present ? tag.createdAt.value : current.createdAt,
        // ADDED: Preserve existing authorId and isShared during update if not provided
        authorId: tag.authorId.present ? tag.authorId.value : current.authorId,
        isShared: tag.isShared.present ? tag.isShared.value : current.isShared,
      ),
    );
  }

  Future<int> deleteTag(String id) =>
      (delete(tags)..where((t) => t.id.equals(id))).go();

  // --- POI ↔ Anime junction ---
  Future<void> addAnimeToPoi(String poiId, String animeId) =>
      into(poiAnimes).insert(
        PoiAnimesCompanion.insert(poiId: poiId, animeId: animeId),
        mode: InsertMode.insertOrIgnore,
      );

  Future<int> removeAnimeFromPoi(String poiId, String animeId) =>
      (delete(poiAnimes)
            ..where((pa) =>
                pa.poiId.equals(poiId) & pa.animeId.equals(animeId)))
          .go();

  Future<void> setAnimesForPoi(String poiId, List<String> animeIds) async {
    await transaction(() async {
      await (delete(poiAnimes)..where((pa) => pa.poiId.equals(poiId))).go();
      for (final animeId in animeIds) {
        await into(poiAnimes).insert(
          PoiAnimesCompanion.insert(poiId: poiId, animeId: animeId),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Stream<List<Anime>> watchAnimesForPoi(String poiId) {
    final query = select(animes).join([
      innerJoin(poiAnimes, poiAnimes.animeId.equalsExp(animes.id)),
    ])
      ..where(poiAnimes.poiId.equals(poiId))
      ..orderBy([OrderingTerm.asc(animes.name)]);
    return query.watch().map(
          (rows) => rows.map((r) => r.readTable(animes)).toList(),
        );
  }

  Stream<List<Poi>> watchPoisByAnime(String animeId) {
    final query = select(pois).join([
      innerJoin(poiAnimes, poiAnimes.poiId.equalsExp(pois.id)),
    ])
      ..where(poiAnimes.animeId.equals(animeId))
      ..orderBy([OrderingTerm.asc(pois.name)]);
    return query.watch().map(
          (rows) => rows.map((r) => r.readTable(pois)).toList(),
        );
  }

  Stream<int> watchPoiCountForAnime(String animeId) {
    final count = poiAnimes.poiId.count();
    final query = selectOnly(poiAnimes)
      ..addColumns([count])
      ..where(poiAnimes.animeId.equals(animeId));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  // --- POI ↔ Tag junction ---
  Future<void> addTagToPoi(String poiId, String tagId) =>
      into(poiTags).insert(
        PoiTagsCompanion.insert(poiId: poiId, tagId: tagId),
        mode: InsertMode.insertOrIgnore,
      );

  Future<int> removeTagFromPoi(String poiId, String tagId) =>
      (delete(poiTags)
            ..where((pt) => pt.poiId.equals(poiId) & pt.tagId.equals(tagId)))
          .go();

  Future<void> setTagsForPoi(String poiId, List<String> tagIds) async {
    await transaction(() async {
      await (delete(poiTags)..where((pt) => pt.poiId.equals(poiId))).go();
      for (final tagId in tagIds) {
        await into(poiTags).insert(
          PoiTagsCompanion.insert(poiId: poiId, tagId: tagId),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Stream<List<Tag>> watchTagsForPoi(String poiId) {
    final query = select(tags).join([
      innerJoin(poiTags, poiTags.tagId.equalsExp(tags.id)),
    ])
      ..where(poiTags.poiId.equals(poiId))
      ..orderBy([OrderingTerm.asc(tags.name)]);
    return query.watch().map(
          (rows) => rows.map((r) => r.readTable(tags)).toList(),
        );
  }

  Stream<List<Poi>> watchPoisByTag(String tagId) {
    final query = select(pois).join([
      innerJoin(poiTags, poiTags.poiId.equalsExp(pois.id)),
    ])
      ..where(poiTags.tagId.equals(tagId))
      ..orderBy([OrderingTerm.asc(pois.name)]);
    return query.watch().map(
          (rows) => rows.map((r) => r.readTable(pois)).toList(),
        );
  }

  Stream<int> watchPoiCountForTag(String tagId) {
    final count = poiTags.poiId.count();
    final query = selectOnly(poiTags)
      ..addColumns([count])
      ..where(poiTags.tagId.equals(tagId));
    return query.watchSingle().map((row) => row.read(count) ?? 0);
  }

  // --- TimeChunk Queries ---
  Future<List<TimeChunk>> getTimeChunksByPoi(String poiId) =>
      (select(timeChunks)..where((t) => t.poiId.equals(poiId))).get();

  Stream<List<TimeChunk>> watchTimeChunksByDate(String date) =>
      (select(timeChunks)..where((t) => t.date.equals(date))).watch();

  Stream<List<TimeChunk>> watchBacklogChunks() => (select(timeChunks)
        ..where((t) => t.status.equals('backlog')))
      .watch();

  Future<int> insertTimeChunk(TimeChunksCompanion chunk) =>
      into(timeChunks).insert(chunk);

  Future<bool> updateTimeChunk(TimeChunksCompanion chunk) =>
      // CRITICAL FIX: Pass the companion directly to Drift.
      // Never manually unpack .value properties. Drift handles absent values automatically.
      update(timeChunks).replace(chunk);

  Stream<List<TimeChunk>> watchAllScheduledChunks() => (select(timeChunks)
        ..where((t) => t.status.equals('scheduled'))
        ..orderBy([(t) => OrderingTerm.asc(t.date)]))
      .watch();

  Future<int> deleteTimeChunk(String id) =>
      (delete(timeChunks)..where((t) => t.id.equals(id))).go();

  // --- MediaAsset Queries ---
  Future<List<MediaAsset>> getMediaAssetsByPoi(String poiId) =>
      (select(mediaAssets)..where((m) => m.poiId.equals(poiId))).get();

  Stream<List<MediaAsset>> watchMediaAssetsByPoi(String poiId) =>
      (select(mediaAssets)..where((m) => m.poiId.equals(poiId))).watch();

  Future<int> insertMediaAsset(MediaAssetsCompanion asset) =>
      into(mediaAssets).insert(asset);

  Future<int> updateMediaAssetLocalPath(String id, String? localPath) =>
      (update(mediaAssets)..where((m) => m.id.equals(id))).write(
        MediaAssetsCompanion(localPath: Value(localPath)),
      );

  Future<int> deleteMediaAsset(String id) =>
      (delete(mediaAssets)..where((m) => m.id.equals(id))).go();

  // --- ReferenceImage Queries ---
  Future<List<ReferenceImage>> getReferenceImagesByPoi(String poiId) =>
      (select(referenceImages)..where((r) => r.poiId.equals(poiId))).get();

  Stream<List<ReferenceImage>> watchReferenceImagesByPoi(String poiId) =>
      (select(referenceImages)..where((r) => r.poiId.equals(poiId))).watch();

  Future<int> insertReferenceImage(ReferenceImagesCompanion image) =>
      into(referenceImages).insert(image);

  Future<int> updateReferenceImageLocalPath(String id, String? localPath) =>
      (update(referenceImages)..where((r) => r.id.equals(id))).write(
        ReferenceImagesCompanion(localPath: Value(localPath)),
      );

  Future<int> deleteReferenceImage(String id) =>
      (delete(referenceImages)..where((r) => r.id.equals(id))).go();

  /// Watches all POIs that have not been synced to the cloud yet
  Stream<List<Poi>> watchUnsyncedPois() {
    return (select(pois)..where((tbl) => tbl.isShared.equals(false))).watch();
  }

  /// Marks a specific POI as successfully synced to the cloud
  Future<void> markPoiAsShared(String id) async {
    await (update(pois)..where((tbl) => tbl.id.equals(id))).write(
      const PoisCompanion(
        isShared: Value(true),
      ),
    );
  }
}
