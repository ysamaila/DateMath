import '../models/custom_holiday.dart';

class BusinessDaysResult {
  final int businessDays;
  final int weekendDays;
  final int holidayDays;
  final int totalDays;
  final bool isReversed;

  const BusinessDaysResult({
    required this.businessDays,
    required this.weekendDays,
    required this.holidayDays,
    required this.totalDays,
    this.isReversed = false,
  });

  double get percentageWorking =>
      totalDays == 0 ? 0.0 : (businessDays / totalDays) * 100;
}

class AddBusinessDaysResult {
  final DateTime targetDate;
  final int daysAdded;
  final int weekendDaysSkipped;
  final int holidaysSkipped;
  final int calendarDaysSpanned;

  const AddBusinessDaysResult({
    required this.targetDate,
    required this.daysAdded,
    required this.weekendDaysSkipped,
    required this.holidaysSkipped,
    required this.calendarDaysSpanned,
  });
}

class WorkCalendarService {
  static const Set<int> defaultWeekendDays = {
    DateTime.saturday,
    DateTime.sunday,
  };

  const WorkCalendarService();

  BusinessDaysResult countBusinessDays({
    required DateTime start,
    required DateTime end,
    Set<int> weekendDays = defaultWeekendDays,
    List<CustomHoliday> holidays = const [],
    bool includeEndDate = true,
  }) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);

    final isReversed = s.isAfter(e);
    final from = isReversed ? e : s;
    final to = isReversed ? s : e;

    var currentDate = from;
    var businessDays = 0;
    var weekendCount = 0;
    var holidayCount = 0;
    var totalCount = 0;

    // If includeEndDate is false and from == to, range is empty (0 days)
    if (!includeEndDate && from.isAtSameMomentAs(to)) {
      return const BusinessDaysResult(
        businessDays: 0,
        weekendDays: 0,
        holidayDays: 0,
        totalDays: 0,
      );
    }

    final endLimit = includeEndDate ? to : to.subtract(const Duration(days: 1));

    while (!currentDate.isAfter(endLimit)) {
      totalCount++;
      final isWeekend = weekendDays.contains(currentDate.weekday);

      if (isWeekend) {
        weekendCount++;
      } else {
        final isHoliday = holidays.any((h) => h.matchesDate(currentDate));
        if (isHoliday) {
          holidayCount++;
        } else {
          businessDays++;
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return BusinessDaysResult(
      businessDays: businessDays,
      weekendDays: weekendCount,
      holidayDays: holidayCount,
      totalDays: totalCount,
      isReversed: isReversed,
    );
  }

  AddBusinessDaysResult addBusinessDays({
    required DateTime start,
    required int days,
    Set<int> weekendDays = defaultWeekendDays,
    List<CustomHoliday> holidays = const [],
  }) {
    var currentDate = DateTime(start.year, start.month, start.day);
    if (days == 0) {
      return AddBusinessDaysResult(
        targetDate: currentDate,
        daysAdded: 0,
        weekendDaysSkipped: 0,
        holidaysSkipped: 0,
        calendarDaysSpanned: 0,
      );
    }

    final direction = days > 0 ? 1 : -1;
    var remainingDays = days.abs();
    var weekendSkipped = 0;
    var holidaysSkipped = 0;
    var calendarDaysSpanned = 0;

    while (remainingDays > 0) {
      currentDate = currentDate.add(Duration(days: direction));
      calendarDaysSpanned++;

      final isWeekend = weekendDays.contains(currentDate.weekday);
      if (isWeekend) {
        weekendSkipped++;
        continue;
      }

      final isHoliday = holidays.any((h) => h.matchesDate(currentDate));
      if (isHoliday) {
        holidaysSkipped++;
        continue;
      }

      remainingDays--;
    }

    return AddBusinessDaysResult(
      targetDate: currentDate,
      daysAdded: days,
      weekendDaysSkipped: weekendSkipped,
      holidaysSkipped: holidaysSkipped,
      calendarDaysSpanned: calendarDaysSpanned,
    );
  }
}
