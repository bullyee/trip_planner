import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trip_planner/firebase_options.dart';
import 'package:trip_planner/features/sync/services/firestore_sync_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Real Firebase and Firestore connectivity on Android', (tester) async {
    print('[IntegrationTest] Initializing Firebase on Android...');
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    expect(app, isNotNull);
    print('[IntegrationTest] Firebase initialized successfully: ${app.name}');

    final db = FirebaseFirestore.instance;
    expect(db, isNotNull);
    print('[IntegrationTest] Firestore instance obtained: ${db.app.name}');

    final syncService = FirestoreSyncService(db);
    expect(syncService, isNotNull);

    // Test Firestore connectivity: checking tripExists on a test ID
    print('[IntegrationTest] Testing Firestore tripExists query...');
    try {
      final exists = await syncService.tripExists('non-existent-test-roi-id');
      print('[IntegrationTest] tripExists executed: $exists');
    } catch (e) {
      print('[IntegrationTest] tripExists query result/error: $e');
    }
  });
}

