// lib/core/providers/sync_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/json_sync.dart';
import 'database_provider.dart';

/// Provides a fully configured JsonSync instance so the UI layer
/// doesn't need to know about the underlying AppDatabase.
final syncProvider = Provider<JsonSync>((ref) {
  final db = ref.read(databaseProvider);
  return JsonSync(db);
});