import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/core/database/database.dart';
import 'package:trip_planner/features/sync/services/firestore_sync_service.dart';
import 'package:trip_planner/features/sync/services/sync_engine_service.dart';

class MockFirestoreSyncService implements FirestoreSyncService {
  final int version;
  final List<Map<String, dynamic>> pois;
  final List<Map<String, dynamic>> chunks;

  MockFirestoreSyncService({
    required this.version,
    required this.pois,
    required this.chunks,
  });

  @override
  Future<int> fetchTripVersion(String roiId) async => version;

  @override
  Future<List<Map<String, dynamic>>> fetchTripData(String roiId) async => chunks;

  @override
  Future<List<Map<String, dynamic>>> fetchTripPois(String roiId) async => pois;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // Ensure foreign key constraints are strictly enforced
    await db.customStatement('PRAGMA foreign_keys = ON');
  });

  tearDown(() async {
    await db.close();
  });

  group('SyncEngine executePull foreign key ordering', () {
    test('executePull upserts cloud POIs before time chunks without FK constraint failure', () async {
      const roiId = 'test-roi-shared';
      const poiId = 'cloud-new-poi';
      const chunkId = 'cloud-new-chunk';

      // 1. Arrange local state: Shared ROI exists with local version 0
      await db.insertRoi(RoisCompanion.insert(
        id: roiId,
        name: 'Kyoto Pilgrimage',
        authorId: 'user-1',
        isShared: const Value(true),
        cloudVersion: const Value(0),
      ));

      // 2. Prepare incoming cloud payload:
      // A brand-new POI and a TimeChunk that points to this POI via foreign key
      final cloudPois = [
        {
          'id': poiId,
          'name': 'Fushimi Inari Shrine',
          'authorId': 'user-remote',
          'lat': 34.9671,
          'lng': 135.7727,
          'sortOrder': 0,
        }
      ];

      final cloudChunks = [
        {
          'id': chunkId,
          'poiId': poiId,
          'date': '2026-11-01',
          'startTime': '09:00',
          'endTime': '10:30',
          'status': 'scheduled',
          'sortOrder': 1024,
          'duration': 90,
          'transitDuration': 15,
          'isFixedTime': false,
          'authorId': 'user-remote',
        }
      ];

      final mockFirestore = MockFirestoreSyncService(
        version: 1,
        pois: cloudPois,
        chunks: cloudChunks,
      );

      final engine = SyncEngineService(
        localDb: db,
        firestoreSync: mockFirestore,
        currentUserId: 'user-1',
      );

      // 3. Act: Pull data from cloud.
      // If chunks were inserted before POIs, PRAGMA foreign_keys would throw SqliteException(787).
      await engine.executePull(roiId);

      // 4. Assert: Both POI and TimeChunk successfully inserted and local cloudVersion bumped
      final savedPoi = await (db.select(db.pois)..where((p) => p.id.equals(poiId))).getSingle();
      expect(savedPoi.name, 'Fushimi Inari Shrine');
      expect(savedPoi.isShared, isTrue);

      final savedChunk = await (db.select(db.timeChunks)..where((t) => t.id.equals(chunkId))).getSingle();
      expect(savedChunk.poiId, poiId);
      expect(savedChunk.startTime, '09:00');
      expect(savedChunk.duration, 90);

      final updatedRoi = await (db.select(db.rois)..where((r) => r.id.equals(roiId))).getSingle();
      expect(updatedRoi.cloudVersion, 1);
    });
  });
}

