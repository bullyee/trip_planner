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

    test('Issue #51: Fixed-time chunk with earlier time orders chronologically without cursor regression', () async {
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

      // Chronological normalization orders chunk_b (09:00) before chunk_a (10:00)
      expect(updated[0].id, 'chunk_b');
      expect(updated[0].startTime, '09:00');
      expect(updated[0].endTime, '09:30');
      expect(updated[0].sortOrder, 1024);

      // Chunk A starts at 10:00 and ends at 11:00
      expect(updated[1].id, 'chunk_a');
      expect(updated[1].startTime, '10:00');
      expect(updated[1].endTime, '11:00');
      expect(updated[1].sortOrder, 2048);

      // Chunk C continues forward after chunk_a + transit at 11:10
      expect(updated[2].id, 'chunk_c');
      expect(updated[2].startTime, '11:10');
      expect(updated[2].endTime, '12:10');
      expect(updated[2].sortOrder, 3072);

      // Verify gap calculation matches
      final gapBA = calculateScheduleGap(updated[0], updated[1]);
      expect(gapBA?.isConflict, isFalse);
      expect(gapBA?.freeTimeMinutes, 20); // 09:40 arrival to 10:00 start

      final gapAC = calculateScheduleGap(updated[1], updated[2]);
      expect(gapAC?.isConflict, isFalse);
      expect(gapAC?.freeTimeMinutes, 0); // starts right on time at 11:10
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

      // Gap between A and B is a conflict of 40 minutes (11:10 arrival vs 10:30 start)
      final gap = calculateScheduleGap(updated[0], updated[1]);
      expect(gap?.isConflict, isTrue);
      expect(gap?.conflictMinutes, 40);
    });

    test('Midnight wrap-around: Fixed chunk at 00:00 advances cursor across midnight into 01:00', () async {
      // Test case from bullyee review:
      // A locked 22:00 d60 t30 (ends 23:30)
      // F locked 00:00 d60 (ends 01:00 next day)
      // R flex d60 -> must land at 01:00, not 23:30!
      final chunks = [
        createChunk(
          id: 'chunk_a',
          sortOrder: 1,
          startTime: '22:00',
          isFixedTime: true,
          duration: 60,
          transitDuration: 30,
        ),
        createChunk(
          id: 'chunk_f',
          sortOrder: 2,
          startTime: '00:00',
          isFixedTime: true,
          duration: 60,
          transitDuration: 0,
        ),
        createChunk(
          id: 'chunk_r',
          sortOrder: 3,
          duration: 60,
          transitDuration: 0,
        ),
      ];

      await engine.recalculateDaySchedule(chunks);

      final updated = repository.lastUpdatedChunks;
      expect(updated.length, 3);

      // A: 22:00 - 23:00, arrival 23:30
      expect(updated[0].id, 'chunk_a');
      expect(updated[0].startTime, '22:00');
      expect(updated[0].endTime, '23:00');

      // F: 00:00 - 01:00
      expect(updated[1].id, 'chunk_f');
      expect(updated[1].startTime, '00:00');
      expect(updated[1].endTime, '01:00');

      // R: starts at 01:00 - 02:00 (not overlapping F!)
      expect(updated[2].id, 'chunk_r');
      expect(updated[2].startTime, '01:00');
      expect(updated[2].endTime, '02:00');

      // Gap between A and F: Free time 30 min (23:30 arrival to 00:00 midnight), NOT Conflict: 1440 min
      final gapAF = calculateScheduleGap(updated[0], updated[1]);
      expect(gapAF?.isConflict, isFalse);
      expect(gapAF?.freeTimeMinutes, 30);

      // Gap between F and R: starts right on time at 01:00
      final gapFR = calculateScheduleGap(updated[1], updated[2]);
      expect(gapFR?.isConflict, isFalse);
      expect(gapFR?.freeTimeMinutes, 0);
    });

    test('Reordering flexible chunk below locked chunk and back above preserves morning start without backwards jump', () async {
      // Test case from bullyee review:
      // Start: [A flex 09:00 d60, L locked 13:00 d60]
      // Drag A below L -> [L 13:00-14:00, A 14:00-15:00]
      final initialChunks = [
        createChunk(
          id: 'chunk_l',
          sortOrder: 1,
          startTime: '13:00',
          isFixedTime: true,
          duration: 60,
          transitDuration: 0,
        ),
        createChunk(
          id: 'chunk_a',
          sortOrder: 2,
          startTime: '09:00',
          duration: 60,
          transitDuration: 0,
        ),
      ];

      // After dragging A below L
      await engine.recalculateDaySchedule(initialChunks);
      final afterFirstDrag = repository.lastUpdatedChunks;
      expect(afterFirstDrag[0].id, 'chunk_l');
      expect(afterFirstDrag[0].startTime, '13:00');
      expect(afterFirstDrag[1].id, 'chunk_a');
      expect(afterFirstDrag[1].startTime, '14:00');

      // Now drag A back to the top above L
      final dragBackChunks = [
        afterFirstDrag[1].copyWith(sortOrder: 0), // chunk_a at top
        afterFirstDrag[0].copyWith(sortOrder: 1), // chunk_l second
      ];

      await engine.recalculateDaySchedule(dragBackChunks);
      final afterDragBack = repository.lastUpdatedChunks;
      expect(afterDragBack.length, 2);

      // chunk_a resets back to morning (09:00 - 10:00) instead of being stuck at 14:00
      expect(afterDragBack[0].id, 'chunk_a');
      expect(afterDragBack[0].startTime, '09:00');
      expect(afterDragBack[0].endTime, '10:00');

      // chunk_l remains pinned at 13:00 - 14:00
      expect(afterDragBack[1].id, 'chunk_l');
      expect(afterDragBack[1].startTime, '13:00');
      expect(afterDragBack[1].endTime, '14:00');

      // Gap between A and L is free time (180 min)
      final gap = calculateScheduleGap(afterDragBack[0], afterDragBack[1]);
      expect(gap?.isConflict, isFalse);
      expect(gap?.freeTimeMinutes, 180);
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

    test('New Issue 1: Reordering flex cards above a locked card preserves earliest flex start', () async {
      // Repro from review: [A 09:00, B 10:00, C 11:00, L locked 15:00]
      // Drag B to top: [B (sortOrder 0), A (sortOrder 1), C (sortOrder 2), L (sortOrder 3)]
      final chunks = [
        createChunk(
          id: 'chunk_b',
          sortOrder: 0,
          startTime: '10:00',
          duration: 60,
          transitDuration: 0,
        ),
        createChunk(
          id: 'chunk_a',
          sortOrder: 1,
          startTime: '09:00',
          duration: 60,
          transitDuration: 0,
        ),
        createChunk(
          id: 'chunk_c',
          sortOrder: 2,
          startTime: '11:00',
          duration: 60,
          transitDuration: 0,
        ),
        createChunk(
          id: 'chunk_l',
          sortOrder: 3,
          startTime: '15:00',
          isFixedTime: true,
          duration: 60,
          transitDuration: 0,
        ),
      ];

      await engine.recalculateDaySchedule(chunks);

      final updated = repository.lastUpdatedChunks;
      expect(updated.length, 4);

      // B gets 09:00 (earliest flex start), morning 09:00-10:00 is NOT empty
      expect(updated[0].id, 'chunk_b');
      expect(updated[0].startTime, '09:00');
      expect(updated[0].endTime, '10:00');

      // A cascades after B at 10:00
      expect(updated[1].id, 'chunk_a');
      expect(updated[1].startTime, '10:00');
      expect(updated[1].endTime, '11:00');

      // C cascades after A at 11:00
      expect(updated[2].id, 'chunk_c');
      expect(updated[2].startTime, '11:00');
      expect(updated[2].endTime, '12:00');

      // L remains locked at 15:00
      expect(updated[3].id, 'chunk_l');
      expect(updated[3].startTime, '15:00');
      expect(updated[3].endTime, '16:00');
    });

    test('New Issue 2: Locked morning card dragged between afternoon cards does not wrap into tomorrow', () async {
      // Repro from review: [L locked 07:30 d60, A 08:30 d300 t60, B d300 t60, C d60]
      // Drag L between B and C: [A, B, L, C]
      final chunks = [
        createChunk(
          id: 'chunk_a',
          sortOrder: 1,
          startTime: '08:30',
          duration: 300,
          transitDuration: 60,
        ),
        createChunk(
          id: 'chunk_b',
          sortOrder: 2,
          duration: 300,
          transitDuration: 60,
        ),
        createChunk(
          id: 'chunk_l',
          sortOrder: 3,
          startTime: '07:30',
          isFixedTime: true,
          duration: 60,
          transitDuration: 0,
        ),
        createChunk(
          id: 'chunk_c',
          sortOrder: 4,
          duration: 60,
          transitDuration: 0,
        ),
      ];

      await engine.recalculateDaySchedule(chunks);

      final updated = repository.lastUpdatedChunks;
      expect(updated.length, 4);

      // L (07:30) is sorted chronologically at the top, not wrapped to next day
      expect(updated[0].id, 'chunk_l');
      expect(updated[0].startTime, '07:30');
      expect(updated[0].endTime, '08:30');

      // A starts at 08:30 -> 13:30, arrival 14:30
      expect(updated[1].id, 'chunk_a');
      expect(updated[1].startTime, '08:30');
      expect(updated[1].endTime, '13:30');

      // B starts at 14:30 -> 19:30, arrival 20:30
      expect(updated[2].id, 'chunk_b');
      expect(updated[2].startTime, '14:30');
      expect(updated[2].endTime, '19:30');

      // C cascades after B at 20:30 -> 21:30 (does NOT land on top of A at 08:30)
      expect(updated[3].id, 'chunk_c');
      expect(updated[3].startTime, '20:30');
      expect(updated[3].endTime, '21:30');
    });

    test('Partly Resolved 2: Day starting before noon and running past midnight keeps 00:00 chunk at end', () async {
      // Repro from review: [A 09:00 d300 t60, B d300 t60, C d180, D d60]
      final chunks = [
        createChunk(
          id: 'chunk_a',
          sortOrder: 1,
          startTime: '09:00',
          duration: 300,
          transitDuration: 60, // 09:00 -> 14:00, arrival 15:00
        ),
        createChunk(
          id: 'chunk_b',
          sortOrder: 2,
          duration: 300,
          transitDuration: 60, // 15:00 -> 20:00, arrival 21:00
        ),
        createChunk(
          id: 'chunk_c',
          sortOrder: 3,
          duration: 180,
          transitDuration: 0, // 21:00 -> 24:00 (00:00)
        ),
        createChunk(
          id: 'chunk_d',
          sortOrder: 4,
          duration: 60,
          transitDuration: 0, // 00:00 -> 01:00
        ),
      ];

      await engine.recalculateDaySchedule(chunks);

      final updated = repository.lastUpdatedChunks;
      expect(updated.length, 4);

      // A stays at the top
      expect(updated[0].id, 'chunk_a');
      expect(updated[0].startTime, '09:00');

      expect(updated[1].id, 'chunk_b');
      expect(updated[1].startTime, '15:00');

      expect(updated[2].id, 'chunk_c');
      expect(updated[2].startTime, '21:00');
      expect(updated[2].endTime, '00:00');

      // D (00:00 - 01:00) remains at the end of the day, not sorted before A
      expect(updated[3].id, 'chunk_d');
      expect(updated[3].startTime, '00:00');
      expect(updated[3].endTime, '01:00');

      // Re-running or setting D duration to 90 min does NOT restart day at 00:00
      final reloaded = [
        updated[0],
        updated[1],
        updated[2],
        updated[3].copyWith(duration: 90),
      ];
      await engine.recalculateDaySchedule(reloaded);
      final updated2 = repository.lastUpdatedChunks;

      expect(updated2[0].id, 'chunk_a');
      expect(updated2[0].startTime, '09:00');
      expect(updated2[3].id, 'chunk_d');
      expect(updated2[3].startTime, '00:00');
      expect(updated2[3].endTime, '01:30');
    });

    test('Evening day with downstream midnight crossing preserves start time on recalculation', () async {
      // Repro from review: [A 20:00 d60, L locked 22:00 d60 t30, B d60, C d60]
      final chunks = [
        createChunk(id: 'chunk_a', sortOrder: 1, startTime: '20:00', duration: 60),
        createChunk(id: 'chunk_l', sortOrder: 2, isFixedTime: true, startTime: '22:00', duration: 60, transitDuration: 30),
        createChunk(id: 'chunk_b', sortOrder: 3, duration: 60),
        createChunk(id: 'chunk_c', sortOrder: 4, duration: 60),
      ];

      await engine.recalculateDaySchedule(chunks);
      final updated = repository.lastUpdatedChunks;

      expect(updated[0].id, 'chunk_a');
      expect(updated[0].startTime, '20:00');
      expect(updated[1].id, 'chunk_l');
      expect(updated[1].startTime, '22:00');
      expect(updated[2].id, 'chunk_b');
      expect(updated[2].startTime, '23:30');
      expect(updated[3].id, 'chunk_c');
      expect(updated[3].startTime, '00:30');

      // Recalculating again without changes must NOT restart at 00:30
      await engine.recalculateDaySchedule(updated);
      final updated2 = repository.lastUpdatedChunks;

      expect(updated2[0].id, 'chunk_a');
      expect(updated2[0].startTime, '20:00');
      expect(updated2[1].id, 'chunk_l');
      expect(updated2[1].startTime, '22:00');
      expect(updated2[2].id, 'chunk_b');
      expect(updated2[2].startTime, '23:30');
      expect(updated2[3].id, 'chunk_c');
      expect(updated2[3].startTime, '00:30');
    });
  });

  group('calculateScheduleGap conflict and free time pill calculations', () {
    test('Calculates positive free time when there is a gap', () {
      final prev = createChunk(
        id: 'p1',
        sortOrder: 1,
        startTime: '09:00',
        endTime: '10:00',
        transitDuration: 15,
      );
      final curr = createChunk(
        id: 'p2',
        sortOrder: 2,
        startTime: '10:45',
        endTime: '11:45',
      );

      final gap = calculateScheduleGap(prev, curr);
      expect(gap, isNotNull);
      expect(gap!.isConflict, isFalse);
      expect(gap.freeTimeMinutes, 30); // 10:15 arrival to 10:45 start = 30m
      expect(gap.conflictMinutes, 0);
    });

    test('Calculates exact overlap conflict when chunks collide', () {
      final prev = createChunk(
        id: 'p1',
        sortOrder: 1,
        startTime: '10:00',
        endTime: '11:00',
        transitDuration: 10,
      );
      final curr = createChunk(
        id: 'p2',
        sortOrder: 2,
        startTime: '10:40',
        endTime: '11:40',
      );

      final gap = calculateScheduleGap(prev, curr);
      expect(gap, isNotNull);
      expect(gap!.isConflict, isTrue);
      expect(gap.conflictMinutes, 30); // 11:10 arrival vs 10:40 start = 30m overlap
      expect(gap.freeTimeMinutes, 0);
    });

    test('Calculates zero gap when arrival exactly matches next start', () {
      final prev = createChunk(
        id: 'p1',
        sortOrder: 1,
        startTime: '09:00',
        endTime: '10:00',
        transitDuration: 20,
      );
      final curr = createChunk(
        id: 'p2',
        sortOrder: 2,
        startTime: '10:20',
        endTime: '11:20',
      );

      final gap = calculateScheduleGap(prev, curr);
      expect(gap, isNotNull);
      expect(gap!.isConflict, isFalse);
      expect(gap.gapMinutes, 0);
      expect(gap.freeTimeMinutes, 0);
      expect(gap.conflictMinutes, 0);
    });

    test('Midnight transit wrap-around calculates correctly without 1440m false conflict', () {
      final prev = createChunk(
        id: 'p1',
        sortOrder: 1,
        startTime: '23:00',
        endTime: '23:30',
        transitDuration: 30, // arrival is 24:00 (00:00)
      );
      final curr = createChunk(
        id: 'p2',
        sortOrder: 2,
        startTime: '00:00',
        endTime: '01:00',
      );

      final gap = calculateScheduleGap(prev, curr);
      expect(gap, isNotNull);
      expect(gap!.isConflict, isFalse);
      expect(gap.gapMinutes, 0);
      expect(gap.conflictMinutes, 0);
    });

    test('calculateScheduleGap does not show false conflict on 09:00 day running past midnight', () {
      final a = createChunk(id: 'chunk_a', sortOrder: 1, startTime: '09:00', endTime: '14:00', transitDuration: 60);
      final b = createChunk(id: 'chunk_b', sortOrder: 2, startTime: '15:00', endTime: '20:00', transitDuration: 60);
      final c = createChunk(id: 'chunk_c', sortOrder: 3, startTime: '21:00', endTime: '00:00', transitDuration: 0);
      final d = createChunk(id: 'chunk_d', sortOrder: 4, startTime: '00:00', endTime: '01:00', transitDuration: 0);

      final gap = calculateScheduleGap(c, d, priorChunks: [a, b, c]);
      expect(gap, isNotNull);
      expect(gap!.isConflict, isFalse);
      expect(gap.conflictMinutes, 0);
      expect(gap.freeTimeMinutes, 0);
    });

    test('Midnight crossing with real conflict calculates overlap correctly', () {
      final prev = createChunk(
        id: 'p1',
        sortOrder: 1,
        startTime: '23:00',
        endTime: '23:45',
        transitDuration: 30, // arrival is 00:15 next day
      );
      final curr = createChunk(
        id: 'p2',
        sortOrder: 2,
        startTime: '00:00',
        endTime: '01:00',
      );

      final gap = calculateScheduleGap(prev, curr);
      expect(gap, isNotNull);
      expect(gap!.isConflict, isTrue);
      expect(gap.conflictMinutes, 15); // 00:15 arrival vs 00:00 start = 15m conflict
      expect(gap.freeTimeMinutes, 0);
    });

    test('Partly Resolved 1: Multi-card timeline calculates exact nested overlap and free time', () {
      // Repro from review: [A flex 09:00 d180, L locked 10:00 d30, B flex 12:00 d60]
      final chunkA = createChunk(
        id: 'chunk_a',
        sortOrder: 1,
        startTime: '09:00',
        endTime: '12:00',
        duration: 180,
        transitDuration: 0,
      );
      final chunkL = createChunk(
        id: 'chunk_l',
        sortOrder: 2,
        startTime: '10:00',
        endTime: '10:30',
        duration: 30,
        transitDuration: 0,
        isFixedTime: true,
      );
      final chunkB = createChunk(
        id: 'chunk_b',
        sortOrder: 3,
        startTime: '12:00',
        endTime: '13:00',
        duration: 60,
        transitDuration: 0,
      );

      // Above L: prior is [A], overlap with A [09:00-12:00] is exactly 30m (not 120m)
      final gapL = calculateScheduleGap(chunkA, chunkL, priorChunks: [chunkA]);
      expect(gapL, isNotNull);
      expect(gapL!.isConflict, isTrue);
      expect(gapL.conflictMinutes, 30);
      expect(gapL.freeTimeMinutes, 0);

      // Above B: prior is [A, L], timeline is occupied until 12:00 by A, so B starts right on time
      final gapB = calculateScheduleGap(chunkL, chunkB, priorChunks: [chunkA, chunkL]);
      expect(gapB, isNotNull);
      expect(gapB!.isConflict, isFalse);
      expect(gapB.gapMinutes, 0);
      expect(gapB.freeTimeMinutes, 0);
      expect(gapB.conflictMinutes, 0);
    });
  });
}
