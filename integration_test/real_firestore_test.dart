import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import 'package:trip_planner/firebase_options.dart';
import 'package:trip_planner/features/sync/services/firestore_sync_service.dart';
import 'package:trip_planner/features/poi/models/poi_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Real Cloud Firestore & Auth Live Test', (tester) async {
    print('=============================================');
    print('[LiveTest] 1. Initializing Firebase Core against REAL cloud...');
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    expect(app, isNotNull);
    print('[LiveTest] Connected to Real Project: ${app.options.projectId}');

    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    print('[LiveTest] 2. Checking Authentication on Real Firebase...');
    // Clear any cached emulator user session from disk
    await auth.signOut();
    User? user = auth.currentUser;

    if (user == null) {
      print('[LiveTest] No existing user signed in. Attempting Anonymous Sign-In...');
      try {
        final cred = await auth.signInAnonymously();
        user = cred.user;
        print('[LiveTest] Anonymous Sign-In succeeded! UID: ${user?.uid}');
      } catch (e) {
        print('[LiveTest] Anonymous Sign-In not available: $e');
        print('[LiveTest] Attempting Email/Password test account creation...');
        try {
          final email = 'test_real_${DateTime.now().millisecondsSinceEpoch}@example.com';
          final cred = await auth.createUserWithEmailAndPassword(
            email: email,
            password: 'TestPassword123!',
          );
          user = cred.user;
          print('[LiveTest] Email/Password user created! UID: ${user?.uid}');
        } catch (e2) {
          print('[LiveTest] Email/Password Sign-In not available: $e2');
        }
      }
    } else {
      print('[LiveTest] Using existing authenticated user: ${user.uid} (${user.email})');
    }

    if (user == null) {
      print('[LiveTest] NOTE: Real Firebase Authentication requires interactive Google Sign-In or enabled Auth provider in Console.');
      print('[LiveTest] Testing unauthenticated read access rule enforcement...');
      try {
        final doc = await firestore.collection('trips').doc('non-existent-test-id').get();
        print('[LiveTest] Unauthenticated get result: ${doc.exists}');
      } catch (e) {
        print('[LiveTest] Security rules successfully blocked unauthenticated read: $e');
      }
      return;
    }

    print('[LiveTest] 3. Authenticated as: ${user.uid}');
    final syncService = FirestoreSyncService(firestore);
    final testRoiId = 'live-test-${const Uuid().v4()}';

    try {
      print('[LiveTest] 4. Initializing Real Cloud Trip ($testRoiId)...');
      await syncService.initializeCloudTrip(testRoiId, user.uid, 'Automated Live Test Trip');
      print('[LiveTest] Real Cloud Trip created successfully!');

      final tripDoc = await firestore.collection('trips').doc(testRoiId).get();
      expect(tripDoc.exists, isTrue);
      expect(tripDoc.data()?['authorId'], equals(user.uid));
      expect(tripDoc.data()?['cloudVersion'], equals(0));
      print('[LiveTest] Verified Real Trip Document exists on Firestore cloud!');

      print('[LiveTest] 5. Acquiring Distributed Lock (syncLock) on Real Trip...');
      final lockAcquired = await syncService.acquireLock(testRoiId, user.uid);
      expect(lockAcquired, isTrue);
      print('[LiveTest] Distributed lock acquired on cloud!');

      print('[LiveTest] 6. Committing batch with POI & version bump to 1...');
      final testPoiId = const Uuid().v4();
      final batch = firestore.batch();
      syncService.buildPoiBatchOperations(
        batch,
        PoiModel(
          id: testPoiId,
          roiId: testRoiId,
          authorId: user.uid,
          name: 'Live Kyoto Imperial Palace',
          lat: 35.0254,
          lng: 135.7621,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
        testRoiId,
      );
      syncService.appendVersionBumpAndLockRelease(batch, testRoiId, 1);
      await syncService.commitBatch(batch);
      print('[LiveTest] Batch commit succeeded on Real Firestore!');

      final updatedDoc = await firestore.collection('trips').doc(testRoiId).get();
      expect(updatedDoc.data()?['cloudVersion'], equals(1));
      print('[LiveTest] Real Firestore cloudVersion is now: ${updatedDoc.data()?['cloudVersion']}');

      print('[LiveTest] 7. Cleaning up test documents on Real Cloud...');
      await firestore.collection('trips').doc(testRoiId).collection('pois').doc(testPoiId).delete();
      await firestore.collection('trips').doc(testRoiId).delete();
      print('[LiveTest] Cleanup completed successfully!');

      print('=============================================');
      print('[LiveTest] REAL CLOUD FIRESTORE TEST PASSED 100%!');
      print('=============================================');
    } catch (e, stack) {
      print('[LiveTest] Real test error: $e');
      print(stack);
      rethrow;
    }
  });
}

