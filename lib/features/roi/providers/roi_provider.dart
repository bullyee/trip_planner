import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../repositories/roi_repository.dart';
import '../models/roi_model.dart';

part 'roi_provider.g.dart';

@riverpod
Stream<List<RoiModel>> allRois(AllRoisRef ref) {
  return ref.watch(roiRepositoryProvider).watchAllRois();
}

@riverpod
Stream<RoiModel?> roiById(RoiByIdRef ref, String id) {
  return ref.watch(roiRepositoryProvider).watchRoiById(id);
}