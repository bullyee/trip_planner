// import 'package:riverpod_annotation/riverpod_annotation.dart';

// import '../services/sync/json_sync.dart';
// import 'database_provider.dart';

// part 'sync_provider.g.dart';

// /// Provides a fully configured JsonSync instance so the UI layer
// /// doesn't need to know about the underlying AppDatabase.
// @Riverpod(keepAlive: true)
// JsonSync sync(SyncRef ref) {
//   final db = ref.watch(databaseProvider);
//   return JsonSync(db);
// }