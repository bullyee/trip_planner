import 'dart:io';
import 'package:trip_planner/features/poi/models/media_asset_model.dart';
import 'package:trip_planner/features/poi/models/reference_image_model.dart';
import 'package:trip_planner/features/poi/repositories/media_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/core/database/database.dart';
import 'package:trip_planner/features/calendar/models/time_chunk_model.dart';
import 'package:trip_planner/features/calendar/repositories/time_chunk_repository.dart';
import 'package:trip_planner/features/poi/repositories/poi_repository.dart';

void main() {
  late AppDatabase db;
  late PoiRepository poiRepository;
  late TimeChunkRepository timeChunkRepository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    const mockUserId = 'test_user_id';
    poiRepository = LocalPoiRepository(db, mockUserId);
    timeChunkRepository = LocalTimeChunkRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Anitabi dedup by bangumi_id', () {
    test('second upsert with same bangumi_id returns same anime row', () async {
      final id1 = await db.upsertAnimeByBangumiId(
        bangumiId: '1424',
        name: 'K-On!', authorId: 'test_user_id',
      );
      final id2 = await db.upsertAnimeByBangumiId(
        bangumiId: '1424',
        name: 'けいおん！', authorId: 'test_user_id',
      );

      expect(id1, equals(id2));

      final all = await db.getAllAnimes();
      expect(all.length, 1, reason: 'should not create a second row');
      expect(all.first.name, 'K-On!',
          reason: 'first name wins; upsert is no-op when exists');
      expect(all.first.bangumiId, '1424');
    });

    test('different bangumi_ids create independent rows', () async {
      await db.upsertAnimeByBangumiId(bangumiId: '1424', name: 'K-On!', authorId: 'test_user_id');
      await db.upsertAnimeByBangumiId(bangumiId: '17288', name: 'Hibike!', authorId: 'test_user_id');

      final all = await db.getAllAnimes();
      expect(all.length, 2);
      expect(all.map((a) => a.bangumiId).toSet(), {'1424', '17288'});
    });
  });

  group('Repository Integration Tests (Phase 0 Guardrails)', () {
    // Assuming repositories take AppDatabase as an injected dependency.
    // If your architecture uses Riverpod ProviderContainer for testing, 
    // adjust the instantiation accordingly.
    
    setUp(() {
    });

    test('watchPoisByAnime properly joins and returns mapped POI models', () async {
      // 1. Arrange: Seed the database with linked data
      final animeId = await db.upsertAnimeByBangumiId(
        bangumiId: '9999', 
        name: 'Integration Test Anime', authorId: 'test_user_id'
      );

      await db.insertRoi(RoisCompanion.insert(
      id: 'test-roi-1',
      name: 'Test ROI',
      createdAt: const Value(1),
      authorId: 'test_user_id', // ADDED: Mock user for testing
    ));

      // Fixed: Added the required 'authorId' field to comply with new schema
      await db.insertPoi(PoisCompanion.insert(
        id: 'test-poi-1',
        authorId: 'test_user_id',
        name: 'Target POI',
        lat: 35.0,
        lng: 135.0,
      ));

      // Fixed: Added the required 'authorId' field to comply with new schema
      await db.insertPoi(PoisCompanion.insert(
        id: 'test-poi-2',
        authorId: 'test_user_id',
        name: 'Unlinked POI',
        lat: 36.0,
        lng: 136.0,
      ));

      // Link only the first POI to the Anime
      await db.addAnimeToPoi('test-poi-1', animeId);

      // 2. Act: Call the repository method that is slated for refactoring
      // Note: Adjust the method name to match your actual AnimeRepository implementation
      final poiStream = poiRepository.watchPoisByAnime(animeId);
      final pois = await poiStream.first;

      // 3. Assert: Verify the repository layer correctly queries and maps the data
      expect(
        pois.length, 
        1, 
        reason: 'The repository should filter out unlinked POIs and return exactly 1 match'
      );
      expect(pois.first.id, 'test-poi-1');
      expect(pois.first.name, 'Target POI');
    });

    test('deletePoi cascades child ReferenceImages, MediaAssets, and TimeChunks without FK failure', () async {
      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-with-children',
        authorId: 'test_user_id',
        name: 'Shrine Spot',
        lat: 35.0,
        lng: 135.0,
      ));

      await db.insertReferenceImage(ReferenceImagesCompanion.insert(
        id: 'ref-1',
        poiId: 'poi-with-children',
        authorId: 'test_user_id',
        localPath: const Value('/tmp/ref.jpg'),
      ));

      await db.insertMediaAsset(MediaAssetsCompanion.insert(
        id: 'media-1',
        poiId: 'poi-with-children',
        authorId: 'test_user_id',
        type: 'user_photo',
        referenceImageId: const Value('ref-1'),
      ));

      await db.insertTimeChunk(TimeChunksCompanion.insert(
        id: 'chunk-1',
        poiId: 'poi-with-children',
        authorId: 'test_user_id',
      ));

      await poiRepository.deletePoi('poi-with-children');

      expect(await db.getAllPois(), isEmpty);
      expect(await db.getReferenceImagesByPoi('poi-with-children'), isEmpty);
      expect(await db.getMediaAssetsByPoi('poi-with-children'), isEmpty);
      expect(await db.getTimeChunksByPoi('poi-with-children'), isEmpty);
    });

    test('deletePoi cleans up physical local files from disk', () async {
      final tempDir = await Directory.systemTemp.createTemp('poi_test_');
      final coverFile = File('${tempDir.path}/cover.jpg')..writeAsStringSync('dummy cover');
      final refFile = File('${tempDir.path}/ref.jpg')..writeAsStringSync('dummy ref');
      final mediaFile = File('${tempDir.path}/photo.jpg')..writeAsStringSync('dummy photo');

      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-with-files',
        authorId: 'test_user_id',
        name: 'Shrine Spot With Files',
        lat: 35.0,
        lng: 135.0,
        localCoverImagePath: Value(coverFile.path),
      ));

      await db.insertReferenceImage(ReferenceImagesCompanion.insert(
        id: 'ref-file-1',
        poiId: 'poi-with-files',
        authorId: 'test_user_id',
        localPath: Value(refFile.path),
      ));

      await db.insertMediaAsset(MediaAssetsCompanion.insert(
        id: 'media-file-1',
        poiId: 'poi-with-files',
        authorId: 'test_user_id',
        type: 'user_photo',
        localPath: Value(mediaFile.path),
      ));

      expect(await coverFile.exists(), isTrue);
      expect(await refFile.exists(), isTrue);
      expect(await mediaFile.exists(), isTrue);

      await poiRepository.deletePoi('poi-with-files');

      expect(await db.getAllPois(), isEmpty);
      expect(await coverFile.exists(), isFalse, reason: 'Cover file must be deleted from disk');
      expect(await refFile.exists(), isFalse, reason: 'Reference image file must be deleted from disk');
      expect(await mediaFile.exists(), isFalse, reason: 'Media asset photo must be deleted from disk');

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('LocalMediaRepository deleteMediaAsset and deleteReferenceImage delete files from disk', () async {
      final mediaRepo = LocalMediaRepository(db);
      final tempDir = await Directory.systemTemp.createTemp('media_test_');
      final refFile = File('${tempDir.path}/ref2.jpg')..writeAsStringSync('dummy ref 2');
      final mediaFile = File('${tempDir.path}/photo2.jpg')..writeAsStringSync('dummy photo 2');

      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-media-test',
        authorId: 'test_user_id',
        name: 'Spot',
        lat: 35.0,
        lng: 135.0,
      ));

      await mediaRepo.addReferenceImage(ReferenceImageModel(
        id: 'ref-direct',
        poiId: 'poi-media-test',
        authorId: 'test_user_id',
        localPath: refFile.path,
        createdAt: 1000,
      ));

      await mediaRepo.addMediaAsset(MediaAssetModel(
        id: 'media-direct',
        poiId: 'poi-media-test',
        authorId: 'test_user_id',
        localPath: mediaFile.path,
        type: 'user_photo',
        createdAt: 1000,
      ));

      expect(await refFile.exists(), isTrue);
      expect(await mediaFile.exists(), isTrue);

      await mediaRepo.deleteReferenceImage('ref-direct');
      expect(await refFile.exists(), isFalse, reason: 'Reference image must be deleted from disk');

      await mediaRepo.deleteMediaAsset('media-direct');
      expect(await mediaFile.exists(), isFalse, reason: 'Media asset must be deleted from disk');

      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('updatePoi preserves localCoverImagePath, remoteCoverImageUrl, and sortOrder', () async {
      await db.insertRoi(RoisCompanion.insert(
        id: 'roi-kyoto',
        name: 'Kyoto',
        authorId: 'test_user_id',
      ));

      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-cover',
        authorId: 'test_user_id',
        name: 'Uji Bridge',
        lat: 34.89,
        lng: 135.80,
        localCoverImagePath: const Value('/local/uji.jpg'),
        remoteCoverImageUrl: const Value('https://example.com/uji.jpg'),
        sortOrder: const Value(2048),
      ));

      final fetched = await poiRepository.getPoiById('poi-cover');
      final assignedToRoi = fetched.copyWith(roiId: 'roi-kyoto');
      await poiRepository.updatePoi(assignedToRoi);

      final afterUpdate = await poiRepository.getPoiById('poi-cover');
      expect(afterUpdate.roiId, 'roi-kyoto');
      expect(afterUpdate.localCoverImagePath, '/local/uji.jpg');
      expect(afterUpdate.remoteCoverImageUrl, 'https://example.com/uji.jpg');
      expect(afterUpdate.sortOrder, 2048);
    });

    test('TimeChunkRepository updateTimeChunk and batchUpdateTimeChunks preserve transitDuration and hasEverSynced', () async {
      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-sync-chunk',
        authorId: 'test_user_id',
        name: 'Station',
        lat: 35.0,
        lng: 135.0,
      ));

      await db.insertTimeChunk(TimeChunksCompanion.insert(
        id: 'chunk-sync-1',
        poiId: 'poi-sync-chunk',
        authorId: 'test_user_id',
        date: const Value('2026-10-30'),
        startTime: const Value('09:00'),
        endTime: const Value('10:00'),
        status: const Value('scheduled'),
        sortOrder: const Value(1024),
        duration: const Value(60),
        transitDuration: const Value(25),
        isFixedTime: const Value(true),
        hasEverSynced: const Value(true),
        createdAt: const Value(123456789),
      ));

      final initial = (await timeChunkRepository.watchTimeChunksByDate('2026-10-30').first).single;
      expect(initial.hasEverSynced, isTrue);
      expect(initial.transitDuration, 25);

      // Complete status update via updateTimeChunk
      await timeChunkRepository.updateTimeChunk(initial.copyWith(status: 'completed'));
      final afterSingleUpdate = (await timeChunkRepository.watchTimeChunksByDate('2026-10-30').first).single;
      expect(afterSingleUpdate.status, 'completed');
      expect(afterSingleUpdate.transitDuration, 25);
      expect(afterSingleUpdate.hasEverSynced, isTrue);
      expect(afterSingleUpdate.createdAt, 123456789);
      expect(afterSingleUpdate.sortOrder, 1024);
      expect(afterSingleUpdate.isFixedTime, isTrue);

      // Batch update via batchUpdateTimeChunks
      await timeChunkRepository.batchUpdateTimeChunks([
        afterSingleUpdate.copyWith(startTime: '09:30', endTime: '10:30'),
      ]);
      final afterBatchUpdate = (await timeChunkRepository.watchTimeChunksByDate('2026-10-30').first).single;
      expect(afterBatchUpdate.startTime, '09:30');
      expect(afterBatchUpdate.transitDuration, 25);
      expect(afterBatchUpdate.hasEverSynced, isTrue);
      expect(afterBatchUpdate.createdAt, 123456789);
    });

    test('PoiRepository updatePoi marks syncStatus dirty and preserves hasEverSynced (#45)', () async {
      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-sync-test',
        authorId: 'test_user_id',
        name: 'Initial Name',
        lat: 35.0,
        lng: 135.0,
        hasEverSynced: const Value(true),
        syncStatus: const Value(0), // synced
      ));

      final poi = await poiRepository.getPoiById('poi-sync-test');
      expect(poi.hasEverSynced, isTrue);
      expect(poi.syncStatus, equals(0));

      await poiRepository.updatePoi(poi.copyWith(name: 'Updated Name'));

      final updated = await poiRepository.getPoiById('poi-sync-test');
      expect(updated.name, equals('Updated Name'));
      expect(updated.hasEverSynced, isTrue);
      expect(updated.syncStatus, equals(1)); // dirty
      expect(updated.lastModifiedAt, isNotNull);
    });
  });

  group('LocalTimeChunkRepository (#50)', () {
    test('updateTimeChunk persists transitDuration', () async {
      await db.insertPoi(PoisCompanion.insert(
        id: 'chunk-poi-1',
        authorId: 'test_user_id',
        name: 'Test POI',
        lat: 35.0,
        lng: 135.0,
      ));

      final repo = LocalTimeChunkRepository(db);
      final initialChunk = TimeChunkModel(
        id: 'test-chunk-1',
        poiId: 'chunk-poi-1',
        authorId: 'test_user_id',
        duration: 60,
        transitDuration: 15,
        status: 'scheduled',
        isFixedTime: false,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await repo.addTimeChunk(initialChunk);

      final updatedChunk = initialChunk.copyWith(
        transitDuration: 45,
        duration: 90,
      );
      await repo.updateTimeChunk(updatedChunk);

      final row = await (db.select(db.timeChunks)..where((t) => t.id.equals('test-chunk-1'))).getSingle();
      expect(row.transitDuration, 45, reason: 'updateTimeChunk must not drop transitDuration');
      expect(row.duration, 90);
    });

    test('getPoisByDate returns POIs ordered by time chunk startTime and sortOrder', () async {
      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-2',
        authorId: 'test-user',
        name: 'Afternoon Spot',
        lat: 35.0,
        lng: 135.0,
        sortOrder: const Value(2),
      ));
      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-1',
        authorId: 'test-user',
        name: 'Morning Spot',
        lat: 35.0,
        lng: 135.0,
        sortOrder: const Value(1),
      ));

      await db.insertTimeChunk(TimeChunksCompanion.insert(
        id: 'chunk-2',
        authorId: 'test-user',
        poiId: 'poi-2',
        date: const Value('2026-10-31'),
        startTime: const Value('14:00'),
      ));
      await db.insertTimeChunk(TimeChunksCompanion.insert(
        id: 'chunk-1',
        authorId: 'test-user',
        poiId: 'poi-1',
        date: const Value('2026-10-31'),
        startTime: const Value('09:00'),
      ));

      final pois = await db.getPoisByDate('2026-10-31');
      expect(pois.map((p) => p.id).toList(), ['poi-1', 'poi-2']);
    });
  });
}
