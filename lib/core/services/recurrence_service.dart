enum RecurrenceFrequency {
  daily,
  weekly,
  monthlyByDay,
  monthlyByWeekday,
  yearly,
}

class RecurrencePattern {
  final RecurrenceFrequency frequency;
  final int interval;
  final Set<int> weekdays;
  final int? dayOfMonth;
  final int? monthlyOrdinal; // 1, 2, 3, 4, or -1 for last
  final int? monthlyWeekday; // DateTime.monday .. DateTime.sunday

  const RecurrencePattern({
    required this.frequency,
    this.interval = 1,
    this.weekdays = const {DateTime.monday},
    this.dayOfMonth,
    this.monthlyOrdinal,
    this.monthlyWeekday,
  });
}

class OccurrenceItem {
  final int index;
  final DateTime date;
  final int daysFromStart;
  final int daysFromToday;

  const OccurrenceItem({
    required this.index,
    required this.date,
    required this.daysFromStart,
    required this.daysFromToday,
  });
}

class RecurrenceService {
  const RecurrenceService();

  List<OccurrenceItem> generateOccurrences({
    required DateTime startDate,
    required RecurrencePattern pattern,
    int count = 10,
    DateTime? untilDate,
    DateTime? currentDate,
  }) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final now = currentDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final limitDate = untilDate != null
        ? DateTime(untilDate.year, untilDate.month, untilDate.day)
        : null;

    final dates = <DateTime>[];

    switch (pattern.frequency) {
      case RecurrenceFrequency.daily:
        var cur = start;
        while (dates.length < count &&
            (limitDate == null || !cur.isAfter(limitDate))) {
          dates.add(cur);
          cur = cur.add(Duration(days: pattern.interval));
        }
        break;

      case RecurrenceFrequency.weekly:
        var curWeekStart = _getWeekStart(start);
        var curDate = start;
        final sortedWeekdays = pattern.weekdays.toList()..sort();

        // Continue generating until count reached or limit exceeded
        while (dates.length < count &&
            (limitDate == null || !curDate.isAfter(limitDate))) {
          for (final wd in sortedWeekdays) {
            final candidate = curWeekStart.add(Duration(days: wd - 1));
            if (!candidate.isBefore(start)) {
              if (limitDate != null && candidate.isAfter(limitDate)) {
                break;
              }
              dates.add(candidate);
              if (dates.length >= count) break;
            }
          }
          curWeekStart = curWeekStart.add(Duration(days: 7 * pattern.interval));
          curDate = curWeekStart;
        }
        break;

      case RecurrenceFrequency.monthlyByDay:
        final targetDay = pattern.dayOfMonth ?? start.day;
        var curYear = start.year;
        var curMonth = start.month;

        while (dates.length < count) {
          final maxDay = _daysInMonth(curYear, curMonth);
          final clampedDay = targetDay > maxDay ? maxDay : targetDay;
          final candidate = DateTime(curYear, curMonth, clampedDay);

          if (!candidate.isBefore(start)) {
            if (limitDate != null && candidate.isAfter(limitDate)) break;
            dates.add(candidate);
          }

          curMonth += pattern.interval;
          while (curMonth > 12) {
            curMonth -= 12;
            curYear++;
          }
        }
        break;

      case RecurrenceFrequency.monthlyByWeekday:
        final ordinal = pattern.monthlyOrdinal ?? 1;
        final targetWeekday = pattern.monthlyWeekday ?? DateTime.monday;
        var curYear = start.year;
        var curMonth = start.month;

        while (dates.length < count) {
          final candidate = _getNthOrLastWeekday(
              curYear, curMonth, targetWeekday, ordinal);

          if (!candidate.isBefore(start)) {
            if (limitDate != null && candidate.isAfter(limitDate)) break;
            dates.add(candidate);
          }

          curMonth += pattern.interval;
          while (curMonth > 12) {
            curMonth -= 12;
            curYear++;
          }
        }
        break;

      case RecurrenceFrequency.yearly:
        var curYear = start.year;
        final month = start.month;
        final day = start.day;

        while (dates.length < count) {
          final maxDay = _daysInMonth(curYear, month);
          final clampedDay = day > maxDay ? maxDay : day;
          final candidate = DateTime(curYear, month, clampedDay);

          if (!candidate.isBefore(start)) {
            if (limitDate != null && candidate.isAfter(limitDate)) break;
            dates.add(candidate);
          }

          curYear += pattern.interval;
        }
        break;
    }

    return dates
        .asMap()
        .entries
        .map((entry) => OccurrenceItem(
              index: entry.key + 1,
              date: entry.value,
              daysFromStart: entry.value.difference(start).inDays,
              daysFromToday: entry.value.difference(today).inDays,
            ))
        .toList();
  }

  static DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static DateTime _getNthOrLastWeekday(
      int year, int month, int targetWeekday, int ordinal) {
    if (ordinal == -1) {
      // Last weekday
      var date = DateTime(year, month + 1, 0);
      while (date.month == month) {
        if (date.weekday == targetWeekday) return date;
        date = date.subtract(const Duration(days: 1));
      }
      return DateTime(year, month, 1);
    } else {
      var date = DateTime(year, month, 1);
      var count = 0;
      while (date.month == month) {
        if (date.weekday == targetWeekday) {
          count++;
          if (count == ordinal) return date;
        }
        date = date.add(const Duration(days: 1));
      }
      return DateTime(year, month, 1);
    }
  }
}
