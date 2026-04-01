import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import '../../poi/providers/poi_provider.dart';
import '../providers/calendar_provider.dart';
import '../widgets/week_strip.dart';
import '../widgets/time_chunk_card.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final chunksAsync = ref.watch(timeChunksByDateProvider(dateStr));
    final backlogAsync = ref.watch(backlogChunksProvider);
    final poisMapAsync = ref.watch(allPoisProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy').format(selectedDate)),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Today',
            onPressed: () {
              ref.read(selectedDateProvider.notifier).state = DateTime.now();
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Pick date',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2024),
                lastDate: DateTime(2030),
              );
              if (picked != null) {
                ref.read(selectedDateProvider.notifier).state = picked;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Week strip
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  onPressed: () {
                    ref.read(selectedDateProvider.notifier).state =
                        selectedDate.subtract(const Duration(days: 7));
                  },
                ),
                Expanded(
                  child: WeekStrip(
                    selectedDate: selectedDate,
                    onDateSelected: (d) =>
                        ref.read(selectedDateProvider.notifier).state = d,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: () {
                    ref.read(selectedDateProvider.notifier).state =
                        selectedDate.add(const Duration(days: 7));
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Day schedule
          Expanded(
            flex: 3,
            child: poisMapAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (poisMap) => chunksAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
                data: (chunks) {
                  if (chunks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_available,
                              size: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant),
                          const SizedBox(height: 12),
                          Text(
                            'No visits scheduled',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Schedule from a POI or drag from backlog',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    );
                  }
                  // Sort by start time
                  final sorted = List<TimeChunk>.from(chunks)
                    ..sort((a, b) =>
                        (a.startTime ?? '').compareTo(b.startTime ?? ''));
                  return ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: sorted.length,
                    itemBuilder: (context, index) {
                      final chunk = sorted[index];
                      final poi = poisMap[chunk.poiId];
                      return TimeChunkCard(
                        chunk: chunk,
                        poiName: poi?.name ?? 'Unknown POI',
                        onAction: (action) =>
                            _handleChunkAction(ref, action, chunk),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Backlog section
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.inbox, size: 18),
                      const SizedBox(width: 8),
                      Text('Backlog',
                          style: Theme.of(context).textTheme.titleSmall),
                      const Spacer(),
                      backlogAsync.when(
                        data: (chunks) => Text('${chunks.length} items',
                            style: Theme.of(context).textTheme.labelSmall),
                        loading: () => const SizedBox.shrink(),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: backlogAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (chunks) {
                      if (chunks.isEmpty) {
                        return const Center(child: Text('Backlog is empty'));
                      }
                      return poisMapAsync.when(
                        loading: () => const Center(
                            child: CircularProgressIndicator()),
                        error: (err, _) =>
                            Center(child: Text('Error: $err')),
                        data: (poisMap) => ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: chunks.length,
                          itemBuilder: (context, index) {
                            final chunk = chunks[index];
                            final poi = poisMap[chunk.poiId];
                            return Card(
                              child: ListTile(
                                dense: true,
                                leading:
                                    const Icon(Icons.location_on, size: 20),
                                title: Text(poi?.name ?? chunk.poiId),
                                trailing: FilledButton.tonal(
                                  onPressed: () => _scheduleForDate(
                                      ref, chunk, dateStr),
                                  child: const Text('Schedule'),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scheduleForDate(WidgetRef ref, TimeChunk chunk, String dateStr) {
    final db = ref.read(databaseProvider);
    db.updateTimeChunk(TimeChunksCompanion(
      id: Value(chunk.id),
      poiId: Value(chunk.poiId),
      date: Value(dateStr),
      startTime: Value(chunk.startTime ?? '10:00'),
      endTime: Value(chunk.endTime ?? '12:00'),
      status: const Value('scheduled'),
    ));
  }

  void _handleChunkAction(WidgetRef ref, String action, TimeChunk chunk) {
    final db = ref.read(databaseProvider);
    if (action == 'delete') {
      db.deleteTimeChunk(chunk.id);
      return;
    }
    db.updateTimeChunk(TimeChunksCompanion(
      id: Value(chunk.id),
      poiId: Value(chunk.poiId),
      date: Value(action == 'backlog' ? null : chunk.date),
      startTime: Value(action == 'backlog' ? null : chunk.startTime),
      endTime: Value(action == 'backlog' ? null : chunk.endTime),
      status: Value(action),
    ));
  }
}
