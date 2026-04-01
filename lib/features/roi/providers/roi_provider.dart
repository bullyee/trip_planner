import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';

final allRoisProvider = StreamProvider<List<Roi>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllRois();
});

final roiByIdProvider = FutureProvider.family<Roi, String>((ref, id) {
  final db = ref.watch(databaseProvider);
  return db.getRoiById(id);
});
