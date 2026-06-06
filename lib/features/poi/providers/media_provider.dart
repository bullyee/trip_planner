// --- Code/Comments must be in English ---
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/media_asset_model.dart';
import '../models/reference_image_model.dart';
import '../repositories/media_repository.dart';

part 'media_provider.g.dart';

@riverpod
Stream<List<MediaAssetModel>> mediaAssetsByPoi(MediaAssetsByPoiRef ref, String poiId) {
  return ref.watch(mediaRepositoryProvider).watchMediaAssetsByPoi(poiId);
}

@riverpod
Stream<List<ReferenceImageModel>> referenceImagesByPoi(ReferenceImagesByPoiRef ref, String poiId) {
  return ref.watch(mediaRepositoryProvider).watchReferenceImagesByPoi(poiId);
}

@riverpod
Stream<List<MediaAssetModel>> ticketAssets(TicketAssetsRef ref) {
  return ref.watch(mediaRepositoryProvider).watchMediaAssetsByType('ticket_qr');
}