import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' show WriteBatch;
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/core/database/database.dart';
import 'package:trip_planner/core/database/tables.dart';
import 'package:trip_planner/features/calendar/repositories/time_chunk_repository.dart';
import 'package:trip_planner/features/poi/models/poi_model.dart';
import 'package:trip_planner/features/poi/repositories/poi_repository.dart';
import 'package:trip_planner/features/roi/repositories/roi_repository.dart';
import 'package:trip_planner/features/sync/services/firestore_sync_service.dart';
import 'package:trip_planner/features/sync/services/sync_engine_service.dart';

/// In-memory fake implementation of FirestoreSyncService for unit tests
class GatedFake extends FakeFirestoreSyncService {
  Completer<void>? gate;
  final waiting = Completer<void>();

  @override
  Future<void> commitBatch(WriteBatch batch) async {
    final g = gate;
    if (g != null) {
      if (!waiting.isCompleted) waiting.complete();
      await g.future;
    }
    return super.commitBatch(batch);
  }
}

class FakeFirestoreSyncService implements FirestoreSyncService {
  final Map<String, Map<String, dynamic>> trips = {};
  final Map<String, Map<String, Map<String, dynamic>>> tripPois = {};
  final Map<String, Map<String, Map<String, dynamic>>> tripChunks = {};
  final Map<String, String?> locks = {};

  final StreamController<List<Map<String, dynamic>>> _userTripsController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  void emitUserTrips(List<Map<String, dynamic>> data) {
    _userTripsController.add(data);
  }

  @override
  Future<bool> acquireLock(String roiId, String userId) async {
    final currentLock = locks[roiId];
    if (currentLock != null && currentLock != userId) {
      return false;
    }
    locks[roiId] = userId;
    return true;
  }

  @override
  Future<void> releaseLock(String roiId) async {
    locks.remove(roiId);
  }

  @override
  Future<int> fetchTripVersion(String roiId) async {
    return (trips[roiId]?['cloudVersion'] as int?) ?? 0;
  }

  @override
  Future<bool> tripExists(String roiId) async {
    return trips.containsKey(roiId);
  }

  @override
  WriteBatch createBatch() {
    return _FakeWriteBatch(this);
  }

  @override
  void buildBatchOperations(WriteBatch batch, dynamic chunk, String roiId) {
    final fakeBatch = batch as _FakeWriteBatch;
    if (chunk.isDeleted) {
      fakeBatch.addOp(() {
        tripChunks[roiId]?.remove(chunk.id);
      });
    } else {
      fakeBatch.addOp(() {
        tripChunks.putIfAbsent(roiId, () => {})[chunk.id] = {
          'id': chunk.id,
          'poiId': chunk.poiId,
          'date': chunk.date,
          'startTime': chunk.startTime,
          'endTime': chunk.endTime,
          'status': chunk.status,
          'sortOrder': chunk.sortOrder,
          'duration': chunk.duration,
          'transitDuration': chunk.transitDuration,
          'isFixedTime': chunk.isFixedTime,
          'authorId': chunk.authorId,
        };
      });
    }
  }

  @override
  void buildPoiBatchOperations(WriteBatch batch, dynamic poi, String roiId) {
    final fakeBatch = batch as _FakeWriteBatch;
    if (poi.isDeleted == true) {
      fakeBatch.addOp(() {
        tripPois[roiId]?.remove(poi.id);
      });
    } else {
      fakeBatch.addOp(() {
        tripPois.putIfAbsent(roiId, () => {})[poi.id] = {
          'id': poi.id,
          'roiId': roiId,
          'authorId': poi.authorId,
          'name': poi.name,
          'description': poi.description,
          'address': poi.address,
          'lat': poi.lat,
          'lng': poi.lng,
          'businessHours': poi.businessHours,
          'contactInfo': poi.contactInfo,
          'remoteCoverImageUrl': poi.remoteCoverImageUrl,
          'sortOrder': poi.sortOrder,
        };
      });
    }
  }

  @override
  Future<void> deletePoiFromTrip(String roiId, String poiId) async {
    tripPois[roiId]?.remove(poiId);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTripPois(String roiId) async {
    return tripPois[roiId]?.values.toList() ?? [];
  }

  @override
  void appendVersionBumpAndLockRelease(WriteBatch batch, String roiId, int newVersion) {
    final fakeBatch = batch as _FakeWriteBatch;
    fakeBatch.addOp(() {
      final trip = trips.putIfAbsent(roiId, () => {'id': roiId});
      trip['cloudVersion'] = newVersion;
      locks.remove(roiId);
    });
  }

  @override
  Future<void> commitBatch(WriteBatch batch) async {
    final fakeBatch = batch as _FakeWriteBatch;
    fakeBatch.execute();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTripData(String roiId) async {
    return tripChunks[roiId]?.values.toList() ?? [];
  }

  @override
  Future<void> initializeCloudTrip(String roiId, String userId, String tripName) async {
    trips[roiId] = {
      'id': roiId,
      'name': tripName,
      'authorId': userId,
      'members': [userId],
      'cloudVersion': 0,
    };
  }

  @override
  Stream<List<Map<String, dynamic>>> watchUserTrips(String userId) {
    return _userTripsController.stream;
  }

  @override
  Future<void> leaveOrDeleteCloudTrip(String roiId, String userId) async {
    final trip = trips[roiId];
    if (trip == null) return;
    final members = List<String>.from(trip['members'] as List? ?? []);
    members.remove(userId);
    if (members.isEmpty) {
      trips.remove(roiId);
      tripPois.remove(roiId);
      tripChunks.remove(roiId);
    } else {
      trip['members'] = members;
    }
  }

  @override
  Stream<Map<String, dynamic>?> watchTrip(String roiId) {
    return Stream.value(trips[roiId]);
  }
}

class _FakeWriteBatch implements WriteBatch {
  final FakeFirestoreSyncService service;
  final List<void Function()> operations = [];

  _FakeWriteBatch(this.service);

  void addOp(void Function() op) {
    operations.add(op);
  }

  void execute() {
    for (final op in operations) {
      op();
    }
  }

  @override
  Future<void> commit() async {
    execute();
  }

  @override
  void delete(dynamic document) {}

  @override
  void set<T>(dynamic document, T data, [dynamic options]) {}

  @override
  void update(dynamic document, Map<Object, Object?> data) {}
}

void main() {
  late AppDatabase db;
  late FakeFirestoreSyncService fakeFirestore;
  late SyncEngineService syncEngine;
  late PoiRepository poiRepo;
  late TimeChunkRepository chunkRepo;
  late RoiRepository roiRepo;
  const mockUser = 'test_user_alice';

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    fakeFirestore = FakeFirestoreSyncService();
    syncEngine = SyncEngineService(
      localDb: db,
      firestoreSync: fakeFirestore,
      currentUserId: mockUser,
    );
    poiRepo = LocalPoiRepository(db, mockUser);
    chunkRepo = LocalTimeChunkRepository(db);
    roiRepo = LocalRoiRepository(db, mockUser, firestoreSync: fakeFirestore);

    // Seed shared trip
    await db.insertRoi(RoisCompanion.insert(
      id: 'roi-1',
      name: 'Kyoto Trip',
      authorId: mockUser,
      isShared: const Value(true),
      cloudVersion: const Value(0),
    ));
    await fakeFirestore.initializeCloudTrip('roi-1', mockUser, 'Kyoto Trip');
  });

  tearDown(() async {
    syncEngine.stopSync();
    await db.close();
  });

  group('Issue #45: Two-way Sync Engine & Dirty Tracking', () {
    test('POI insert and update mark syncStatus as dirty and executePush clears it', () async {
      // 1. Add POI via repository
      await poiRepo.savePoiWithRelations(
        poi: PoiModel(
          id: 'poi-1',
          roiId: 'roi-1',
          authorId: mockUser,
          name: 'Kinkaku-ji',
          lat: 35.039,
          lng: 135.729,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
        animeIds: [],
        tagIds: [],
        isUpdate: false,
      );

      final inserted = await poiRepo.getPoiById('poi-1');
      expect(inserted.syncStatus, equals(SyncStatus.dirty.index), reason: 'Newly created POI must be marked dirty');
      expect(inserted.hasEverSynced, isFalse);

      // 2. Push to cloud
      await syncEngine.executePush('roi-1');

      final synced = await poiRepo.getPoiById('poi-1');
      expect(synced.syncStatus, equals(SyncStatus.synced.index), reason: 'Pushed POI must be marked synced');
      expect(synced.hasEverSynced, isTrue);
      expect(fakeFirestore.tripPois['roi-1']?['poi-1']?['name'], equals('Kinkaku-ji'));

      // 3. Edit POI after first sync
      await poiRepo.updatePoi(synced.copyWith(name: 'Golden Pavilion'));

      final edited = await poiRepo.getPoiById('poi-1');
      expect(edited.name, equals('Golden Pavilion'));
      expect(edited.syncStatus, equals(SyncStatus.dirty.index), reason: 'POI edits must re-mark dirty for re-sync');

      // 4. Re-push to cloud
      await syncEngine.executePush('roi-1');

      final reSynced = await poiRepo.getPoiById('poi-1');
      expect(reSynced.syncStatus, equals(SyncStatus.synced.index));
      expect(fakeFirestore.tripPois['roi-1']?['poi-1']?['name'], equals('Golden Pavilion'),
          reason: 'Remote Firestore must receive the updated name');
    });

    test('Synced POI delete marks soft-delete, pushes deletion to cloud, and cleans up locally', () async {
      await poiRepo.savePoiWithRelations(
        poi: PoiModel(
          id: 'poi-del',
          roiId: 'roi-1',
          authorId: mockUser,
          name: 'To Delete Spot',
          lat: 35.0,
          lng: 135.0,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
        animeIds: [],
        tagIds: [],
        isUpdate: false,
      );
      await syncEngine.executePush('roi-1');
      expect(fakeFirestore.tripPois['roi-1']?.containsKey('poi-del'), isTrue);

      // Delete the synced POI
      await poiRepo.deletePoi('poi-del');

      // POI should be soft-deleted in DB (hidden from active queries)
      final allActive = await poiRepo.getAllPois();
      expect(allActive.any((p) => p.id == 'poi-del'), isFalse);

      final rawPoi = await (db.select(db.pois)..where((p) => p.id.equals('poi-del'))).getSingle();
      expect(rawPoi.isDeleted, isTrue);
      expect(rawPoi.syncStatus, equals(SyncStatus.dirty.index));

      // Execute push
      await syncEngine.executePush('roi-1');

      // Remote doc must be deleted
      expect(fakeFirestore.tripPois['roi-1']?.containsKey('poi-del'), isFalse);

      // Local soft-delete row must be pruned
      final postCleanRow = await (db.select(db.pois)..where((p) => p.id.equals('poi-del'))).getSingleOrNull();
      expect(postCleanRow, isNull);
    });

    test('Downstream executePull imports remote POIs and TimeChunks into local DB', () async {
      // Simulate remote collaborator creating data in Firestore
      fakeFirestore.trips['roi-1']?['cloudVersion'] = 3;
      fakeFirestore.tripPois.putIfAbsent('roi-1', () => {})['remote-poi-1'] = {
        'id': 'remote-poi-1',
        'roiId': 'roi-1',
        'authorId': 'collaborator_bob',
        'name': 'Fushimi Inari',
        'lat': 34.967,
        'lng': 135.772,
        'remoteCoverImageUrl': 'https://example.com/inari.jpg',
        'sortOrder': 100,
      };
      fakeFirestore.tripChunks.putIfAbsent('roi-1', () => {})['remote-chunk-1'] = {
        'id': 'remote-chunk-1',
        'poiId': 'remote-poi-1',
        'date': '2026-11-01',
        'startTime': '10:00',
        'endTime': '12:00',
        'status': 'scheduled',
        'duration': 120,
        'transitDuration': 15,
        'isFixedTime': true,
        'sortOrder': 0,
        'authorId': 'collaborator_bob',
      };

      await syncEngine.executePull('roi-1');

      // Verify local DB received remote POI
      final localPoi = await poiRepo.getPoiById('remote-poi-1');
      expect(localPoi.name, equals('Fushimi Inari'));
      expect(localPoi.remoteCoverImageUrl, equals('https://example.com/inari.jpg'));
      expect(localPoi.authorId, equals('collaborator_bob'));
      expect(localPoi.syncStatus, equals(SyncStatus.synced.index));
      expect(localPoi.hasEverSynced, isTrue);

      // Verify local DB received remote chunk
      final localChunks = await chunkRepo.watchTimeChunksByPoi('remote-poi-1').first;
      expect(localChunks.length, equals(1));
      expect(localChunks.first.id, equals('remote-chunk-1'));
      expect(localChunks.first.startTime, equals('10:00'));
      expect(localChunks.first.endTime, equals('12:00'));

      // Verify local cloudVersion matches remote
      final localRoi = await db.getRoiById('roi-1');
      expect(localRoi.cloudVersion, equals(3));
    });

    test('Downstream executePull handles remote chunk deletion (deletes clean, stashes dirty)', () async {
      // Setup a synced POI and two synced chunks
      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-shared',
        roiId: const Value('roi-1'),
        authorId: mockUser,
        name: 'Shared Spot',
        lat: 35.0,
        lng: 135.0,
        hasEverSynced: const Value(true),
        syncStatus: Value(SyncStatus.synced.index),
      ));

      await db.insertTimeChunk(TimeChunksCompanion.insert(
        id: 'chunk-clean',
        poiId: 'poi-shared',
        authorId: mockUser,
        hasEverSynced: const Value(true),
        syncStatus: Value(SyncStatus.synced.index),
        status: const Value('scheduled'),
      ));

      await db.insertTimeChunk(TimeChunksCompanion.insert(
        id: 'chunk-dirty',
        poiId: 'poi-shared',
        authorId: mockUser,
        hasEverSynced: const Value(true),
        syncStatus: Value(SyncStatus.dirty.index),
        status: const Value('scheduled'),
      ));

      // Remote collaborator deletes both chunks and bumps version
      fakeFirestore.trips['roi-1']?['cloudVersion'] = 5;
      fakeFirestore.tripPois.putIfAbsent('roi-1', () => {})['poi-shared'] = {
        'id': 'poi-shared',
        'roiId': 'roi-1',
        'authorId': mockUser,
        'name': 'Shared Spot',
        'lat': 35.0,
        'lng': 135.0,
      };
      fakeFirestore.tripChunks['roi-1'] = {}; // empty — remote deleted both chunks

      await syncEngine.executePull('roi-1');

      // Clean chunk should be deleted locally
      final cleanCheck = await (db.select(db.timeChunks)..where((t) => t.id.equals('chunk-clean'))).getSingleOrNull();
      expect(cleanCheck, isNull, reason: 'Clean chunk deleted on remote must be deleted locally');

      // Dirty chunk should be safely stashed so local effort is preserved
      final dirtyCheck = await (db.select(db.timeChunks)..where((t) => t.id.equals('chunk-dirty'))).getSingleOrNull();
      expect(dirtyCheck, isNull);

      final stashed = await (db.select(db.timeChunks)..where((t) => t.syncStatus.equals(SyncStatus.stashed.index))).getSingleOrNull();
      expect(stashed, isNotNull, reason: 'Locally dirty chunk deleted on remote must be stashed to backlog');
      expect(stashed!.status, equals('backlog'));
    });

    test('executePush automatically pulls downstream when local is behind remote before pushing', () async {
      // Local version is 0
      // Remote version bumped to 2 by someone else with a new spot
      fakeFirestore.trips['roi-1']?['cloudVersion'] = 2;
      fakeFirestore.tripPois.putIfAbsent('roi-1', () => {})['remote-spot'] = {
        'id': 'remote-spot',
        'roiId': 'roi-1',
        'authorId': 'bob',
        'name': 'Bob Spot',
        'lat': 35.1,
        'lng': 135.1,
      };

      // Local has a dirty new POI
      await poiRepo.savePoiWithRelations(
        poi: PoiModel(
          id: 'alice-spot',
          roiId: 'roi-1',
          authorId: mockUser,
          name: 'Alice Spot',
          lat: 35.2,
          lng: 135.2,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
        animeIds: [],
        tagIds: [],
        isUpdate: false,
      );

      // Execute push: should merge remote-spot first, then push alice-spot with version 3
      await syncEngine.executePush('roi-1');

      // Local DB now has both
      expect(await poiRepo.getPoiById('remote-spot'), isNotNull);
      expect(await poiRepo.getPoiById('alice-spot'), isNotNull);

      // Remote now has both and version is bumped to 3
      expect(fakeFirestore.tripPois['roi-1']?.containsKey('remote-spot'), isTrue);
      expect(fakeFirestore.tripPois['roi-1']?.containsKey('alice-spot'), isTrue);
      expect(fakeFirestore.trips['roi-1']?['cloudVersion'], equals(3));
    });

    test('enableCloudSyncForRoi arms full re-sync for all existing POIs and chunks', () async {
      // Create local unshared trip with POI and chunk
      await db.insertRoi(RoisCompanion.insert(
        id: 'roi-local',
        name: 'Local Only',
        authorId: mockUser,
        isShared: const Value(false),
      ));

      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-local-1',
        roiId: const Value('roi-local'),
        authorId: mockUser,
        name: 'Local Spot',
        lat: 35.0,
        lng: 135.0,
        syncStatus: Value(SyncStatus.synced.index),
      ));

      await db.insertTimeChunk(TimeChunksCompanion.insert(
        id: 'chunk-local-1',
        poiId: 'poi-local-1',
        authorId: mockUser,
        syncStatus: Value(SyncStatus.synced.index),
      ));

      // User toggles Cloud Sync
      await roiRepo.enableCloudSyncForRoi('roi-local');

      final roi = await db.getRoiById('roi-local');
      expect(roi.isShared, isTrue);

      final poi = await (db.select(db.pois)..where((p) => p.id.equals('poi-local-1'))).getSingle();
      expect(poi.syncStatus, equals(SyncStatus.dirty.index), reason: 'POI must be armed as dirty for cloud upload');

      final chunk = await (db.select(db.timeChunks)..where((t) => t.id.equals('chunk-local-1'))).getSingle();
      expect(chunk.syncStatus, equals(SyncStatus.dirty.index), reason: 'TimeChunk must be armed as dirty for cloud upload');
    });

    test('Deleting a synced POI with time chunk, photo, and reference image pushes cleanly without FK violation (#45 review 1)', () async {
      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-cascade-1',
        roiId: const Value('roi-1'),
        authorId: mockUser,
        name: 'Cascade Spot',
        lat: 35.0,
        lng: 135.0,
        syncStatus: Value(SyncStatus.synced.index),
        hasEverSynced: const Value(true),
      ));

      await db.insertTimeChunk(TimeChunksCompanion.insert(
        id: 'chunk-cascade-1',
        poiId: 'poi-cascade-1',
        authorId: mockUser,
        syncStatus: Value(SyncStatus.synced.index),
        hasEverSynced: const Value(true),
      ));

      await db.insertMediaAsset(MediaAssetsCompanion.insert(
        id: 'asset-cascade-1',
        poiId: 'poi-cascade-1',
        authorId: mockUser,
        type: 'user_photo',
        localPath: const Value('/tmp/photo.jpg'),
      ));

      await db.insertReferenceImage(ReferenceImagesCompanion.insert(
        id: 'ref-cascade-1',
        poiId: 'poi-cascade-1',
        authorId: mockUser,
        localPath: const Value('/tmp/ref.jpg'),
      ));

      await syncEngine.executePush('roi-1');

      // Delete POI
      await poiRepo.deletePoi('poi-cascade-1');

      final deletedPoi = await (db.select(db.pois)..where((p) => p.id.equals('poi-cascade-1'))).getSingle();
      expect(deletedPoi.isDeleted, isTrue);
      expect(deletedPoi.syncStatus, equals(SyncStatus.dirty.index));

      // Push the deletion — must not throw FK constraint failed
      await expectLater(syncEngine.executePush('roi-1'), completes);

      // Verify POI, chunk, mediaAsset, and referenceImage are hard-deleted locally
      expect(await (db.select(db.pois)..where((p) => p.id.equals('poi-cascade-1'))).getSingleOrNull(), isNull);
      expect(await (db.select(db.timeChunks)..where((t) => t.id.equals('chunk-cascade-1'))).getSingleOrNull(), isNull);
      expect(await (db.select(db.mediaAssets)..where((m) => m.poiId.equals('poi-cascade-1'))).get(), isEmpty);
      expect(await (db.select(db.referenceImages)..where((r) => r.poiId.equals('poi-cascade-1'))).get(), isEmpty);

      // Verify cloud doc was removed
      expect(fakeFirestore.tripPois['roi-1']?['poi-cascade-1'], isNull);
    });

    test('Peer pulling remote POI delete hard-deletes locally without leaving dirty soft-delete (#45 review 2)', () async {
      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-peer-1',
        roiId: const Value('roi-1'),
        authorId: mockUser,
        name: 'Peer Spot',
        lat: 35.0,
        lng: 135.0,
        syncStatus: Value(SyncStatus.synced.index),
        hasEverSynced: const Value(true),
      ));

      await db.insertTimeChunk(TimeChunksCompanion.insert(
        id: 'chunk-peer-1',
        poiId: 'poi-peer-1',
        authorId: mockUser,
        syncStatus: Value(SyncStatus.synced.index),
        hasEverSynced: const Value(true),
      ));

      fakeFirestore.trips['roi-1'] = {
        'id': 'roi-1',
        'cloudVersion': 2,
        'members': [mockUser],
      };
      fakeFirestore.tripPois['roi-1'] = {};
      fakeFirestore.tripChunks['roi-1'] = {};

      await syncEngine.executePull('roi-1');

      final localPoi = await (db.select(db.pois)..where((p) => p.id.equals('poi-peer-1'))).getSingleOrNull();
      expect(localPoi, isNull, reason: 'Remote delete must hard-delete clean local POI');

      final localChunk = await (db.select(db.timeChunks)..where((t) => t.id.equals('chunk-peer-1'))).getSingleOrNull();
      expect(localChunk, isNull, reason: 'Remote delete must hard-delete clean local chunk');

      await expectLater(syncEngine.executePush('roi-1'), completes);
    });

    test('Deleting a shared trip removes user from cloud members and does not resurrect (#45 review 5)', () async {
      fakeFirestore.trips['roi-1'] = {
        'id': 'roi-1',
        'name': 'Kyoto Trip',
        'members': [mockUser, 'bob'],
        'cloudVersion': 1,
      };

      await roiRepo.deleteRoi('roi-1');

      final localRoi = await (db.select(db.rois)..where((r) => r.id.equals('roi-1'))).getSingleOrNull();
      expect(localRoi, isNull);

      expect(fakeFirestore.trips['roi-1']?['members'], equals(['bob']));

      fakeFirestore.emitUserTrips([
        {'id': 'roi-1', 'name': 'Kyoto Trip', 'members': ['bob'], 'cloudVersion': 2}
      ]);
      await Future.delayed(const Duration(milliseconds: 50));

      final checkAgain = await (db.select(db.rois)..where((r) => r.id.equals('roi-1'))).getSingleOrNull();
      expect(checkAgain, isNull);
    });

    test('In-flight guard prevents concurrent push/pull overlap on same trip (#45 review 6)', () async {
      final pushFuture = syncEngine.executePush('roi-1');
      final pullFuture = syncEngine.executePull('roi-1');

      await Future.wait([pushFuture, pullFuture]);
      final roi = await db.getRoiById('roi-1');
      expect(roi.isShared, isTrue);
    });

    test('Debounce handles multiple trips without dropping earlier trips (#45 review 3)', () async {
      await db.insertRoi(RoisCompanion.insert(
        id: 'roi-2',
        name: 'Tokyo Trip',
        authorId: mockUser,
        isShared: const Value(true),
      ));

      syncEngine.startSync();

      // 1. Insert dirty chunk in roi-1
      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-trip1',
        roiId: const Value('roi-1'),
        authorId: mockUser,
        name: 'Spot Trip 1',
        lat: 35.0,
        lng: 135.0,
      ));
      await db.insertTimeChunk(TimeChunksCompanion.insert(
        id: 'chunk-trip1',
        poiId: 'poi-trip1',
        authorId: mockUser,
        syncStatus: Value(SyncStatus.dirty.index),
      ));

      // 2. Shortly after (within debounce window), insert dirty POI in roi-2
      await Future.delayed(const Duration(milliseconds: 300));
      await db.insertPoi(PoisCompanion.insert(
        id: 'poi-trip2',
        roiId: const Value('roi-2'),
        authorId: mockUser,
        name: 'Spot Trip 2',
        lat: 35.0,
        lng: 135.0,
        syncStatus: Value(SyncStatus.dirty.index),
      ));

      // 3. Wait for debounce timer (2s) to fire and execute both pushes
      await Future.delayed(const Duration(milliseconds: 2500));

      expect(fakeFirestore.tripChunks['roi-1']?.containsKey('chunk-trip1'), isTrue,
          reason: 'roi-1 chunk must be pushed');
      expect(fakeFirestore.tripPois['roi-2']?.containsKey('poi-trip2'), isTrue,
          reason: 'roi-2 POI must be pushed');

      syncEngine.stopSync();
    });
  });

  group('Round 2 Review Tests (E, F, and Session Tombstone)', () {
    late AppDatabase db;
    late GatedFake fake;
    late SyncEngineService engine;
    late PoiRepository poiRepo;
    const user = 'alice';

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      fake = GatedFake();
      engine = SyncEngineService(localDb: db, firestoreSync: fake, currentUserId: user);
      poiRepo = LocalPoiRepository(db, user, fake);
      for (final id in ['roi-1', 'roi-2']) {
        await db.insertRoi(RoisCompanion.insert(
            id: id, name: id, authorId: user, isShared: const Value(true)));
        await fake.initializeCloudTrip(id, user, id);
      }
    });

    tearDown(() async {
      engine.stopSync();
      await db.close();
    });

    PoiModel createPoi(String id, String roiId, String name) => PoiModel(
        id: id, roiId: roiId, authorId: user, name: name, lat: 35, lng: 135, createdAt: 0);

    Future<void> save(PoiModel p, {required bool update}) => poiRepo.savePoiWithRelations(
        poi: p, animeIds: [], tagIds: [], isUpdate: update);

    test('E: an edit made while a push is committing still reaches the cloud', () async {
      await save(createPoi('p1', 'roi-1', 'v1'), update: false);
      await engine.executePush('roi-1');
      await save(createPoi('p1', 'roi-1', 'v2'), update: true);

      fake.gate = Completer<void>();
      final push = engine.executePush('roi-1'); // reads v2, then waits in commit
      await fake.waiting.future;
      await save(createPoi('p1', 'roi-1', 'v3'), update: true); // edited during the commit
      fake.gate!.complete();
      await push;

      final local = await db.getPoiById('p1');
      final cloudName = fake.tripPois['roi-1']?['p1']?['name'];
      expect(
        cloudName == 'v3' || local.syncStatus == SyncStatus.dirty.index,
        isTrue,
        reason: 'cloud has "$cloudName" and the local v3 edit is marked '
            '${SyncStatus.values[local.syncStatus].name}, so v3 is never uploaded',
      );
    });

    test('F: a POI moved to another shared trip stays there after the old trip is pulled', () async {
      await save(createPoi('p2', 'roi-1', 'spot'), update: false);
      await engine.executePush('roi-1');
      await save(createPoi('p2', 'roi-2', 'spot'), update: true); // moved to roi-2
      await engine.executePush('roi-2');

      // A collaborator changes something else in roi-1, bumping its version.
      fake.trips['roi-1']!['cloudVersion'] = (fake.trips['roi-1']!['cloudVersion'] as int) + 1;
      await engine.executePull('roi-1');

      final local = await db.getPoiById('p2');
      expect(local.roiId, 'roi-2', reason: 'the pull of roi-1 moved the POI back');
      expect(fake.tripPois['roi-1']?.containsKey('p2') ?? false, isFalse,
          reason: "roi-1's cloud copy is never deleted, so collaborators still see it there");
    });

    test('Tombstone: locally deleted trip is never resurrected by downstream pull', () async {
      engine.notifyRoiDeleted('roi-1');
      
      // Attempting to pull roi-1 should be a no-op
      await engine.executePull('roi-1');
      
      // Downstream snapshot with roi-1 is ignored
      fake.emitUserTrips([
        {'id': 'roi-1', 'name': 'roi-1', 'cloudVersion': 5, 'members': [user]},
      ]);
      await Future.delayed(const Duration(milliseconds: 50));

      final roi = await (db.select(db.rois)..where((r) => r.id.equals('roi-1'))).getSingleOrNull();
      // Even if roi row was deleted by deleteRoi, it should NOT be re-created or synced
      expect(roi?.cloudVersion != 5, isTrue);
    });
  });
}
