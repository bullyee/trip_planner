import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/database_provider.dart';
import '../../poi/providers/poi_provider.dart';
import '../../roi/providers/roi_provider.dart';
import '../providers/last_selected_backlog_roi_provider.dart';
import '../providers/calendar_provider.dart';
import '../widgets/week_strip.dart';
import '../widgets/time_chunk_card.dart';
import '../../../core/utils/schedule_utils.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _isBacklogExpanded = false;

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final chunksAsync = ref.watch(timeChunksByDateProvider(dateStr));
    final backlogAsync = ref.watch(backlogChunksProvider);
    final poisMapAsync = ref.watch(allPoisProvider);

    // Backlog heights calculated proportionally to the screen height
    final screenHeight = MediaQuery.of(context).size.height;
    final expandedBacklogHeight = screenHeight * 0.4; // 40%
    final collapsedBacklogHeight = screenHeight * 0.2; // 20%

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
              final picked = await showMonthCalendarPicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(DateTime.now().year - 10),
                lastDate: DateTime(DateTime.now().year + 10),
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
                            handleTimeChunkAction(context, ref, action, chunk),
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // -----------------------------------------------------------
          // Backlog Section：AnimatedContainer
          // -----------------------------------------------------------
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: _isBacklogExpanded
              ? expandedBacklogHeight
              : collapsedBacklogHeight,
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
                InkWell(
                  onTap: () {
                    setState(() {
                      _isBacklogExpanded = !_isBacklogExpanded;
                    });
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          tooltip: 'Add to backlog',
                          onPressed: () => _showAddToBacklogDialog(context, ref),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _isBacklogExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                
                Expanded(
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, 
                            vertical: 4
                          ),
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
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 36, minHeight: 36),
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.delete),
                                      tooltip: 'Delete',
                                      onPressed: () => confirmDeleteTimeChunkAndRemove(
                                        context, ref, chunk),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 36, minHeight: 36),
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.edit),
                                      tooltip: 'Edit',
                                      onPressed: () => showScheduleEditDialog(
                                        context, ref, chunk),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 36, minHeight: 36),
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.add),
                                      tooltip: 'Schedule',
                                      onPressed: () => _scheduleForDate(
                                        ref, chunk, dateStr),
                                    ),
                                  ],
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

  Future<void> _scheduleForDate(WidgetRef ref, TimeChunk chunk, String dateStr) async {
    final db = ref.read(databaseProvider);
    await db.updateTimeChunk(TimeChunksCompanion(
      id: Value(chunk.id),
      poiId: Value(chunk.poiId),
      date: Value(dateStr),
      startTime: Value(chunk.startTime ?? '10:00'),
      endTime: Value(chunk.endTime ?? '12:00'),
      status: const Value('scheduled'),
    ));
  }

  Future<void> _showAddToBacklogDialog(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    String? selectedRoiId;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Consumer(
              builder: (context, dialogRef, _) {
                final roisAsync = dialogRef.watch(allRoisProvider);

                return AlertDialog(
                  title: const Text('Add to Backlog'),
                  content: roisAsync.when(
                    loading: () => const SizedBox(
                      width: 400,
                      height: 300,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => SizedBox(
                      width: 400,
                      height: 300,
                      child: Center(child: Text('Error: $err')),
                    ),
                    data: (rois) {
                      if (rois.isEmpty) {
                        return const SizedBox(
                          width: 400,
                          height: 300,
                          child: Center(child: Text('No ROIs available')),
                        );
                      }

                      // Initialize selectedRoiId with previously saved ROI or first ROI
                      final saved = dialogRef.read(lastSelectedBacklogRoiProvider);
                      selectedRoiId ??= saved ?? rois.first.id;

                      // Show ROI selector and POI list in fixed layout
                      final poisAsync = dialogRef.watch(poisByRoiProvider(selectedRoiId!));
                      return SizedBox(
                        width: 400,
                        height: 400,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Region label
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Region',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                            ),
                            // ROI Selector (fixed at top)
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedRoiId,
                                items: rois
                                    .map((roi) => DropdownMenuItem<String>(
                                          value: roi.id,
                                          child: Text(roi.name),
                                        ))
                                    .toList(),
                                onChanged: (String? newRoiId) {
                                  if (newRoiId != null) {
                                    setDialogState(() {
                                      selectedRoiId = newRoiId;
                                    });
                                    // persist selection in session state
                                    dialogRef.read(lastSelectedBacklogRoiProvider.notifier).state = newRoiId;
                                  }
                                },
                              ),
                            ),
                            // Locations label
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Locations',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                            ),
                            // POI List
                            Expanded(
                              child: poisAsync.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (err, _) => Center(
                                  child: Text('Error: $err'),
                                ),
                                data: (pois) {
                                  if (pois.isEmpty) {
                                    return const Center(
                                      child: Text('No locations yet.'),
                                    );
                                  }
                                  return ListView.separated(
                                    itemCount: pois.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final poi = pois[index];
                                      return ListTile(
                                        title: Text(poi.name),
                                        subtitle: Text(poi.address ?? 'No address'),
                                        onTap: () async {
                                          // persist last selected ROI for backlog block
                                          dialogRef.read(lastSelectedBacklogRoiProvider.notifier).state = selectedRoiId;
                                          // Create a new time chunk in backlog status
                                          final db = dialogRef.read(databaseProvider);
                                          await db.insertTimeChunk(
                                            TimeChunksCompanion(
                                              id: Value(const Uuid().v4()),
                                              poiId: Value(poi.id),
                                              date: const Value(null),
                                              startTime: const Value('10:00'),
                                              endTime: const Value('12:00'),
                                              status: const Value('backlog'),
                                            ),
                                          );
                                          if (context.mounted) {
                                            Navigator.pop(context);
                                          }
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

}