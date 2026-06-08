// lib/features/calendar/models/time_chunk_model.dart

class TimeChunkModel {
  final String id;
  final String poiId;
  final String authorId;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? status;
  
  final int createdAt;
  final bool isShared;

  TimeChunkModel({
    required this.id,
    required this.poiId,
    required this.authorId,
    this.date,
    this.startTime,
    this.endTime,
    this.status,
    required this.createdAt,
    this.isShared = false,
  });
}