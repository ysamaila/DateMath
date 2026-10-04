import 'dart:math' as math;

/// Discrete lunar phases of the synodic cycle.
enum MoonPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

/// Metadata and upcoming timing for a primary moon phase.
class NextMoonPhase {
  final MoonPhase phase;
  final String name;
  final DateTime targetDate;
  final int daysAway;

  const NextMoonPhase({
    required this.phase,
    required this.name,
    required this.targetDate,
    required this.daysAway,
  });
}

/// Detailed calculation result for a lunar observation.
class MoonPhaseInfo {
  final MoonPhase phase;
  final String name;
  final double fraction; // 0.0 to 1.0 through synodic cycle
  final double illuminationPercentage; // 0.0% to 100.0%
  final double ageInDays; // 0.0 to 29.53
  final bool isWaxing;
  final List<NextMoonPhase> upcomingPhases;

  const MoonPhaseInfo({
    required this.phase,
    required this.name,
    required this.fraction,
    required this.illuminationPercentage,
    required this.ageInDays,
    required this.isWaxing,
    required this.upcomingPhases,
  });
}

/// Solar cardinal event types.
enum SolarEventType {
  vernalEquinox,
  summerSolstice,
  autumnalEquinox,
  winterSolstice,
}

/// Seasonal equinox or solstice event.
class SolarEvent {
  final SolarEventType type;
  final String name;
  final String northernHemisphereSeason;
  final String southernHemisphereSeason;
  final DateTime utcDateTime;
  final DateTime localDateTime;
  final bool isPast;
  final int daysDifference;

  const SolarEvent({
    required this.type,
    required this.name,
    required this.northernHemisphereSeason,
    required this.southernHemisphereSeason,
    required this.utcDateTime,
    required this.localDateTime,
    required this.isPast,
    required this.daysDifference,
  });
}

/// Julian date and day-of-year calculation results.
class JulianDateResult {
  final double julianDate;
  final double modifiedJulianDate;
  final int julianDayNumber;
  final int dayOfYear;
  final int totalDaysInYear;
  final int daysRemaining;
  final double yearProgressPercentage;

  const JulianDateResult({
    required this.julianDate,
    required this.modifiedJulianDate,
    required this.julianDayNumber,
    required this.dayOfYear,
    required this.totalDaysInYear,
    required this.daysRemaining,
    required this.yearProgressPercentage,
  });
}

/// Milestone in the annual calendar progress.
class DayOfYearMilestone {
  final String label;
  final int dayNumber;
  final DateTime date;
  final bool isReached;
  final int daysAway;

  const DayOfYearMilestone({
    required this.label,
    required this.dayNumber,
    required this.date,
    required this.isReached,
    required this.daysAway,
  });
}

/// Pure Dart astronomical calculation engine.
/// 100% offline, zero network dependencies, based on standard Meeus algorithms.
class AstronomicalService {
  static const double synodicMonth = 29.530588853; // Average length of lunar cycle in days

  /// Converts a [DateTime] to standard Julian Date (JD).
  static double toJulianDate(DateTime dt) {
    final utc = dt.toUtc();
    int y = utc.year;
    int m = utc.month;
    final double dayFraction = utc.day +
        (utc.hour / 24.0) +
        (utc.minute / 1440.0) +
        (utc.second / 86400.0) +
        (utc.millisecond / 86400000.0);

    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();

    final jd = (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        dayFraction +
        b -
        1524.5;
    return jd;
  }

  /// Converts standard Julian Date (JD) back to a UTC [DateTime].
  static DateTime fromJulianDate(double jd) {
    final double z = (jd + 0.5).floorToDouble();
    final double f = (jd + 0.5) - z;

    double a = z;
    if (z >= 2299161) {
      final double alpha = ((z - 1867216.25) / 36524.25).floorToDouble();
      a = z + 1 + alpha - (alpha / 4).floorToDouble();
    }

    final double b = a + 1524;
    final double c = ((b - 122.1) / 365.25).floorToDouble();
    final double d = (365.25 * c).floorToDouble();
    final double e = ((b - d) / 30.6001).floorToDouble();

    final double dayFraction = b - d - (30.6001 * e).floorToDouble() + f;
    final int day = dayFraction.floor();
    final double dayRemainder = dayFraction - day;

    final int month = (e < 14) ? (e - 1).toInt() : (e - 13).toInt();
    final int year = (month > 2) ? (c - 4716).toInt() : (c - 4715).toInt();

    final totalSeconds = (dayRemainder * 86400).round();
    final int hour = (totalSeconds ~/ 3600).clamp(0, 23);
    final int minute = ((totalSeconds % 3600) ~/ 60).clamp(0, 59);
    final int second = (totalSeconds % 60).clamp(0, 59);

    return DateTime.utc(year, month, day, hour, minute, second);
  }

  /// Calculates Julian Date, Modified Julian Date, and Day of Year progress.
  static JulianDateResult calculateJulianDate(DateTime dateTime) {
    final jd = toJulianDate(dateTime);
    final mjd = jd - 2400000.5;
    final jdn = (jd + 0.5).floor();

    final isLeapYear = (dateTime.year % 4 == 0 && dateTime.year % 100 != 0) ||
        (dateTime.year % 400 == 0);
    final totalDays = isLeapYear ? 366 : 365;

    final startOfYear = DateTime(dateTime.year, 1, 1);
    final dayOfYear = dateTime.difference(startOfYear).inDays + 1;
    final daysRemaining = totalDays - dayOfYear;
    final progress = (dayOfYear / totalDays) * 100.0;

    return JulianDateResult(
      julianDate: jd,
      modifiedJulianDate: mjd,
      julianDayNumber: jdn,
      dayOfYear: dayOfYear,
      totalDaysInYear: totalDays,
      daysRemaining: daysRemaining,
      yearProgressPercentage: progress,
    );
  }

  /// Generates the day-of-year milestones for any given calendar year.
  static List<DayOfYearMilestone> getDayOfYearMilestones(
    int year, {
    DateTime? referenceNow,
  }) {
    final now = referenceNow ?? DateTime.now();
    final isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    final totalDays = isLeapYear ? 366 : 365;
    final midYearDay = isLeapYear ? 183 : 182;

    final rawMilestones = <(String, int)>[
      ('Day 50 Milestone', 50),
      ('End of Q1', isLeapYear ? 91 : 90),
      ('Day 100 Milestone', 100),
      ('Day 150 Milestone', 150),
      ('Mid-Year Point (50%)', midYearDay),
      ('End of Q2 (Halfway)', isLeapYear ? 182 : 181),
      ('Day 200 Milestone', 200),
      ('Day 250 Milestone', 250),
      ('100 Days Left in Year', totalDays - 100),
      ('End of Q3', isLeapYear ? 274 : 273),
      ('Day 300 Milestone', 300),
      ('Day 350 Milestone', 350),
      ('End of Year (Day $totalDays)', totalDays),
    ];

    // Deduplicate and sort by day number
    final unique = <int, String>{};
    for (final m in rawMilestones) {
      if (m.$2 <= totalDays) {
        unique[m.$2] = m.$1;
      }
    }

    final sortedDays = unique.keys.toList()..sort();

    return sortedDays.map((dayNum) {
      final date = DateTime.utc(year, 1, 1).add(Duration(days: dayNum - 1));
      final compareDate = DateTime.utc(now.year, now.month, now.day);
      final isReached = compareDate.isAfter(date) || compareDate.isAtSameMomentAs(date);
      final daysAway = date.difference(compareDate).inDays.abs();

      return DayOfYearMilestone(
        label: unique[dayNum]!,
        dayNumber: dayNum,
        date: date,
        isReached: isReached,
        daysAway: daysAway,
      );
    }).toList();
  }

  /// Calculates moon phase parameters and upcoming primary phases.
  static MoonPhaseInfo calculateMoonPhase(DateTime date) {
    final jd = toJulianDate(date);

    // Reference epoch: 2000-01-06 18:14 UTC (Known New Moon)
    // JD = 2451550.259722
    const double referenceNewMoonJd = 2451550.259722;
    final double elapsedDays = jd - referenceNewMoonJd;
    final double cycles = elapsedDays / synodicMonth;
    final double fraction = cycles - cycles.floorToDouble();
    final double ageInDays = fraction * synodicMonth;

    // Geometric phase angle theta = 2 * pi * fraction
    final double phaseAngle = 2 * math.pi * fraction;
    // Illumination: 0.5 * (1 - cos(phaseAngle))
    final double illuminationFraction = 0.5 * (1 - math.cos(phaseAngle));
    final double illuminationPercentage = illuminationFraction * 100.0;

    final isWaxing = fraction < 0.5;

    // Categorize into 8 discrete phases
    final MoonPhase phase;
    final String name;

    if (fraction < 0.03 || fraction >= 0.97) {
      phase = MoonPhase.newMoon;
      name = 'New Moon';
    } else if (fraction < 0.22) {
      phase = MoonPhase.waxingCrescent;
      name = 'Waxing Crescent';
    } else if (fraction < 0.28) {
      phase = MoonPhase.firstQuarter;
      name = 'First Quarter';
    } else if (fraction < 0.47) {
      phase = MoonPhase.waxingGibbous;
      name = 'Waxing Gibbous';
    } else if (fraction < 0.53) {
      phase = MoonPhase.fullMoon;
      name = 'Full Moon';
    } else if (fraction < 0.72) {
      phase = MoonPhase.waningGibbous;
      name = 'Waning Gibbous';
    } else if (fraction < 0.78) {
      phase = MoonPhase.lastQuarter;
      name = 'Last Quarter';
    } else {
      phase = MoonPhase.waningCrescent;
      name = 'Waning Crescent';
    }

    // Calculate next 4 primary phases (New, First Quarter, Full, Last Quarter)
    final primaryTargets = <(MoonPhase, String, double)>[
      (MoonPhase.newMoon, 'New Moon', 0.0),
      (MoonPhase.firstQuarter, 'First Quarter', 0.25),
      (MoonPhase.fullMoon, 'Full Moon', 0.5),
      (MoonPhase.lastQuarter, 'Last Quarter', 0.75),
    ];

    final upcoming = <NextMoonPhase>[];
    for (final target in primaryTargets) {
      double diff = target.$3 - fraction;
      if (diff <= 0.001) {
        diff += 1.0;
      }
      final double daysUntil = diff * synodicMonth;
      final targetDate = date.add(Duration(
        seconds: (daysUntil * 86400).round(),
      ));
      final daysAway = targetDate.difference(date).inDays;

      upcoming.add(NextMoonPhase(
        phase: target.$1,
        name: target.$2,
        targetDate: targetDate,
        daysAway: daysAway,
      ));
    }

    // Sort upcoming phases by date
    upcoming.sort((a, b) => a.targetDate.compareTo(b.targetDate));

    return MoonPhaseInfo(
      phase: phase,
      name: name,
      fraction: fraction,
      illuminationPercentage: illuminationPercentage,
      ageInDays: ageInDays,
      isWaxing: isWaxing,
      upcomingPhases: upcoming,
    );
  }

  /// Calculates the 4 cardinal solar events (Equinoxes & Solstices) for [year].
  /// Utilizes Jean Meeus Chapter 27 truncated polynomial approximations.
  static List<SolarEvent> calculateSolarEvents(
    int year, {
    DateTime? referenceNow,
  }) {
    final now = referenceNow ?? DateTime.now();
    final double m = (year - 2000) / 1000.0;

    // Meeus Chapter 27 equinox and solstice formulas
    final double jdeMarch = 2451623.80984 +
        (365242.37404 * m) +
        (0.05169 * m * m) -
        (0.00411 * m * m * m) -
        (0.00057 * m * m * m * m);

    final double jdeJune = 2451716.56767 +
        (365241.62603 * m) +
        (0.00325 * m * m) +
        (0.00888 * m * m * m) -
        (0.00030 * m * m * m * m);

    final double jdeSept = 2451810.21715 +
        (365242.01767 * m) -
        (0.11575 * m * m) +
        (0.00337 * m * m * m) +
        (0.00078 * m * m * m * m);

    final double jdeDec = 2451900.05952 +
        (365242.74049 * m) -
        (0.06223 * m * m) -
        (0.00823 * m * m * m) +
        (0.00032 * m * m * m * m);

    final rawEvents = [
      (
        SolarEventType.vernalEquinox,
        'March Equinox',
        'Spring Equinox (Vernal)',
        'Autumn Equinox',
        jdeMarch,
      ),
      (
        SolarEventType.summerSolstice,
        'June Solstice',
        'Summer Solstice (Longest Day)',
        'Winter Solstice (Shortest Day)',
        jdeJune,
      ),
      (
        SolarEventType.autumnalEquinox,
        'September Equinox',
        'Autumn Equinox (Autumnal)',
        'Spring Equinox',
        jdeSept,
      ),
      (
        SolarEventType.winterSolstice,
        'December Solstice',
        'Winter Solstice (Shortest Day)',
        'Summer Solstice (Longest Day)',
        jdeDec,
      ),
    ];

    return rawEvents.map((e) {
      final utc = fromJulianDate(e.$5);
      final local = utc.toLocal();
      final isPast = now.isAfter(utc);
      final daysDiff = (utc.difference(now).inHours / 24).round().abs();

      return SolarEvent(
        type: e.$1,
        name: e.$2,
        northernHemisphereSeason: e.$3,
        southernHemisphereSeason: e.$4,
        utcDateTime: utc,
        localDateTime: local,
        isPast: isPast,
        daysDifference: daysDiff,
      );
    }).toList();
  }
}
