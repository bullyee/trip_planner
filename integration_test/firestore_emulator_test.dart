// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import 'package:trip_planner/firebase_options.dart';
import 'package:trip_planner/core/database/database.dart';
import 'package:trip_planner/core/database/tables.dart';
import 'package:trip_planner/features/sync/services/firestore_sync_service.dart';
import 'package:trip_planner/features/sync/services/sync_engine_service.dart';
import 'package:trip_planner/features/poi/models/poi_model.dart';
import 'package:trip_planner/features/poi/repositories/poi_repository.dart';
import 'package:trip_planner/features/calendar/models/time_chunk_model.dart';
import 'package:trip_planner/features/calendar/repositories/time_chunk_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-End Local Firestore & Auth Emulator Sync across Mobile and Desktop', (tester) async {
    print('=============================================');
    print('[IntegrationTest] 1. Initializing Firebase Core...');
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    expect(app, isNotNull);

    print('[IntegrationTest] 2. Connecting to Local Emulators (127.0.0.1 via ADB reverse)...');
    final firestore = FirebaseFirestore.instance;
    firestore.useFirestoreEmulator('127.0.0.1', 8080);

    final auth = FirebaseAuth.instance;
    auth.useAuthEmulator('127.0.0.1', 9099);

    print('[IntegrationTest] 3. Authenticating with Auth Emulator...');
    final testEmail = 'android_tester_${DateTime.now().millisecondsSinceEpoch}@example.com';
    final userCredential = await auth.createUserWithEmailAndPassword(
      email: testEmail,
      password: 'testPassword123!',
    );
    final user = userCredential.user!;
    print('[IntegrationTest] Authenticated as UID: ${user.uid} (${user.email})');
    expect(user.uid, isNotEmpty);

    print('[IntegrationTest] 4. Setting up Drift DB & Repositories...');
    final localDb = AppDatabase.forTesting(NativeDatabase.memory());
    final firestoreSync = FirestoreSyncService(firestore);
    final syncEngine = SyncEngineService(
      localDb: localDb,
      firestoreSync: firestoreSync,
      currentUserId: user.uid,
    );
    final poiRepo = LocalPoiRepository(localDb, user.uid);
    final chunkRepo = LocalTimeChunkRepository(localDb);

    final roiId = const Uuid().v4();
    print('[IntegrationTest] 5. Creating Shared Trip (ROI ID: $roiId)...');

    // Create ROI locally
    await localDb.insertRoi(RoisCompanion.insert(
      id: roiId,
      name: 'Android Local Sync Pilgrimage',
      authorId: user.uid,
      isShared: const Value(true),
      cloudVersion: const Value(0),
    ));

    // Initialize root trip doc on Firestore Emulator
    await firestoreSync.initializeCloudTrip(
      roiId,
      user.uid,
      'Android Local Sync Pilgrimage',
    );
    print('[IntegrationTest] Root trip doc initialized on Firestore!');

    final tripDoc = await firestore.collection('trips').doc(roiId).get();
    expect(tripDoc.exists, isTrue);
    expect(tripDoc.data()?['authorId'], equals(user.uid));
    expect(tripDoc.data()?['cloudVersion'], equals(0));
    print('[IntegrationTest] Verified trip doc exists on Firestore with version 0.');

    print('[IntegrationTest] 6. Creating Dirty POI & TimeChunk locally via Repositories...');
    final poiId = const Uuid().v4();
    await poiRepo.savePoiWithRelations(
      poi: PoiModel(
        id: poiId,
        roiId: roiId,
        authorId: user.uid,
        name: 'Fushimi Inari Shrine',
        lat: 34.9671,
        lng: 135.7727,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
      animeIds: [],
      tagIds: [],
      isUpdate: false,
    );

    final chunkId = const Uuid().v4();
    await chunkRepo.addTimeChunk(TimeChunkModel(
      id: chunkId,
      poiId: poiId,
      authorId: user.uid,
      date: '2026-10-31',
      startTime: '09:00',
      endTime: '11:00',
      duration: 120,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      syncStatus: SyncStatus.dirty.index,
    ));

    print('[IntegrationTest] 7. Executing SyncEngine.executePush to Firestore Emulator...');
    await syncEngine.executePush(roiId);

    // Verify POI & Chunk reached Firestore Emulator
    final remotePoi = await firestore
        .collection('trips')
        .doc(roiId)
        .collection('pois')
        .doc(poiId)
        .get();
    expect(remotePoi.exists, isTrue);
    expect(remotePoi.data()?['name'], equals('Fushimi Inari Shrine'));
    print('[IntegrationTest] SUCCESS: Remote POI found on Firestore Emulator: ${remotePoi.data()?['name']}');

    final remoteChunk = await firestore
        .collection('trips')
        .doc(roiId)
        .collection('timeChunks')
        .doc(chunkId)
        .get();
    expect(remoteChunk.exists, isTrue);
    expect(remoteChunk.data()?['duration'], equals(120));
    print('[IntegrationTest] SUCCESS: Remote TimeChunk found on Firestore Emulator: ${remoteChunk.data()?['duration']} min');

    final updatedTrip = await firestore.collection('trips').doc(roiId).get();
    expect(updatedTrip.data()?['cloudVersion'], equals(1));
    print('[IntegrationTest] SUCCESS: Cloud version bumped to 1 in Firestore!');

    print('[IntegrationTest] 8. Simulating Remote Update (Desktop Collaborator writes to Firestore)...');
    final remotePoi2Id = const Uuid().v4();
    final lockAcquired = await firestoreSync.acquireLock(roiId, user.uid);
    expect(lockAcquired, isTrue);

    final batch = firestore.batch();
    firestoreSync.buildPoiBatchOperations(
      batch,
      PoiModel(
        id: remotePoi2Id,
        roiId: roiId,
        authorId: user.uid,
        name: 'Kiyomizu-dera Temple',
        lat: 34.9949,
        lng: 135.7850,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
      roiId,
    );
    firestoreSync.appendVersionBumpAndLockRelease(batch, roiId, 2);
    await firestoreSync.commitBatch(batch);
    print('[IntegrationTest] Remote Collaborator committed Kiyomizu-dera and bumped cloudVersion to 2 via batch.');

    print('[IntegrationTest] 9. Executing SyncEngine.executePull on Android Device...');
    await syncEngine.executePull(roiId);

    // Verify local DB received the new POI
    final localPois = await (localDb.select(localDb.pois)..where((p) => p.roiId.equals(roiId))).get();
    expect(localPois.length, equals(2));
    final importedPoi = localPois.firstWhere((p) => p.id == remotePoi2Id);
    expect(importedPoi.name, equals('Kiyomizu-dera Temple'));
    print('[IntegrationTest] SUCCESS: Local Drift DB pulled and imported: ${importedPoi.name}');

    print('[IntegrationTest] =============================================');
    print('[IntegrationTest] ALL 9 VERIFICATION STEPS PASSED PERFECTLY!');
    print('[IntegrationTest] =============================================');

    await localDb.close();
  });
}
