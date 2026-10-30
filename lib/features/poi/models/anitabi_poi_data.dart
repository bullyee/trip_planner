class AnitabiPoiData {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final String description;
  final String? imageUrl;
  final String? imageMetadata;

  const AnitabiPoiData({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.description,
    this.imageUrl,
    this.imageMetadata,
  });
}

class AnitabiImportBatchResult {
  final String animeId;
  final int imported;
  final int skipped;
  final List<PendingCoverDownload> pendingDownloads;

  const AnitabiImportBatchResult({
    required this.animeId,
    required this.imported,
    required this.skipped,
    required this.pendingDownloads,
  });
}

class PendingCoverDownload {
  final String poiId;
  final String url;
  final String metadata;

  const PendingCoverDownload({
    required this.poiId,
    required this.url,
    required this.metadata,
  });
}
