import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/core/database/database.dart';
import 'package:trip_planner/features/poi/repositories/poi_repository.dart';

void main() {
  late AppDatabase db;
  late PoiRepository poiRepository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    const mockUserId = 'test_mock_user_id';
    poiRepository = LocalPoiRepository(db, mockUserId);
  });

  tearDown(() async {
    await db.close();
  });

  group('Anitabi dedup by bangumi_id', () {
    test('second upsert with same bangumi_id returns same anime row', () async {
      final id1 = await db.upsertAnimeByBangumiId(
        bangumiId: '1424',
        name: 'K-On!', authorId: 'test_mock_user_id',
      );
      final id2 = await db.upsertAnimeByBangumiId(
        bangumiId: '1424',
        name: 'けいおん！', authorId: 'test_mock_user_id',
      );

      expect(id1, equals(id2));

      final all = await db.getAllAnimes();
      expect(all.length, 1, reason: 'should not create a second row');
      expect(all.first.name, 'K-On!',
          reason: 'first name wins; upsert is no-op when exists');
      expect(all.first.bangumiId, '1424');
    });

    test('different bangumi_ids create independent rows', () async {
      await db.upsertAnimeByBangumiId(bangumiId: '1424', name: 'K-On!', authorId: 'test_mock_user_id');
      await db.upsertAnimeByBangumiId(bangumiId: '17288', name: 'Hibike!', authorId: 'test_mock_user_id');

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
        name: 'Integration Test Anime', authorId: 'test_mock_user_id'
      );

      await db.insertRoi(RoisCompanion.insert(
      id: 'test-roi-1',
      name: 'Test ROI',
      createdAt: const Value(1),
      authorId: 'test_user', // ADDED: Mock user for testing
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
  });
}