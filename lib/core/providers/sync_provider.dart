import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/sync/providers/firestore_sync_provider.dart';
import '../../features/sync/services/sync_engine_service.dart';
import 'database_provider.dart';

part 'sync_provider.g.dart';

@Riverpod(keepAlive: true)
SyncEngineService? syncEngine(SyncEngineRef ref) {
  // 1. Watch the authentication state. 
  // If the user logs out, this provider will rebuild, returning null and calling onDispose.
  final user = ref.watch(authStateChangesProvider).valueOrNull;

  // 2. Return null if no user is authenticated
  if (user == null) {
    return null;
  }

  // 3. Watch other required dependencies.
  // Note: Replace these with the actual names of your providers
  final localDatabase = ref.watch(databaseProvider);
  final firestoreSyncService = ref.watch(firestoreSyncServiceProvider);

  // 4. Instantiate the service with the required arguments
  final service = SyncEngineService(
    localDb: localDatabase,
    firestoreSync: firestoreSyncService,
    currentUserId: user.uid,
  );

  // 5. Start the engine immediately upon creation
  service.startSync();

  // 6. Stop the engine when the provider is destroyed (e.g., user logs out)
  ref.onDispose(() {
    service.stopSync();
  });

  return service;
}