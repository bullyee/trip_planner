import 'package:flutter_test/flutter_test.dart';
import 'package:trip_planner/core/utils/schedule_engine.dart';
import 'package:trip_planner/features/calendar/models/time_chunk_model.dart';
import 'package:trip_planner/features/calendar/repositories/time_chunk_repository.dart';

class FakeTimeChunkRepository implements TimeChunkRepository {
  List<TimeChunkModel> lastUpdatedChunks = [];

  @override
  Future<void> batchUpdateTimeChunks(List<TimeChunkModel> chunks) async {
    lastUpdatedChunks = List.from(chunks);
  }

  @override
  Future<void> addTimeChunk(TimeChunkModel chunk) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateTimeChunk(TimeChunkModel chunk) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTimeChunk(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<void> executeRebirth(
    TimeChunkModel stashedChunk, {
    required String newDate,
    String? newStartTime,
    String? newEndTime,
  }) async {
    throw UnimplementedError();
  }

  @override
  Stream<List<TimeChunkModel>> watchTimeChunksByPoi(String poiId) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TimeChunkModel>> watchTimeChunksByDate(String date) {
    throw UnimplementedError();
  }

  @override
  Stream<List<TimeChunkModel>> watchBacklogChunks() {
    throw UnimplementedError();
  }
}

TimeChunkModel createChunk({
  required String id,
  required int sortOrder,
  String? startTime,
  String? endTime,
  int duration = 60,
  int transitDuration = 0,
  bool isFixedTime = false,
}) {
  return TimeChunkModel(
    id: id,
    poiId: 'poi_$id',
    authorId: 'test_author',
    date: '2026-10-30',
    startTime: startTime,
    endTime: endTime,
    duration: duration,
    transitDuration: transitDuration,
    isFixedTime: isFixedTime,
    sortOrder: sortOrder,
    createdAt: DateTime.now().millisecondsSinceEpoch,
  );
}

void main() {
  late FakeTimeChunkRepository repository;
  late ScheduleEngine engine;

  setUp(() {
    repository = FakeTimeChunkRepository();
    engine = ScheduleEngine(repository);
  });

  group('ScheduleEngine auto-cascading', () {
    test('Empty list does not update repository', () async {
      await engine.recalculateDaySchedule([]);
      expect(repository.lastUpdatedChunks, isEmpty);
    });

    test('Cascades flexible chunks sequentially with transit time', () async {
      final chunks = [
        createChunk(
          id: 'chunk_1',
          sortOrder: 1,
          startTime: '09:00',
          duration: 60,
          transitDuration: 15,
        ),
        createChunk(
          id: 'chunk_2',
          sortOrder: 2,
          duration: 45,
          transitDuration: 10,
        ),
        createChunk(
          id: 'chunk_3',
          sortOrder: 3,
          duration: 30,
        ),
      ];

      await engine.recalculateDaySchedule(chunks);

      final updated = repository.lastUpdatedChunks;
      expect(updated.length, 3);

      // chunk_1: 09:00 - 10:00, transit 15m -> next cursor 10:15
      expect(updated[0].id, 'chunk_1');
      expect(updated[0].startTime, '09:00');
      expect(updated[0].endTime, '10:00');
      expect(updated[0].sortOrder, 1024);

      // chunk_2: 10:15 - 11:00, transit 10m -> next cursor 11:10
      expect(updated[1].id, 'chunk_2');
      expect(updated[1].startTime, '10:15');
      expect(updated[1].endTime, '11:00');
      expect(updated[1].sortOrder, 2048);

      // chunk_3: 11:10 - 11:40
      expect(updated[2].id, 'chunk_3');
      expect(updated[2].startTime, '11:10');
      expect(updated[2].endTime, '11:40');
      expect(updated[2].sortOrder, 3072);
    });

    test('Fixed-time chunk with later time advances cursor (gap/free time)', () async {
      final chunks = [
        createChunk(
          id: 'chunk_1',
          sortOrder: 1,
          startTime: '09:00',
          duration: 60,
          transitDuration: 0,
        ),
        createChunk(
          id: 'chunk_2',
          sortOrder: 2,
          startTime: '11:00',
          isFixedTime: true,
          duration: 60,
          transitDuration: 10,
        ),
        createChunk(
          id: 'chunk_3',
          sortOrder: 3,
          duration: 30,
        ),
      ];

      await engine.recalculateDaySchedule(chunks);

      final updated = repository.lastUpdatedChunks;
      expect(updated.length, 3);

      // chunk_1 ends at 10:00
      expect(updated[0].startTime, '09:00');
      expect(updated[0].endTime, '10:00');

      // chunk_2 is fixed at 11:00 -> 12:00, transit 10m -> next cursor 12:10
      expect(updated[1].startTime, '11:00');
      expect(updated[1].endTime, '12:00');

      // chunk_3 starts at 12:10 -> 12:40
      expect(updated[2].startTime, '12:10');
      expect(updated[2].endTime, '12:40');
    });

    test('Issue #51: Fixed-time chunk with earlier time keeps locked time and does not regress cursor', () async {
      // Repro from Issue #51:
      // Chunk A is flexible, starts at 10:00, ends at 11:00 (transit 10m -> 11:10).
      // Chunk B is locked to 09:00 (duration 30m, transit 10m -> ends 09:40).
      // Chunk C is flexible (duration 60m).
      final chunks = [
        createChunk(
          id: 'chunk_a',
          sortOrder: 1,
          startTime: '10:00',
          duration: 60,
          transitDuration: 10,
        ),
        createChunk(
          id: 'chunk_b',
          sortOrder: 2,
          startTime: '09:00',
          isFixedTime: true,
          duration: 30,
          transitDuration: 10,
        ),
        createChunk(
          id: 'chunk_c',
          sortOrder: 3,
          duration: 60,
        ),
      ];

      await engine.recalculateDaySchedule(chunks);

      final updated = repository.lastUpdatedChunks;
      expect(updated.length, 3);

      // Chunk A starts at 10:00 and ends at 11:00 (not pulled back to 09:00)
      expect(updated[0].id, 'chunk_a');
      expect(updated[0].startTime, '10:00');
      expect(updated[0].endTime, '11:00');

      // Chunk B preserves its pinned 09:00 time
      expect(updated[1].id, 'chunk_b');
      expect(updated[1].startTime, '09:00');
      expect(updated[1].endTime, '09:30');

      // Chunk C does NOT jump backwards to 09:40; it continues forward from Chunk A's 11:10 cursor
      expect(updated[2].id, 'chunk_c');
      expect(updated[2].startTime, '11:10');
      expect(updated[2].endTime, '12:10');
    });

    test('Fixed-time chunk overlapping earlier chunk but ending later advances cursor', () async {
      // Chunk A: 10:00 - 11:00, transit 10m (cursor would be 11:10)
      // Chunk B: fixed at 10:30, duration 60m -> ends at 11:30, transit 15m -> 11:45
      // Chunk C: flexible, duration 30m
      final chunks = [
        createChunk(
          id: 'chunk_a',
          sortOrder: 1,
          startTime: '10:00',
          duration: 60,
          transitDuration: 10,
        ),
        createChunk(
          id: 'chunk_b',
          sortOrder: 2,
          startTime: '10:30',
          isFixedTime: true,
          duration: 60,
          transitDuration: 15,
        ),
        createChunk(
          id: 'chunk_c',
          sortOrder: 3,
          duration: 30,
        ),
      ];

      await engine.recalculateDaySchedule(chunks);

      final updated = repository.lastUpdatedChunks;
      expect(updated.length, 3);

      // Chunk A: 10:00 - 11:00
      expect(updated[0].startTime, '10:00');
      expect(updated[0].endTime, '11:00');

      // Chunk B: locked at 10:30 - 11:30
      expect(updated[1].startTime, '10:30');
      expect(updated[1].endTime, '11:30');

      // Chunk C: advances to 11:45 (11:30 + 15m transit)
      expect(updated[2].startTime, '11:45');
      expect(updated[2].endTime, '12:15');
    });

    test('Reordering flexible chunks preserves earliest schedule start time', () async {
      // Chunk 1 was previously at 09:00, Chunk 2 was at 10:00.
      // Chunk 2 is dragged before Chunk 1 (sortOrder 0 vs 1).
      final chunks = [
        createChunk(
          id: 'chunk_2',
          sortOrder: 0,
          startTime: '10:00',
          duration: 60,
          transitDuration: 0,
        ),
        createChunk(
          id: 'chunk_1',
          sortOrder: 1,
          startTime: '09:00',
          duration: 60,
          transitDuration: 0,
        ),
      ];

      await engine.recalculateDaySchedule(chunks);

      final updated = repository.lastUpdatedChunks;
      expect(updated.length, 2);

      // chunk_2 gets the earliest day time (09:00)
      expect(updated[0].id, 'chunk_2');
      expect(updated[0].startTime, '09:00');
      expect(updated[0].endTime, '10:00');

      // chunk_1 cascades after chunk_2
      expect(updated[1].id, 'chunk_1');
      expect(updated[1].startTime, '10:00');
      expect(updated[1].endTime, '11:00');
    });

    test('First chunk fixed-time initializes cursor from its start time', () async {
      final chunks = [
        createChunk(
          id: 'chunk_1',
          sortOrder: 1,
          startTime: '13:00',
          isFixedTime: true,
          duration: 90,
          transitDuration: 10,
        ),
        createChunk(
          id: 'chunk_2',
          sortOrder: 2,
          duration: 30,
        ),
      ];

      await engine.recalculateDaySchedule(chunks);

      final updated = repository.lastUpdatedChunks;
      expect(updated.length, 2);

      expect(updated[0].startTime, '13:00');
      expect(updated[0].endTime, '14:30');

      expect(updated[1].startTime, '14:40');
      expect(updated[1].endTime, '15:10');
    });
  });
}
