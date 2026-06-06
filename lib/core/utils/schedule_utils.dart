import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../features/calendar/models/time_chunk_model.dart';
import '../../features/calendar/providers/calendar_provider.dart';
import '../../features/calendar/repositories/time_chunk_repository.dart';

Future<void> handleTimeChunkAction(BuildContext context, WidgetRef ref, String action, TimeChunkModel chunk) async {
  switch (action) {
    case 'delete':
      await confirmDeleteTimeChunkAndRemove(context, ref, chunk);
      break;
    case 'edit':
      showScheduleEditDialog(context, ref, chunk);
      break;
    case 'scheduled':
    case 'completed':
    case 'skipped':
      final updatedChunk = TimeChunkModel(
        id: chunk.id,
        poiId: chunk.poiId,
        date: chunk.date,
        startTime: chunk.startTime,
        endTime: chunk.endTime,
        status: action,
        createdAt: chunk.createdAt,
        isShared: chunk.isShared,
      );
      await ref.read(timeChunkRepositoryProvider).updateTimeChunk(updatedChunk);
      break;
    case 'backlog':
      final backlogChunk = TimeChunkModel(
        id: chunk.id,
        poiId: chunk.poiId,
        date: null,
        startTime: null,
        endTime: null,
        status: action,
        createdAt: chunk.createdAt,
        isShared: chunk.isShared,
      );
      await ref.read(timeChunkRepositoryProvider).updateTimeChunk(backlogChunk);
      break;
  }
}

void showScheduleEditDialog(
  BuildContext context, WidgetRef ref, TimeChunkModel chunk) {
DateTime? selectedDate = chunk.date != null 
  ? DateFormat('yyyy-MM-dd').parse(chunk.date!) 
  : DateTime.now();
final startController = TextEditingController(text: chunk.startTime ?? '10:00');
final endController = TextEditingController(text: chunk.endTime ?? '12:00');

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('Edit Time Slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(selectedDate != null
                  ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                  : 'Select Date'),
              onTap: () async {
                final picked = await showMonthCalendarPicker(
                  context: ctx,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(DateTime.now().year - 10),
                  lastDate: DateTime(DateTime.now().year + 10),
                );
                if (picked != null) {
                  setDialogState(() => selectedDate = picked);
                }
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startController,
                    decoration:
                        const InputDecoration(labelText: 'Start'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: endController,
                    decoration:
                        const InputDecoration(labelText: 'End'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final updatedChunk = TimeChunkModel(
                id: chunk.id,
                poiId: chunk.poiId,
                date: chunk.date, 
                startTime: chunk.startTime, 
                endTime: chunk.endTime, 
                status: 'scheduled', 
                createdAt: chunk.createdAt,
                isShared: chunk.isShared,
              );
              await ref.read(timeChunkRepositoryProvider).updateTimeChunk(updatedChunk);
              if (!context.mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    ),
  );
}

Future<void> confirmDeleteTimeChunkAndRemove(
    BuildContext context, WidgetRef ref, TimeChunkModel chunk) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Schedule?'),
      content: const Text('This will permanently delete the schedule entry.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirm == true) {
    await _deleteChunk(ref, chunk);
  }
}

Future<void> _deleteChunk(WidgetRef ref, TimeChunkModel chunk) async {
  await ref.read(timeChunkRepositoryProvider).deleteTimeChunk(chunk.id);
}

class MonthCalendarPicker extends ConsumerStatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onDateSelected;

  const MonthCalendarPicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  });
  @override
  ConsumerState<MonthCalendarPicker> createState() => _MonthCalendarPickerState();
}

class _MonthCalendarPickerState extends ConsumerState<MonthCalendarPicker> {
  late DateTime monthYear;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    monthYear = DateTime(widget.initialDate.year, widget.initialDate.month);
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month/year selector and calendar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Month/year selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        final prev = DateTime(monthYear.year, monthYear.month - 1);
                        if (prev.isAfter(widget.firstDate) || prev.isAtSameMomentAs(widget.firstDate)) {
                          setState(() {
                            monthYear = prev;
                          });
                        }
                      },
                    ),
                    GestureDetector(
                      onTap: () => _showMonthYearPicker(),
                      child: Row(
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(monthYear),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        final next = DateTime(monthYear.year, monthYear.month + 1);
                        if (next.isBefore(widget.lastDate) || next.isAtSameMomentAs(widget.lastDate)) {
                          setState(() {
                            monthYear = next;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Day header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                      .map(
                        (day) => SizedBox(
                          width: 36,
                          child: Center(
                            child: Text(
                              day,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                // Calendar grid
                _buildCalendarGrid(
                  context,
                  ref,
                  monthYear,
                  (d) => setState(() => selectedDate = d),
                ),
              ],
            ),
          ),
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    try {
                      widget.onDateSelected(selectedDate);
                    } catch (_) {}
                    Navigator.of(context).pop(selectedDate);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    BuildContext context,
    WidgetRef ref,
    DateTime monthYear,
    void Function(DateTime) onSelect,
  ) {
    final theme = Theme.of(context);
    // Get first day of month and calculate start day (Sunday = 0 for Material Design)
    final firstDay = DateTime(monthYear.year, monthYear.month, 1);
    final lastDay =
        DateTime(monthYear.year, monthYear.month + 1, 0); // Last day of month
    final startWeekday =
        firstDay.weekday % 7; // Convert to Sunday = 0, Monday = 1, etc.

    final days = <DateTime>[];
    // Add leading empty days
    for (int i = startWeekday; i > 0; i--) {
      days.add(DateTime(monthYear.year, monthYear.month, 1 - i));
    }
    // Add month days
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(monthYear.year, monthYear.month, i));
    }
    // Add trailing empty days to complete grid
    while (days.length % 7 != 0) {
      days.add(DateTime(monthYear.year, monthYear.month + 1, days.length - 28));
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.1,
        mainAxisSpacing: 8,
        crossAxisSpacing: 4,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isCurrentMonth =
            day.year == monthYear.year && day.month == monthYear.month;
        final isSelected = day.year == selectedDate.year &&
          day.month == selectedDate.month &&
          day.day == selectedDate.day;
        final isToday = _isToday(day);

        final dateStr = DateFormat('yyyy-MM-dd').format(day);
        final chunksAsync = ref.watch(timeChunksByDateProvider(dateStr));

        // Determine dot colors
        final statuses = chunksAsync.maybeWhen(
          data: (chunks) => chunks.map((c) => c.status).toSet(),
          orElse: () => <String>{},
        );

        final List<Color> dotColors = [];
        if (statuses.contains('scheduled')) dotColors.add(Colors.blue);
        if (statuses.contains('completed')) dotColors.add(Colors.green);
        if (statuses.contains('skipped')) dotColors.add(Colors.orange);
        if (dotColors.isEmpty && statuses.isNotEmpty) dotColors.add(Colors.grey);

        return GestureDetector(
          onTap: isCurrentMonth
              ? () {
                  onSelect(day);
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : isToday
                      ? theme.colorScheme.primaryContainer
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : isCurrentMonth
                                ? (isToday
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface)
                                : theme.colorScheme.outlineVariant,
                      ),
                    ),
                ),
                ),
                if (isCurrentMonth && dotColors.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: dotColors
                          .map((c) => Container(
                                    width: 4,
                                    height: 4,
                                    margin:
                                        const EdgeInsets.symmetric(horizontal: 1),
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                    ),
                                  ))
                          .toList(),
                    ),
                  )
                else if (isCurrentMonth)
                  const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }

  void _showMonthYearPicker() {
    final theme = Theme.of(context);
    int selectedYear = monthYear.year;
    int selectedMonth = monthYear.month;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          content: SizedBox(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Year and Month selectors side by side
                Row(
                  children: [
                    // Year selector
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Year',
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            isExpanded: true,
                            value: selectedYear,
                            items: List.generate(
                              widget.lastDate.year - widget.firstDate.year + 1,
                              (i) => widget.firstDate.year + i,
                            )
                                .map((year) => DropdownMenuItem(
                                      value: year,
                                      child: Text('$year'),
                                    ))
                                .toList(),
                            onChanged: (year) {
                              if (year != null) {
                                setDialogState(() {
                                  selectedYear = year;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Month selector
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Month',
                            style: theme.textTheme.labelMedium,
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            isExpanded: true,
                            value: selectedMonth,
                            items: List.generate(12, (i) => i + 1)
                                .map((month) => DropdownMenuItem(
                                      value: month,
                                      child: Text('$month'),
                                    ))
                                .toList(),
                            onChanged: (month) {
                              if (month != null) {
                                setDialogState(() {
                                  selectedMonth = month;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newDate = DateTime(selectedYear, selectedMonth);
                // Ensure within range
                if ((newDate.isAfter(widget.firstDate) || newDate.isAtSameMomentAs(widget.firstDate)) &&
                    (newDate.isBefore(widget.lastDate) || newDate.isAtSameMomentAs(widget.lastDate))) {
                  setState(() {
                    monthYear = newDate;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show custom month calendar picker dialog
Future<DateTime?> showMonthCalendarPicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final result = await showDialog<DateTime>(
    context: context,
    builder: (context) => MonthCalendarPicker(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      onDateSelected: (_) {}, // Handled by OK button in dialog
    ),
  );
  return result;
}
