import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/roi_repository.dart';
import '../models/roi_model.dart';

final allRoisProvider = StreamProvider<List<RoiModel>>((ref) {
  return ref.watch(roiRepositoryProvider).watchAllRois();
});

final roiByIdProvider = StreamProvider.family<RoiModel?, String>((ref, id) {
  return ref.watch(roiRepositoryProvider).watchRoiById(id);
});
