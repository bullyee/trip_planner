import 'package:flutter_test/flutter_test.dart';

List<DateTime> buildMonthCalendarDays(DateTime monthYear) {
  final firstDay = DateTime(monthYear.year, monthYear.month, 1);
  final lastDay = DateTime(monthYear.year, monthYear.month + 1, 0);
  final startWeekday = firstDay.weekday % 7;

  final days = <DateTime>[];
  for (int i = startWeekday; i > 0; i--) {
    days.add(DateTime(monthYear.year, monthYear.month, 1 - i));
  }
  for (int i = 1; i <= lastDay.day; i++) {
    days.add(DateTime(monthYear.year, monthYear.month, i));
  }
  var trailingDay = 1;
  while (days.length % 7 != 0) {
    days.add(DateTime(monthYear.year, monthYear.month + 1, trailingDay++));
  }
  return days;
}

void main() {
  group('Month Calendar Grid Generation (#20)', () {
    test('May 2026 (starts on Friday, 5 leading days) trailing days start at 1', () {
      final days = buildMonthCalendarDays(DateTime(2026, 5));

      expect(days.length % 7, 0);
      // May 2026 has 31 days + 5 leading days = 36 days -> needs 6 trailing days to reach 42
      final trailingDays = days.where((d) => d.month == 6).toList();
      expect(trailingDays.length, 6);
      expect(trailingDays.map((d) => d.day).toList(), [1, 2, 3, 4, 5, 6]);
    });

    test('February 2026 (starts on Sunday, 0 leading days, 28 days) has 0 trailing days', () {
      final days = buildMonthCalendarDays(DateTime(2026, 2));

      expect(days.length, 28);
      expect(days.length % 7, 0);
      expect(days.every((d) => d.month == 2), isTrue);
    });

    test('October 2026 (starts on Thursday, 4 leading days) trailing days start at 1', () {
      final days = buildMonthCalendarDays(DateTime(2026, 10));

      expect(days.length % 7, 0);
      // Oct 2026 has 31 days + 4 leading days = 35 days -> exactly 35, 0 trailing days
      final trailingDays = days.where((d) => d.month == 11).toList();
      expect(trailingDays.isEmpty, isTrue);
    });

    test('August 2026 (starts on Saturday, 6 leading days) trailing days start at 1', () {
      final days = buildMonthCalendarDays(DateTime(2026, 8));

      expect(days.length % 7, 0);
      // Aug 2026: 31 days + 6 leading days = 37 days -> needs 5 trailing days to reach 42
      final trailingDays = days.where((d) => d.month == 9).toList();
      expect(trailingDays.length, 5);
      expect(trailingDays.map((d) => d.day).toList(), [1, 2, 3, 4, 5]);
    });
  });
}

