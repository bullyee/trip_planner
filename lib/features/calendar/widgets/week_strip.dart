import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeekStrip extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const WeekStrip({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Start of the week (Monday)
    final weekStart =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    return SizedBox(
      height: 80,
      child: Row(
        children: List.generate(7, (i) {
          final day = weekStart.add(Duration(days: i));
          final isSelected = day.year == selectedDate.year &&
              day.month == selectedDate.month &&
              day.day == selectedDate.day;
          final isToday = _isToday(day);

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
                        fontSize: 11,
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
                        fontSize: 18,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : isToday
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                      ),
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
