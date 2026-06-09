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

  final int sortOrder;
  final int duration;
  final int transitDuration;
  final bool isFixedTime;
  final int syncStatus;
  final bool isDeleted;
  final bool hasEverSynced;

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
    this.sortOrder = 0,
    this.duration = 60,
    this.transitDuration = 0,
    this.isFixedTime = false,
    this.syncStatus = 0,
    this.isDeleted = false,
    this.hasEverSynced = false,
  });

  TimeChunkModel copyWith({
    String? id,
    String? poiId,
    String? authorId,
    String? date,
    String? startTime,
    String? endTime,
    String? status,
    int? createdAt,
    bool? isShared,
    int? sortOrder,
    int? duration,
    int? transitDuration,
    bool? isFixedTime,
    int? syncStatus,
    bool? isDeleted,
    bool? hasEverSynced,
  }) {
    return TimeChunkModel(
      id: id ?? this.id,
      poiId: poiId ?? this.poiId,
      authorId: authorId ?? this.authorId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isShared: isShared ?? this.isShared,
      sortOrder: sortOrder ?? this.sortOrder,
      duration: duration ?? this.duration,
      transitDuration: transitDuration ?? this.transitDuration,
      isFixedTime: isFixedTime ?? this.isFixedTime,
      syncStatus: syncStatus ?? this.syncStatus,
      isDeleted: isDeleted ?? this.isDeleted,
      hasEverSynced: hasEverSynced ?? this.hasEverSynced,
    );
  }
}
