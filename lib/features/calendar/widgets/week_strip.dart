import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/calendar_provider.dart';

class WeekStrip extends ConsumerWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const WeekStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    // Start of the week (Monday)
    final weekStart =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    return SizedBox(
      height: 88,
      child: Row(
        children: List.generate(7, (i) {
          final day = weekStart.add(Duration(days: i));
          final isSelected = day.year == selectedDate.year &&
              day.month == selectedDate.month &&
              day.day == selectedDate.day;
          final isToday = _isToday(day);

          final dateStr = DateFormat('yyyy-MM-dd').format(day);
          final chunksAsync = ref.watch(timeChunksByDateProvider(dateStr));

          // determine dot colors based on chunks: show multiple small dots for different statuses
          final statuses = chunksAsync.maybeWhen(
            data: (chunks) => chunks.map((c) => c.status).toSet(),
            orElse: () => <String>{},
          );

          final List<Color> dotColors = [];
          if (statuses.contains('scheduled')) dotColors.add(Colors.blue);
          if (statuses.contains('completed')) dotColors.add(Colors.green);
          if (statuses.contains('skipped')) dotColors.add(Colors.orange);
          // fallback: if there are chunks but none of the above, show backlog grey
          if (dotColors.isEmpty && statuses.isNotEmpty) dotColors.add(Colors.grey);

          return Expanded(
            child: GestureDetector(
              onTap: () => onDateSelected(day),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : isToday
                          ? theme.colorScheme.primaryContainer
                          : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E').format(day).substring(0, 2),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : isToday
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (dotColors.isNotEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: dotColors
                            .map((c) => Container(
                                  width: 6,
                                  height: 6,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                  ),
                                ))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }
}
