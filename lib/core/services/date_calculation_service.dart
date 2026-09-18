/// Pure Dart Date & Time calculation engine for DateMath.
/// Zero external UI dependencies, 100% offline.
class DateDifferenceResult {
  final int totalDays;
  final int totalWeeks;
  final int remainingDays;
  final int years;
  final int months;
  final int days;
  final bool isNegative;
  final bool isInclusive;

  const DateDifferenceResult({
    required this.totalDays,
    required this.totalWeeks,
    required this.remainingDays,
    required this.years,
    required this.months,
    required this.days,
    required this.isNegative,
    required this.isInclusive,
  });

  String get formattedBreakdown {
    final parts = <String>[];
    if (years > 0) parts.add('$years ${years == 1 ? "year" : "years"}');
    if (months > 0) parts.add('$months ${months == 1 ? "month" : "months"}');
    if (days > 0 || parts.isEmpty) {
      parts.add('$days ${days == 1 ? "day" : "days"}');
    }
    return parts.join(', ');
  }

  String get formattedWeeksDays {
    if (totalWeeks == 0) {
      return '$remainingDays ${remainingDays == 1 ? "day" : "days"}';
    }
    if (remainingDays == 0) {
      return '$totalWeeks ${totalWeeks == 1 ? "week" : "weeks"}';
    }
    return '$totalWeeks ${totalWeeks == 1 ? "week" : "weeks"}, $remainingDays ${remainingDays == 1 ? "day" : "days"}';
  }
}

class DateAddSubtractResult {
  final DateTime originalDate;
  final DateTime resultDate;
  final int yearsAdded;
  final int monthsAdded;
  final int weeksAdded;
  final int daysAdded;
  final bool isSubtract;

  const DateAddSubtractResult({
    required this.originalDate,
    required this.resultDate,
    required this.yearsAdded,
    required this.monthsAdded,
    required this.weeksAdded,
    required this.daysAdded,
    required this.isSubtract,
  });
}

class AgeResult {
  final int years;
  final int months;
  final int days;
  final int totalDaysLived;
  final int totalWeeksLived;
  final DateTime nextBirthday;
  final int daysToNextBirthday;
  final String nextBirthdayWeekday;
  final bool isBornOnLeapDay;

  const AgeResult({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDaysLived,
    required this.totalWeeksLived,
    required this.nextBirthday,
    required this.daysToNextBirthday,
    required this.nextBirthdayWeekday,
    required this.isBornOnLeapDay,
  });

  String get formattedAge {
    final parts = <String>[];
    parts.add('$years ${years == 1 ? "year" : "years"}');
    parts.add('$months ${months == 1 ? "month" : "months"}');
    parts.add('$days ${days == 1 ? "day" : "days"}');
    return parts.join(', ');
  }
}

class DayFinderResult {
  final DateTime date;
  final String weekdayName;
  final String monthName;
  final int dayOfMonth;
  final int year;
  final int dayOfYear;
  final int daysRemainingInYear;
  final int isoWeekNumber;
  final bool isLeapYear;
  final int quarter;

  const DayFinderResult({
    required this.date,
    required this.weekdayName,
    required this.monthName,
    required this.dayOfMonth,
    required this.year,
    required this.dayOfYear,
    required this.daysRemainingInYear,
    required this.isoWeekNumber,
    required this.isLeapYear,
    required this.quarter,
  });
}

class TodayOverviewResult {
  final DateTime date;
  final String formattedDate;
  final String weekdayName;
  final int dayOfYear;
  final int totalDaysInYear;
  final int daysRemainingInYear;
  final double percentageElapsed;
  final int quarter;
  final int isoWeekNumber;
  final bool isLeapYear;

  const TodayOverviewResult({
    required this.date,
    required this.formattedDate,
    required this.weekdayName,
    required this.dayOfYear,
    required this.totalDaysInYear,
    required this.daysRemainingInYear,
    required this.percentageElapsed,
    required this.quarter,
    required this.isoWeekNumber,
    required this.isLeapYear,
  });
}

class DateCalculationService {
  static const List<String> weekdayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Returns true if [year] is a leap year in the Gregorian calendar.
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Returns number of days in [month] for given [year].
  static int daysInMonth(int year, int month) {
    switch (month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      case 2:
        return isLeapYear(year) ? 29 : 28;
      default:
        throw ArgumentError('Month must be between 1 and 12');
    }
  }

  /// Strip hours/mins/secs to avoid DST or time offset calculation drift.
  static DateTime normalize(DateTime dt) {
    return DateTime.utc(dt.year, dt.month, dt.day);
  }

  /// Calculate the difference between [startDate] and [endDate].
  static DateDifferenceResult calculateDifference(
    DateTime startDate,
    DateTime endDate, {
    bool includeEndDate = false,
  }) {
    final d1 = normalize(startDate);
    final d2 = normalize(endDate);

    final isNegative = d1.isAfter(d2);
    final early = isNegative ? d2 : d1;
    var late = isNegative ? d1 : d2;

    if (includeEndDate) {
      late = late.add(const Duration(days: 1));
    }

    final totalDays = late.difference(early).inDays;
    final totalWeeks = totalDays ~/ 7;
    final remainingDays = totalDays % 7;

    // Exact years, months, days breakdown
    int years = late.year - early.year;
    int months = late.month - early.month;
    int days = late.day - early.day;

    if (days < 0) {
      months -= 1;
      int prevMonth = late.month - 1;
      int prevYear = late.year;
      if (prevMonth == 0) {
        prevMonth = 12;
        prevYear -= 1;
      }
      days += daysInMonth(prevYear, prevMonth);
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    return DateDifferenceResult(
      totalDays: isNegative ? -totalDays : totalDays,
      totalWeeks: totalWeeks,
      remainingDays: remainingDays,
      years: years,
      months: months,
      days: days,
      isNegative: isNegative,
      isInclusive: includeEndDate,
    );
  }

  /// Add or subtract years, months, weeks, days with calendar clamping.
  static DateAddSubtractResult addOrSubtractDate(
    DateTime baseDate, {
    int years = 0,
    int months = 0,
    int weeks = 0,
    int days = 0,
    bool isSubtract = false,
  }) {
    final normalized = normalize(baseDate);
    final multiplier = isSubtract ? -1 : 1;

    final targetMonthsTotal = (normalized.year * 12 + (normalized.month - 1)) +
        (years * 12 + months) * multiplier;

    final targetYear = targetMonthsTotal ~/ 12;
    final targetMonth = (targetMonthsTotal % 12) + 1;

    final maxDaysInTargetMonth = daysInMonth(targetYear, targetMonth);
    final targetDay = normalized.day > maxDaysInTargetMonth
        ? maxDaysInTargetMonth
        : normalized.day;

    var result = DateTime.utc(targetYear, targetMonth, targetDay);

    final totalDaysOffset = ((weeks * 7) + days) * multiplier;
    result = result.add(Duration(days: totalDaysOffset));

    return DateAddSubtractResult(
      originalDate: normalized,
      resultDate: result,
      yearsAdded: years,
      monthsAdded: months,
      weeksAdded: weeks,
      daysAdded: days,
      isSubtract: isSubtract,
    );
  }

  /// Calculate exact age as of [asOf] (defaults to current date).
  static AgeResult calculateAge(
    DateTime birthDate, {
    DateTime? asOf,
  }) {
    final b = normalize(birthDate);
    final now = normalize(asOf ?? DateTime.now());

    if (b.isAfter(now)) {
      return AgeResult(
        years: 0,
        months: 0,
        days: 0,
        totalDaysLived: 0,
        totalWeeksLived: 0,
        nextBirthday: b,
        daysToNextBirthday: b.difference(now).inDays,
        nextBirthdayWeekday: weekdayNames[b.weekday - 1],
        isBornOnLeapDay: b.month == 2 && b.day == 29,
      );
    }

    int years = now.year - b.year;
    int months = now.month - b.month;
    int days = now.day - b.day;

    if (days < 0) {
      months -= 1;
      int prevMonth = now.month - 1;
      int prevYear = now.year;
      if (prevMonth == 0) {
        prevMonth = 12;
        prevYear -= 1;
      }
      days += daysInMonth(prevYear, prevMonth);
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    final totalDaysLived = now.difference(b).inDays;
    final totalWeeksLived = totalDaysLived ~/ 7;
    final isBornOnLeapDay = b.month == 2 && b.day == 29;

    // Calculate next birthday
    DateTime candidate;
    if (isBornOnLeapDay && !isLeapYear(now.year)) {
      // In non-leap year, celebrate on Feb 28
      candidate = DateTime.utc(now.year, 2, 28);
    } else {
      candidate = DateTime.utc(now.year, b.month, b.day);
    }

    DateTime nextBirthday;
    if (candidate.isBefore(now)) {
      // Already passed this year, so next year
      final nextYear = now.year + 1;
      if (isBornOnLeapDay && !isLeapYear(nextYear)) {
        nextBirthday = DateTime.utc(nextYear, 2, 28);
      } else {
        nextBirthday = DateTime.utc(nextYear, b.month, b.day);
      }
    } else {
      nextBirthday = candidate;
    }

    final daysToNextBirthday = nextBirthday.difference(now).inDays;
    final nextBirthdayWeekday = weekdayNames[nextBirthday.weekday - 1];

    return AgeResult(
      years: years,
      months: months,
      days: days,
      totalDaysLived: totalDaysLived,
      totalWeeksLived: totalWeeksLived,
      nextBirthday: nextBirthday,
      daysToNextBirthday: daysToNextBirthday,
      nextBirthdayWeekday: nextBirthdayWeekday,
      isBornOnLeapDay: isBornOnLeapDay,
    );
  }

  /// ISO 8601 week number calculation.
  static int isoWeekNumber(DateTime date) {
    final d = normalize(date);
    final wDay = d.weekday; // 1 = Mon, 7 = Sun
    // Thursday in current week determines the year
    final thursday = d.add(Duration(days: 4 - wDay));
    final jan1 = DateTime.utc(thursday.year, 1, 1);
    final days = thursday.difference(jan1).inDays;
    return (days ~/ 7) + 1;
  }

  /// Day Finder details for any given [date].
  static DayFinderResult findDayDetails(DateTime date) {
    final d = normalize(date);
    final weekdayName = weekdayNames[d.weekday - 1];
    final monthName = monthNames[d.month - 1];
    final leap = isLeapYear(d.year);

    final jan1 = DateTime.utc(d.year, 1, 1);
    final dayOfYear = d.difference(jan1).inDays + 1;
    final totalDaysInYear = leap ? 366 : 365;
    final daysRemaining = totalDaysInYear - dayOfYear;
    final weekNumber = isoWeekNumber(d);
    final quarter = ((d.month - 1) ~/ 3) + 1;

    return DayFinderResult(
      date: d,
      weekdayName: weekdayName,
      monthName: monthName,
      dayOfMonth: d.day,
      year: d.year,
      dayOfYear: dayOfYear,
      daysRemainingInYear: daysRemaining,
      isoWeekNumber: weekNumber,
      isLeapYear: leap,
      quarter: quarter,
    );
  }

  /// Today Overview details.
  static TodayOverviewResult getTodayOverview({DateTime? date}) {
    final now = normalize(date ?? DateTime.now());
    final leap = isLeapYear(now.year);
    final totalDaysInYear = leap ? 366 : 365;

    final jan1 = DateTime.utc(now.year, 1, 1);
    final dayOfYear = now.difference(jan1).inDays + 1;
    final daysRemaining = totalDaysInYear - dayOfYear;
    final percentage = (dayOfYear / totalDaysInYear) * 100;
    final weekNumber = isoWeekNumber(now);
    final quarter = ((now.month - 1) ~/ 3) + 1;
    final weekdayName = weekdayNames[now.weekday - 1];

    final formatted =
        '$weekdayName, ${monthNames[now.month - 1]} ${now.day}, ${now.year}';

    return TodayOverviewResult(
      date: now,
      formattedDate: formatted,
      weekdayName: weekdayName,
      dayOfYear: dayOfYear,
      totalDaysInYear: totalDaysInYear,
      daysRemainingInYear: daysRemaining,
      percentageElapsed: percentage,
      quarter: quarter,
      isoWeekNumber: weekNumber,
      isLeapYear: leap,
    );
  }
}
