import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../poi/providers/poi_provider.dart';
import '../../roi/providers/roi_provider.dart';
import '../models/time_chunk_model.dart';
import '../providers/last_selected_backlog_roi_provider.dart';
import '../providers/calendar_provider.dart';
import '../repositories/time_chunk_repository.dart';
import '../widgets/time_chunk_card.dart';
import '../widgets/week_strip.dart';
import '../../../core/utils/schedule_utils.dart';
import '../../auth/providers/auth_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  bool _isBacklogExpanded = false;
  // ADDED: State for Backlog batch deletion
  bool _isBacklogSelectionMode = false;
  final Set<String> _selectedBacklogIds = {};

  bool _isScheduleSelectionMode = false;
  final Set<String> _selectedScheduleIds = {};

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
              ref.read(selectedDateProvider.notifier).updateDate(DateTime.now());
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
                ref.read(selectedDateProvider.notifier).updateDate(picked);
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
                    ref.read(selectedDateProvider.notifier).updateDate(
                        selectedDate.subtract(const Duration(days: 7)));
                  },
                ),
                Expanded(
                  child: WeekStrip(
                    selectedDate: selectedDate,
                    onDateSelected: (d) =>
                        ref.read(selectedDateProvider.notifier).updateDate(d),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: () {
                    ref.read(selectedDateProvider.notifier).updateDate(
                        selectedDate.add(const Duration(days: 7)));
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Day schedule
          Expanded(
            flex: 3,
            child: DragTarget<TimeChunkModel>(
              onWillAcceptWithDetails: (details) {
                return details.data.status == 'backlog'; 
              },
              
              onAcceptWithDetails: (details) {
                    final chunkToSchedule = details.data;
                    // Safely extract the current day's schedule from the AsyncValue
                    final currentDayChunks = chunksAsync.value ?? [];
                    _scheduleForDate(context, ref, chunkToSchedule, dateStr, currentDayChunks);
                  },
              
              builder: (context, candidateData, rejectedData) {
                final isHovering = candidateData.isNotEmpty;
                
                return Container(
                  color: isHovering 
                      ?Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : Colors.transparent,
                  child: poisMapAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Error: $err')),
                    data: (poisMap) => chunksAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error: $err')),
                      data: (chunks) {
                        if (chunks.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.event_available,
                                    size: 48,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                                const SizedBox(height: 12),
                                Text(
                                  'No visits scheduled',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Schedule from a POI or drag from backlog',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }
                        // IMPORTANT: Sort by sortOrder instead of startTime to support auto-cascading
                        final sorted = List<TimeChunkModel>.from(chunks)
                          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

                        // We wrap the ReorderableListView in a Column to add a control bar at the top
                        return Column(
                          children: [
                            // ADDED: Control Bar for Schedule Selection
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (_isScheduleSelectionMode) ...[
                                    Text(
                                      '${_selectedScheduleIds.length} selected',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _isScheduleSelectionMode = false;
                                          _selectedScheduleIds.clear();
                                        });
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: 'Delete Selected',
                                      onPressed: _selectedScheduleIds.isEmpty 
                                          ? null 
                                          : () => _deleteSelectedScheduleChunks(sorted),
                                    ),
                                  ] else ...[
                                    const Spacer(),
                                    IconButton(
                                      icon: const Icon(Icons.checklist),
                                      tooltip: 'Manage Schedule',
                                      onPressed: () {
                                        setState(() {
                                          _isScheduleSelectionMode = true;
                                        });
                                      },
                                    ),
                                  ]
                                ],
                              ),
                            ),

                            Expanded(
                              child: ReorderableListView.builder(
                                buildDefaultDragHandles: false,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                itemCount: sorted.length,
                                onReorder: (oldIndex, newIndex) async {
                                  if (_isScheduleSelectionMode) return;

                                  // ReorderableListView reports newIndex in the
                                  // pre-removal coordinate space; adjust when
                                  // dragging an item downward.
                                  if (newIndex > oldIndex) newIndex -= 1;

                                  if (oldIndex == newIndex) return;

                                  try {
                                    final mutableChunks = List<TimeChunkModel>.from(sorted);
                                    final movedChunk = mutableChunks.removeAt(oldIndex);

                                    int newSortOrder;
                                    if (mutableChunks.isEmpty) {
                                      newSortOrder = 0;
                                    } else if (newIndex == 0) {
                                      newSortOrder = mutableChunks.first.sortOrder - 2048;
                                    } else if (newIndex == mutableChunks.length) {
                                      newSortOrder = mutableChunks.last.sortOrder + 2048;
                                    } else {
                                      final int prevOrder = mutableChunks[newIndex - 1].sortOrder;
                                      final int nextOrder = mutableChunks[newIndex].sortOrder;
                                      newSortOrder = prevOrder + ((nextOrder - prevOrder) ~/ 2);
                                    }

                                    final updatedChunk = movedChunk.copyWith(sortOrder: newSortOrder);
                                    mutableChunks.insert(newIndex, updatedChunk);

                                    final engine = ref.read(scheduleEngineProvider);
                                    await engine.recalculateDaySchedule(mutableChunks);
                                  } catch (e) {
                                    debugPrint('Reorder Error: $e');
                                  }
                                },
                                itemBuilder: (context, index) {
                                  final chunk = sorted[index];
                                  final poi = poisMap[chunk.poiId];
                                  final isSelected = _selectedScheduleIds.contains(chunk.id);

                                  Widget gapWidget = const SizedBox.shrink();
                                  if (index > 0) {
                                    final prevChunk = sorted[index - 1];
                                    final prevEndTime = prevChunk.endTime ?? '00:00';
                                    
                                    int prevEndMins = (int.tryParse(prevEndTime.split(':')[0]) ?? 0) * 60 + 
                                                      (int.tryParse(prevEndTime.split(':')[1]) ?? 0);
                                    int arrivalMins = prevEndMins + prevChunk.transitDuration;
                                    
                                    final currStartTime = chunk.startTime ?? '00:00';
                                    int currStartMins = (int.tryParse(currStartTime.split(':')[0]) ?? 0) * 60 + 
                                                        (int.tryParse(currStartTime.split(':')[1]) ?? 0);
                                    
                                    int gap = currStartMins - arrivalMins;
                                    if (gap > 0) {
                                      gapWidget = Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.5),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              'Free Time: $gap min',
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  }

                                  return Container(
                                    key: ValueKey(chunk.id), 
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        gapWidget,
                                        Row(
                                          children: [
                                            if (_isScheduleSelectionMode)
                                              Checkbox(
                                                value: isSelected,
                                                onChanged: (bool? checked) {
                                                  setState(() {
                                                    if (checked == true) {
                                                      _selectedScheduleIds.add(chunk.id);
                                                    } else {
                                                      _selectedScheduleIds.remove(chunk.id);
                                                    }
                                                  });
                                                },
                                              ),
                                            Expanded(
                                              child: TimeChunkCard(
                                                index: index, 
                                                chunk: chunk,
                                                poiName: poi?.name ?? 'Unknown POI',
                                                onAction: (action) {
                                                  if (_isScheduleSelectionMode) return; 

                                                  if (action == 'edit_duration') {
                                                    _showDurationEditDialog(context, ref, chunk, sorted);
                                                  } else if (action == 'edit_transit') {
                                                    _showTransitEditDialog(context, ref, chunk, sorted);
                                                  } else if (action == 'toggle_fixed') {
                                                    final updatedChunk = chunk.copyWith(isFixedTime: !chunk.isFixedTime);
                                                    final updatedChunks = sorted.map((c) => c.id == chunk.id ? updatedChunk : c).toList();
                                                    ref.read(scheduleEngineProvider).recalculateDaySchedule(updatedChunks);
                                                  } else {
                                                    handleTimeChunkAction(context, ref, action, chunk);
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
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
                    // Disable expand/collapse toggle when in selection mode
                    if (_isBacklogSelectionMode) return; 
                    setState(() {
                      _isBacklogExpanded = !_isBacklogExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.inbox, size: 18),
                        const SizedBox(width: 8),
                        // Dynamic Title
                        Text(
                          _isBacklogSelectionMode 
                              ? '${_selectedBacklogIds.length} items selected' 
                              : 'Backlog',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const Spacer(),
                        
                        // Switch UI based on Selection Mode
                        if (_isBacklogSelectionMode) ...[
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isBacklogSelectionMode = false;
                                _selectedBacklogIds.clear();
                              });
                            },
                            child: const Text('Cancel'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Delete selected',
                            onPressed: _selectedBacklogIds.isEmpty ? null : () async {
                              final repository = ref.read(timeChunkRepositoryProvider);
                              // Run batch deletions concurrently
                              final futures = _selectedBacklogIds.map((id) => repository.deleteTimeChunk(id));
                              await Future.wait(futures);
                              
                              setState(() {
                                _isBacklogSelectionMode = false;
                                _selectedBacklogIds.clear();
                              });
                            },
                          ),
                        ] else ...[
                          // Normal Mode Actions
                          backlogAsync.when(
                            data: (chunks) => Text('${chunks.length} items',
                                style: Theme.of(context).textTheme.labelSmall),
                            loading: () => const SizedBox.shrink(),
                            error: (_, _) => const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 8),
                          // ADDED: Explicit 'Manage' button to enter selection mode
                          IconButton(
                            icon: const Icon(Icons.checklist, size: 20),
                            tooltip: 'Manage Backlog',
                            onPressed: () {
                              setState(() {
                                _isBacklogSelectionMode = true;
                                _isBacklogExpanded = true; // Auto-expand when managing
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            tooltip: 'Add to backlog',
                            onPressed: () => _showAddToBacklogDialog(context, ref),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                          ),
                          Icon(
                            _isBacklogExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            size: 20,
                          ),
                        ],
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
                            
                            if (_isBacklogSelectionMode) {
                              final isSelected = _selectedBacklogIds.contains(chunk.id);
                              return Card(
                                child: CheckboxListTile(
                                  title: Text(poi?.name ?? chunk.poiId),
                                  value: isSelected,
                                  onChanged: (bool? checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedBacklogIds.add(chunk.id);
                                      } else {
                                        _selectedBacklogIds.remove(chunk.id);
                                      }
                                    });
                                  },
                                  controlAffinity: ListTileControlAffinity.leading,
                                ),
                              );
                            }

                            return Draggable<TimeChunkModel>(
                              data: chunk,
                              feedback: Material(
                                elevation: 8,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.8,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(poi?.name ?? chunk.poiId, style: const TextStyle(fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: Card(
                                  child: ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.location_on, size: 20),
                                    title: Text(poi?.name ?? chunk.poiId),
                                  ),
                                ),
                              ),
                              child: Card(
                                child: ListTile(
                                  onLongPress: () {
                                    setState(() {
                                      _isBacklogSelectionMode = true;
                                      _selectedBacklogIds.add(chunk.id);
                                    });
                                  },
                                  dense: true,
                                  leading: const Icon(Icons.location_on, size: 20),
                                  title: Text(poi?.name ?? chunk.poiId),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.delete),
                                        tooltip: 'delete',
                                        onPressed: () => confirmDeleteTimeChunkAndRemove(context, ref, chunk),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.edit),
                                        tooltip: 'edit',
                                        onPressed: () => showScheduleEditDialog(context, ref, chunk),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                        visualDensity: VisualDensity.compact,
                                        icon: const Icon(Icons.add),
                                        tooltip: 'add',
                                        onPressed: () {
                                          // CRITICAL: Do NOT use the 'chunks' from the Backlog scope.
                                          // Fetch the day's schedule directly from chunksAsync.
                                          final currentDayChunks = chunksAsync.value ?? [];
                                          _scheduleForDate(context, ref, chunk, dateStr, currentDayChunks);
                                        },
                                      ),
                                    ],
                                  ),
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

  Future<void> _scheduleForDate(
    BuildContext context, 
    WidgetRef ref, 
    TimeChunkModel chunk, 
    String dateStr,
    List<TimeChunkModel> currentDayChunks, // REQUIRED: Pass the current day's schedule
  ) async {
    try {
      final currentUserId = ref.read(currentUserIdProvider);
      
      final dynamic dirtyAuthorId = chunk.authorId;
      final String safeAuthorId = (dirtyAuthorId == null || dirtyAuthorId.toString().isEmpty) 
          ? currentUserId 
          : dirtyAuthorId.toString();

      // Calculate the new sort order (append to the end of the existing schedule)
      int maxOrder = 0;
      if (currentDayChunks.isNotEmpty) {
        maxOrder = currentDayChunks.map((c) => c.sortOrder).reduce((a, b) => a > b ? a : b);
      }
      final int newSortOrder = maxOrder + 1024;

      // Update the chunk properties. Time fields are intentionally left unchanged 
      // as the ScheduleEngine will handle the absolute time allocation.
      final updatedChunk = chunk.copyWith(
        authorId: safeAuthorId,
        date: dateStr,
        status: 'scheduled',
        sortOrder: newSortOrder,
      );

      // Create a mutable copy of the day's schedule and append the new chunk
      final newDayChunks = List<TimeChunkModel>.from(currentDayChunks)..add(updatedChunk);

      // Trigger the cascade engine to recalculate all start and end times
      final engine = ref.read(scheduleEngineProvider);
      await engine.recalculateDaySchedule(newDayChunks);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully scheduled and recalculated for $dateStr!')),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('=== start ===');
      debugPrint('[Schedule Error] Failed to update time chunk: $e');
      debugPrint('$stackTrace');
      debugPrint('===  end  ===');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showAddToBacklogDialog(BuildContext context, WidgetRef ref) async {
    if (!context.mounted) return;

    String? selectedRoiId;
    // ADDED: State to track selected POI IDs within the dialog
    Set<String> selectedPoiIds = {};

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

                      final saved = dialogRef.read(lastSelectedBacklogRoiProvider);
                      selectedRoiId ??= saved ?? rois.first.id;

                      final poisAsync = dialogRef.watch(poisByRoiProvider(selectedRoiId!));
                      
                      return SizedBox(
                        width: 400,
                        height: 400,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                                  if (newRoiId != null && newRoiId != selectedRoiId) {
                                    setDialogState(() {
                                      selectedRoiId = newRoiId;
                                      // CRITICAL: Clear selections when ROI changes
                                      selectedPoiIds.clear(); 
                                    });
                                    ref.read(lastSelectedBacklogRoiProvider.notifier).updateRoi(newRoiId);
                                  }
                                },
                              ),
                            ),
                            
                            Expanded(
                              child: poisAsync.when(
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (err, _) => Center(child: Text('Error: $err')),
                                data: (pois) {
                                  if (pois.isEmpty) {
                                    return const Center(child: Text('No locations yet.'));
                                  }
                                  
                                  // Determine if all items are currently selected
                                  final isAllSelected = selectedPoiIds.length == pois.length && pois.isNotEmpty;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Locations',
                                              style: Theme.of(context).textTheme.labelMedium,
                                            ),
                                            // ADDED: Toggle Select All / Deselect All
                                            TextButton.icon(
                                              onPressed: () {
                                                setDialogState(() {
                                                  if (isAllSelected) {
                                                    selectedPoiIds.clear();
                                                  } else {
                                                    selectedPoiIds = pois.map((p) => p.id).toSet();
                                                  }
                                                });
                                              },
                                              icon: Icon(
                                                isAllSelected ? Icons.deselect : Icons.done_all, 
                                                size: 16
                                              ),
                                              label: Text(isAllSelected ? 'Deselect All' : 'Select All'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.separated(
                                          itemCount: pois.length,
                                          separatorBuilder: (context, index) => const Divider(height: 1),
                                          itemBuilder: (context, index) {
                                            final poi = pois[index];
                                            final isSelected = selectedPoiIds.contains(poi.id);

                                            // REPLACED: ListTile with CheckboxListTile for multi-selection
                                            return CheckboxListTile(
                                              title: Text(poi.name),
                                              subtitle: Text(poi.address ?? 'No address'),
                                              value: isSelected,
                                              onChanged: (bool? checked) {
                                                setDialogState(() {
                                                  if (checked == true) {
                                                    selectedPoiIds.add(poi.id);
                                                  } else {
                                                    selectedPoiIds.remove(poi.id);
                                                  }
                                                });
                                              },
                                              controlAffinity: ListTileControlAffinity.leading,
                                              contentPadding: EdgeInsets.zero,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
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
                    // ADDED: The actual submit button that performs the batch insert
                    FilledButton(
                      onPressed: selectedPoiIds.isEmpty ? null : () async {
                        // We must fetch the actual POI models for the selected IDs to insert them
                        final currentPois = dialogRef.read(poisByRoiProvider(selectedRoiId!)).value ?? [];
                        final selectedPoiModels = currentPois.where((p) => selectedPoiIds.contains(p.id)).toList();
                        
                        final currentUserId = dialogRef.read(currentUserIdProvider);
                        final repository = dialogRef.read(timeChunkRepositoryProvider);
                        
                        final futures = selectedPoiModels.map((poi) {
                          final newChunk = TimeChunkModel(
                            id: const Uuid().v4(),
                            poiId: poi.id,
                            authorId: currentUserId,
                            date: null,
                            startTime: '10:00',
                            endTime: '12:00',
                            status: 'backlog',
                            createdAt: DateTime.now().millisecondsSinceEpoch,
                            isShared: false,
                          );
                          return repository.addTimeChunk(newChunk);
                        });

                        await Future.wait(futures);
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Add (${selectedPoiIds.length})'),
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

  Future<void> _showDurationEditDialog(
    BuildContext context,
    WidgetRef ref,
    TimeChunkModel targetChunk,
    List<TimeChunkModel> currentDayChunks,
  ) async {
    int selectedDuration = targetChunk.duration;
    final List<int> presetDurations = [15, 30, 45, 60, 90, 120, 180];

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adjust Duration'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current: $selectedDuration minutes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presetDurations.map((duration) {
                      return ChoiceChip(
                        label: Text('${duration}m'),
                        selected: selectedDuration == duration,
                        onSelected: (selected) {
                          if (selected) setState(() => selectedDuration = duration);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: selectedDuration.toDouble(),
                    min: 5,
                    max: 300,
                    divisions: 59,
                    label: '${selectedDuration}m',
                    onChanged: (value) {
                      setState(() => selectedDuration = value.toInt());
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Apply & Recalculate'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && selectedDuration != targetChunk.duration) {
      try {
        // Map the new duration to the specific chunk
        final updatedDayChunks = currentDayChunks.map((chunk) {
          if (chunk.id == targetChunk.id) {
            return chunk.copyWith(duration: selectedDuration);
          }
          return chunk;
        }).toList();

        // Feed updated list to the engine to cascade time changes
        final engine = ref.read(scheduleEngineProvider);
        await engine.recalculateDaySchedule(updatedDayChunks);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule updated based on new duration.')),
          );
        }
      } catch (e) {
        debugPrint('Failed to recalculate duration: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _showTransitEditDialog(
    BuildContext context,
    WidgetRef ref,
    TimeChunkModel targetChunk,
    List<TimeChunkModel> currentDayChunks,
  ) async {
    int selectedTransit = targetChunk.transitDuration;
    
    // Presets tailored for transit, including 0 for "next door"
    final List<int> presetDurations = [0, 15, 30, 45, 60, 90, 120];

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Adjust Transit Time'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current: $selectedTransit minutes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presetDurations.map((duration) {
                      return ChoiceChip(
                        label: Text('${duration}m'),
                        selected: selectedTransit == duration,
                        onSelected: (selected) {
                          if (selected) setState(() => selectedTransit = duration);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: selectedTransit.toDouble(),
                    min: 0,
                    max: 180, // Max 3 hours for transit
                    divisions: 36, // 5-minute increments
                    label: '${selectedTransit}m',
                    onChanged: (value) {
                      setState(() => selectedTransit = value.toInt());
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Apply & Recalculate'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && selectedTransit != targetChunk.transitDuration) {
      try {
        // Map the new transit duration to the target chunk
        final updatedDayChunks = currentDayChunks.map((chunk) {
          if (chunk.id == targetChunk.id) {
            return chunk.copyWith(transitDuration: selectedTransit);
          }
          return chunk;
        }).toList();

        // Pass the updated schedule to the cascading engine
        final engine = ref.read(scheduleEngineProvider);
        await engine.recalculateDaySchedule(updatedDayChunks);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule updated based on new transit time.')),
          );
        }
      } catch (e) {
        debugPrint('Failed to recalculate transit time: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  // ADDED: Feature A - Batch delete for scheduled chunks
  Future<void> _deleteSelectedScheduleChunks(List<TimeChunkModel> currentChunks) async {
    if (_selectedScheduleIds.isEmpty) return;

    try {
      final repository = ref.read(timeChunkRepositoryProvider);
      final engine = ref.read(scheduleEngineProvider);

      // 1. Execute batch deletion
      final futures = _selectedScheduleIds.map((id) => repository.deleteTimeChunk(id));
      await Future.wait(futures);

      // 2. Filter out the deleted chunks from the current day's list
      final remainingChunks = currentChunks
          .where((chunk) => !_selectedScheduleIds.contains(chunk.id))
          .toList();

      // 3. Trigger the cascading engine to close the time gaps
      await engine.recalculateDaySchedule(remainingChunks);

      // 4. Reset selection state
      setState(() {
        _isScheduleSelectionMode = false;
        _selectedScheduleIds.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected items deleted and schedule recalculated.')),
        );
      }
    } catch (e) {
      debugPrint('Failed to batch delete schedule chunks: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }
}