# Release 2: CONVERT & TIME Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement DateMath Release 2 (CONVERT & TIME), introducing pure Dart time mathematics, universal duration conversions, 12h/24h military time conversion, and offline world timezone offset calculations with complete unit test coverage and Material 3 UI.

**Architecture:** A pure Dart domain calculation engine in `lib/core/services/time_calculation_service.dart` with zero Flutter/UI imports paired with an immutable offline world cities dataset in `lib/core/data/world_cities_data.dart`. Four modular presentation screens under `lib/features/` consume this engine, wired into an enhanced Home Dashboard with category filter chips.

**Tech Stack:** Flutter (Dart 3.11+), Material 3, `intl`, `shared_preferences`, 100% offline, zero internet permissions.

**Spec:** [`docs/superpowers/specs/2026-09-24-release-2-convert-and-time-design.md`](file:///c:/Users/User/Desktop/mobile/flutter/datemath/docs/superpowers/specs/2026-09-24-release-2-convert-and-time-design.md)

## Global Constraints

- **Strict Offline Guarantee**: `android.permission.INTERNET` must NEVER be added; zero HTTP/network dependencies.
- **Pure Dart Services**: Core services must NOT import `package:flutter` or `dart:ui`.
- **Pure Dart Tests**: Calculation tests must run purely in Dart without device/emulator dependencies.
- **Material 3 Design**: All UI components must adhere to the existing color schemes, surface elevation, and shape tokens.

---

### Task 1: Pure Dart Core Engine — `TimeCalculationService`

**Files:**
- Create: `lib/core/services/time_calculation_service.dart`
- Create: `test/time_calculation_test.dart`

**Interfaces:**
- Produces:
  - `class ClockTime` (`int hour`, `int minute`, `int second`, `toSeconds()`, `formatted12()`, `formatted24()`, `militaryString()`)
  - `class TimeDifferenceResult` (`int hours`, `int minutes`, `int seconds`, `int totalSeconds`, `double totalHours`, `bool isOvernight`, `String formattedDuration`)
  - `class TimeAddSubtractResult` (`ClockTime resultTime`, `int dayOffset`, `bool isSubtract`, `String dayOffsetBadge`)
  - `enum DurationUnit` (`milliseconds`, `seconds`, `minutes`, `hours`, `days`, `weeks`)
  - `class DurationConversionResult` (`Map<DurationUnit, double> conversions`, `String compositeBreakdown`)
  - `class MilitaryTimeResult` (`String format12`, `String format24`, `String militaryDesignation`, `String spokenMilitary`, `double dayPercentage`)
  - `class WorldTimeOffsetResult` (`ClockTime targetTime`, `int differenceMinutes`, `String offsetDeltaLabel`, `String relativeDay`)
  - `class TimeCalculationService`:
    - `static TimeDifferenceResult difference(ClockTime start, ClockTime end, {bool assumeOvernight = true})`
    - `static TimeAddSubtractResult addSubtract(ClockTime base, {int hours = 0, int minutes = 0, int seconds = 0, bool isSubtract = false})`
    - `static DurationConversionResult convertDuration(double value, DurationUnit unit)`
    - `static MilitaryTimeResult toMilitary(ClockTime time)`
    - `static WorldTimeOffsetResult calculateOffsetDifference({required ClockTime baseTime, required int baseOffsetMinutes, required int targetOffsetMinutes})`

- [ ] **Step 1: Write the failing tests for Time Math, Duration Conversion, and Military Time**

```dart
// test/time_calculation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:datemath/core/services/time_calculation_service.dart';

void main() {
  group('TimeCalculationService - Time Difference', () {
    test('Calculates difference within the same day', () {
      final start = ClockTime(hour: 9, minute: 15, second: 0);
      final end = ClockTime(hour: 17, minute: 45, second: 30);
      final result = TimeCalculationService.difference(start, end);

      expect(result.hours, 8);
      expect(result.minutes, 30);
      expect(result.seconds, 30);
      expect(result.isOvernight, isFalse);
      expect(result.formattedDuration, '8 hours, 30 minutes, 30 seconds');
    });

    test('Calculates difference crossing midnight (overnight)', () {
      final start = ClockTime(hour: 23, minute: 30, second: 0);
      final end = ClockTime(hour: 6, minute: 15, second: 0);
      final result = TimeCalculationService.difference(start, end, assumeOvernight: true);

      expect(result.hours, 6);
      expect(result.minutes, 45);
      expect(result.seconds, 0);
      expect(result.isOvernight, isTrue);
      expect(result.totalSeconds, 24300);
    });

    test('Calculates zero difference when start equals end', () {
      final t = ClockTime(hour: 12, minute: 0, second: 0);
      final result = TimeCalculationService.difference(t, t);

      expect(result.totalSeconds, 0);
      expect(result.isOvernight, isFalse);
    });
  });

  group('TimeCalculationService - Add / Subtract Time', () {
    test('Adds duration within same day', () {
      final base = ClockTime(hour: 10, minute: 15, second: 0);
      final result = TimeCalculationService.addSubtract(base, hours: 3, minutes: 20);

      expect(result.resultTime.hour, 13);
      expect(result.resultTime.minute, 35);
      expect(result.dayOffset, 0);
      expect(result.dayOffsetBadge, 'Same day');
    });

    test('Adds duration rolling into next day', () {
      final base = ClockTime(hour: 22, minute: 0, second: 0);
      final result = TimeCalculationService.addSubtract(base, hours: 4, minutes: 30);

      expect(result.resultTime.hour, 2);
      expect(result.resultTime.minute, 30);
      expect(result.dayOffset, 1);
      expect(result.dayOffsetBadge, '+1 Day (Tomorrow)');
    });

    test('Subtracts duration rolling into previous day', () {
      final base = ClockTime(hour: 1, minute: 30, second: 0);
      final result = TimeCalculationService.addSubtract(base, hours: 3, isSubtract: true);

      expect(result.resultTime.hour, 22);
      expect(result.resultTime.minute, 30);
      expect(result.dayOffset, -1);
      expect(result.dayOffsetBadge, '-1 Day (Yesterday)');
    });
  });

  group('TimeCalculationService - Duration Conversions', () {
    test('Converts 1 day across all units', () {
      final result = TimeCalculationService.convertDuration(1, DurationUnit.days);

      expect(result.conversions[DurationUnit.days], 1.0);
      expect(result.conversions[DurationUnit.hours], 24.0);
      expect(result.conversions[DurationUnit.minutes], 1440.0);
      expect(result.conversions[DurationUnit.seconds], 86400.0);
      expect(result.conversions[DurationUnit.milliseconds], 86400000.0);
      expect(result.compositeBreakdown, '1 day');
    });

    test('Produces accurate composite breakdown', () {
      // 90061s = 1 day, 1 hour, 1 minute, 1 second
      final result = TimeCalculationService.convertDuration(90061, DurationUnit.seconds);
      expect(result.compositeBreakdown, '1 day, 1 hour, 1 min, 1 sec');
    });
  });

  group('TimeCalculationService - 12h/24h Military Time', () {
    test('Converts midnight correctly', () {
      final midnight = ClockTime(hour: 0, minute: 0, second: 0);
      final result = TimeCalculationService.toMilitary(midnight);

      expect(result.format12, '12:00 AM');
      expect(result.format24, '00:00');
      expect(result.militaryDesignation, '0000 Hours');
      expect(result.spokenMilitary, 'Zero zero zero zero hours');
      expect(result.dayPercentage, 0.0);
    });

    test('Converts 08:45 PM correctly', () {
      final t = ClockTime(hour: 20, minute: 45, second: 0);
      final result = TimeCalculationService.toMilitary(t);

      expect(result.format12, '08:45 PM');
      expect(result.format24, '20:45');
      expect(result.militaryDesignation, '2045 Hours');
      expect(result.spokenMilitary, 'Twenty hundred forty-five hours');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/time_calculation_test.dart`
Expected: Compilation failure because `lib/core/services/time_calculation_service.dart` does not yet exist.

- [ ] **Step 3: Implement `TimeCalculationService`**

Create `lib/core/services/time_calculation_service.dart`:

```dart
/// Pure Dart Time & Duration calculation engine for DateMath.
/// 100% offline, zero Flutter UI dependencies.

class ClockTime {
  final int hour;
  final int minute;
  final int second;

  const ClockTime({
    required this.hour,
    required this.minute,
    this.second = 0,
  })  : assert(hour >= 0 && hour <= 23, 'Hour must be between 0 and 23'),
        assert(minute >= 0 && minute <= 59, 'Minute must be between 0 and 59'),
        assert(second >= 0 && second <= 59, 'Second must be between 0 and 59');

  factory ClockTime.fromDateTime(DateTime dt) {
    return ClockTime(hour: dt.hour, minute: dt.minute, second: dt.second);
  }

  factory ClockTime.fromSeconds(int totalSeconds) {
    final normalized = ((totalSeconds % 86400) + 86400) % 86400;
    final h = normalized ~/ 3600;
    final rem = normalized % 3600;
    final m = rem ~/ 60;
    final s = rem % 60;
    return ClockTime(hour: h, minute: m, second: s);
  }

  int toSeconds() => hour * 3600 + minute * 60 + second;

  String formatted12({bool showSeconds = false}) {
    final h12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final hStr = h12.toString().padLeft(2, '0');
    final mStr = minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    if (showSeconds) {
      final sStr = second.toString().padLeft(2, '0');
      return '$hStr:$mStr:$sStr $period';
    }
    return '$hStr:$mStr $period';
  }

  String formatted24({bool showSeconds = false}) {
    final hStr = hour.toString().padLeft(2, '0');
    final mStr = minute.toString().padLeft(2, '0');
    if (showSeconds) {
      final sStr = second.toString().padLeft(2, '0');
      return '$hStr:$mStr:$sStr';
    }
    return '$hStr:$mStr';
  }

  String militaryString() {
    final hStr = hour.toString().padLeft(2, '0');
    final mStr = minute.toString().padLeft(2, '0');
    return '$hStr$mStr Hours';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClockTime &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute &&
          second == other.second;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode ^ second.hashCode;
}

class TimeDifferenceResult {
  final int hours;
  final int minutes;
  final int seconds;
  final int totalSeconds;
  final double totalHours;
  final bool isOvernight;

  const TimeDifferenceResult({
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.totalSeconds,
    required this.totalHours,
    required this.isOvernight,
  });

  String get formattedDuration {
    final parts = <String>[];
    if (hours > 0) parts.add('$hours ${hours == 1 ? "hour" : "hours"}');
    if (minutes > 0) parts.add('$minutes ${minutes == 1 ? "minute" : "minutes"}');
    if (seconds > 0 || parts.isEmpty) {
      parts.add('$seconds ${seconds == 1 ? "second" : "seconds"}');
    }
    return parts.join(', ');
  }
}

class TimeAddSubtractResult {
  final ClockTime resultTime;
  final int dayOffset;
  final bool isSubtract;

  const TimeAddSubtractResult({
    required this.resultTime,
    required this.dayOffset,
    required this.isSubtract,
  });

  String get dayOffsetBadge {
    if (dayOffset == 0) return 'Same day';
    if (dayOffset == 1) return '+1 Day (Tomorrow)';
    if (dayOffset == -1) return '-1 Day (Yesterday)';
    return dayOffset > 0 ? '+$dayOffset Days' : '$dayOffset Days';
  }
}

enum DurationUnit {
  milliseconds,
  seconds,
  minutes,
  hours,
  days,
  weeks,
}

class DurationConversionResult {
  final double sourceValue;
  final DurationUnit sourceUnit;
  final Map<DurationUnit, double> conversions;
  final String compositeBreakdown;

  const DurationConversionResult({
    required this.sourceValue,
    required this.sourceUnit,
    required this.conversions,
    required this.compositeBreakdown,
  });
}

class MilitaryTimeResult {
  final String format12;
  final String format24;
  final String militaryDesignation;
  final String spokenMilitary;
  final double dayPercentage;

  const MilitaryTimeResult({
    required this.format12,
    required this.format24,
    required this.militaryDesignation,
    required this.spokenMilitary,
    required this.dayPercentage,
  });
}

class WorldTimeOffsetResult {
  final ClockTime targetTime;
  final int differenceMinutes;
  final String offsetDeltaLabel;
  final String relativeDay;

  const WorldTimeOffsetResult({
    required this.targetTime,
    required this.differenceMinutes,
    required this.offsetDeltaLabel,
    required this.relativeDay,
  });
}

class TimeCalculationService {
  static const Map<DurationUnit, double> _secondsPerUnit = {
    DurationUnit.milliseconds: 0.001,
    DurationUnit.seconds: 1.0,
    DurationUnit.minutes: 60.0,
    DurationUnit.hours: 3600.0,
    DurationUnit.days: 86400.0,
    DurationUnit.weeks: 604800.0,
  };

  static TimeDifferenceResult difference(
    ClockTime start,
    ClockTime end, {
    bool assumeOvernight = true,
  }) {
    final startSec = start.toSeconds();
    var endSec = end.toSeconds();
    var isOvernight = false;

    if (endSec < startSec && assumeOvernight) {
      endSec += 86400;
      isOvernight = true;
    }

    final diffSec = endSec >= startSec ? endSec - startSec : (endSec + 86400 - startSec);
    final h = diffSec ~/ 3600;
    final rem = diffSec % 3600;
    final m = rem ~/ 60;
    final s = rem % 60;

    return TimeDifferenceResult(
      hours: h,
      minutes: m,
      seconds: s,
      totalSeconds: diffSec,
      totalHours: diffSec / 3600.0,
      isOvernight: isOvernight,
    );
  }

  static TimeAddSubtractResult addSubtract(
    ClockTime base, {
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
    bool isSubtract = false,
  }) {
    final deltaSec = (hours * 3600 + minutes * 60 + seconds) * (isSubtract ? -1 : 1);
    final totalTargetSec = base.toSeconds() + deltaSec;

    var dayOffset = 0;
    if (totalTargetSec >= 86400) {
      dayOffset = totalTargetSec ~/ 86400;
    } else if (totalTargetSec < 0) {
      dayOffset = -((( -totalTargetSec - 1) ~/ 86400) + 1);
    }

    final normalizedSec = ((totalTargetSec % 86400) + 86400) % 86400;
    final resultTime = ClockTime.fromSeconds(normalizedSec);

    return TimeAddSubtractResult(
      resultTime: resultTime,
      dayOffset: dayOffset,
      isSubtract: isSubtract,
    );
  }

  static DurationConversionResult convertDuration(double value, DurationUnit unit) {
    final factor = _secondsPerUnit[unit]!;
    final totalSeconds = value * factor;

    final conversions = <DurationUnit, double>{};
    for (final entry in _secondsPerUnit.entries) {
      conversions[entry.key] = totalSeconds / entry.value;
    }

    // Composite breakdown
    final wholeSeconds = totalSeconds.round().abs();
    final d = wholeSeconds ~/ 86400;
    final remD = wholeSeconds % 86400;
    final h = remD ~/ 3600;
    final remH = remD % 3600;
    final m = remH ~/ 60;
    final s = remH % 60;

    final parts = <String>[];
    if (d > 0) parts.add('$d ${d == 1 ? "day" : "days"}');
    if (h > 0) parts.add('$h ${h == 1 ? "hour" : "hours"}');
    if (m > 0) parts.add('$m min');
    if (s > 0 || parts.isEmpty) parts.add('$s sec');

    return DurationConversionResult(
      sourceValue: value,
      sourceUnit: unit,
      conversions: conversions,
      compositeBreakdown: parts.join(', '),
    );
  }

  static MilitaryTimeResult toMilitary(ClockTime time) {
    final f12 = time.formatted12();
    final f24 = time.formatted24();
    final milDesig = time.militaryString();

    final spoken = _formatSpokenMilitary(time.hour, time.minute);
    final dayPct = (time.toSeconds() / 86400.0) * 100.0;

    return MilitaryTimeResult(
      format12: f12,
      format24: f24,
      militaryDesignation: milDesig,
      spokenMilitary: spoken,
      dayPercentage: double.parse(dayPct.toStringAsFixed(1)),
    );
  }

  static String _formatSpokenMilitary(int hour, int minute) {
    const numbers = [
      'zero', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine',
      'ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen', 'sixteen',
      'seventeen', 'eighteen', 'nineteen', 'twenty'
    ];

    if (hour == 0 && minute == 0) {
      return 'Zero zero zero zero hours';
    }

    String hourStr;
    if (hour < 10) {
      hourStr = 'Zero ${numbers[hour]}';
    } else if (hour <= 20) {
      hourStr = numbers[hour];
    } else {
      hourStr = 'Twenty-${numbers[hour - 20]}';
    }

    if (minute == 0) {
      return '${_capitalize(hourStr)} hundred hours';
    }

    String minStr;
    if (minute < 10) {
      minStr = 'zero ${numbers[minute]}';
    } else if (minute <= 20) {
      minStr = numbers[minute];
    } else {
      final tens = minute ~/ 10;
      final ones = minute % 10;
      final tensStr = ['twenty', 'thirty', 'forty', 'fifty'][tens - 2];
      minStr = ones == 0 ? tensStr : '$tensStr-${numbers[ones]}';
    }

    return '${_capitalize(hourStr)} hundred $minStr hours';
  }

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  static WorldTimeOffsetResult calculateOffsetDifference({
    required ClockTime baseTime,
    required int baseOffsetMinutes,
    required int targetOffsetMinutes,
  }) {
    final diffMinutes = targetOffsetMinutes - baseOffsetMinutes;
    final totalTargetMinutes = (baseTime.hour * 60 + baseTime.minute) + diffMinutes;

    var dayStatus = 'Same day';
    if (totalTargetMinutes >= 1440) {
      dayStatus = 'Tomorrow (+1d)';
    } else if (totalTargetMinutes < 0) {
      dayStatus = 'Yesterday (-1d)';
    }

    final normalizedMinutes = ((totalTargetMinutes % 1440) + 1440) % 1440;
    final targetTime = ClockTime(
      hour: normalizedMinutes ~/ 60,
      minute: normalizedMinutes % 60,
      second: baseTime.second,
    );

    final diffAbs = diffMinutes.abs();
    final diffHours = diffAbs ~/ 60;
    final diffRemMinutes = diffAbs % 60;
    final sign = diffMinutes >= 0 ? '+' : '-';
    final label = diffRemMinutes == 0
        ? '$sign$diffHours hrs ${diffMinutes >= 0 ? "ahead" : "behind"}'
        : '$sign$diffHours hrs $diffRemMinutes mins ${diffMinutes >= 0 ? "ahead" : "behind"}';

    return WorldTimeOffsetResult(
      targetTime: targetTime,
      differenceMinutes: diffMinutes,
      offsetDeltaLabel: diffMinutes == 0 ? 'Same time zone' : label,
      relativeDay: dayStatus,
    );
  }
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/time_calculation_test.dart`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/services/time_calculation_service.dart test/time_calculation_test.dart
git commit -m "feat(core): implement pure Dart TimeCalculationService and unit tests"
```

---

### Task 2: Offline World Cities Catalog (`world_cities_data.dart`)

**Files:**
- Create: `lib/core/data/world_cities_data.dart`
- Modify: `test/time_calculation_test.dart`

**Interfaces:**
- Produces:
  - `class WorldCity` (`String name`, `String country`, `String continent`, `int utcOffsetMinutes`, `String abbreviation`)
  - `class WorldCitiesData`:
    - `static List<WorldCity> get allCities`
    - `static List<WorldCity> searchCities(String query)`
    - `static List<String> get continents`

- [ ] **Step 1: Write test for World Cities search and offset calculation**

Add to `test/time_calculation_test.dart`:
```dart
  group('WorldCitiesData and World Time Offset Math', () {
    test('Contains ~60 major global cities spanning all continents', () {
      expect(WorldCitiesData.allCities.length, greaterThanOrEqualTo(50));
      expect(WorldCitiesData.continents, containsAll(['Europe', 'Asia', 'North America', 'Africa', 'Oceania', 'South America']));
    });

    test('Searches cities case-insensitively by name, country, or code', () {
      final results = WorldCitiesData.searchCities('tokyo');
      expect(results.length, 1);
      expect(results.first.name, 'Tokyo');
      expect(results.first.utcOffsetMinutes, 9 * 60);

      final ukResults = WorldCitiesData.searchCities('United Kingdom');
      expect(ukResults.any((c) => c.name == 'London'), isTrue);
    });

    test('Calculates world offset difference correctly', () {
      // London (UTC+0) to New Delhi (UTC+5:30)
      final londonTime = ClockTime(hour: 12, minute: 0);
      final result = TimeCalculationService.calculateOffsetDifference(
        baseTime: londonTime,
        baseOffsetMinutes: 0,
        targetOffsetMinutes: 330, // +5h 30m
      );

      expect(result.targetTime.hour, 17);
      expect(result.targetTime.minute, 30);
      expect(result.offsetDeltaLabel, contains('+5 hrs 30 mins ahead'));
      expect(result.relativeDay, 'Same day');
    });

    test('Calculates world offset date rollover into yesterday', () {
      // Tokyo (UTC+9) 04:00 AM to New York (UTC-5) -> Tokyo is 14 hrs ahead
      final tokyoTime = ClockTime(hour: 4, minute: 0);
      final result = TimeCalculationService.calculateOffsetDifference(
        baseTime: tokyoTime,
        baseOffsetMinutes: 540,
        targetOffsetMinutes: -300,
      );

      expect(result.targetTime.hour, 14); // 2:00 PM yesterday
      expect(result.targetTime.minute, 0);
      expect(result.relativeDay, 'Yesterday (-1d)');
    });
  });
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/time_calculation_test.dart`
Expected: FAIL because `WorldCitiesData` does not exist yet.

- [ ] **Step 3: Implement `WorldCitiesData`**

Create `lib/core/data/world_cities_data.dart`:
```dart
/// Immutable offline dataset of major world cities and their standard UTC offsets.
/// 100% offline, zero network dependencies.

class WorldCity {
  final String name;
  final String country;
  final String continent;
  final int utcOffsetMinutes;
  final String abbreviation;

  const WorldCity({
    required this.name,
    required this.country,
    required this.continent,
    required this.utcOffsetMinutes,
    required this.abbreviation,
  });

  String get formattedOffset {
    final sign = utcOffsetMinutes >= 0 ? '+' : '-';
    final absMin = utcOffsetMinutes.abs();
    final h = (absMin ~/ 60).toString().padLeft(2, '0');
    final m = (absMin % 60).toString().padLeft(2, '0');
    return 'UTC$sign$h:$m';
  }
}

class WorldCitiesData {
  static const List<WorldCity> allCities = [
    // Europe
    WorldCity(name: 'London', country: 'United Kingdom', continent: 'Europe', utcOffsetMinutes: 0, abbreviation: 'GMT'),
    WorldCity(name: 'Dublin', country: 'Ireland', continent: 'Europe', utcOffsetMinutes: 0, abbreviation: 'GMT'),
    WorldCity(name: 'Paris', country: 'France', continent: 'Europe', utcOffsetMinutes: 60, abbreviation: 'CET'),
    WorldCity(name: 'Berlin', country: 'Germany', continent: 'Europe', utcOffsetMinutes: 60, abbreviation: 'CET'),
    WorldCity(name: 'Rome', country: 'Italy', continent: 'Europe', utcOffsetMinutes: 60, abbreviation: 'CET'),
    WorldCity(name: 'Madrid', country: 'Spain', continent: 'Europe', utcOffsetMinutes: 60, abbreviation: 'CET'),
    WorldCity(name: 'Amsterdam', country: 'Netherlands', continent: 'Europe', utcOffsetMinutes: 60, abbreviation: 'CET'),
    WorldCity(name: 'Stockholm', country: 'Sweden', continent: 'Europe', utcOffsetMinutes: 60, abbreviation: 'CET'),
    WorldCity(name: 'Athens', country: 'Greece', continent: 'Europe', utcOffsetMinutes: 120, abbreviation: 'EET'),
    WorldCity(name: 'Helsinki', country: 'Finland', continent: 'Europe', utcOffsetMinutes: 120, abbreviation: 'EET'),
    WorldCity(name: 'Istanbul', country: 'Turkey', continent: 'Europe', utcOffsetMinutes: 180, abbreviation: 'TRT'),
    WorldCity(name: 'Moscow', country: 'Russia', continent: 'Europe', utcOffsetMinutes: 180, abbreviation: 'MSK'),

    // North America
    WorldCity(name: 'New York', country: 'United States', continent: 'North America', utcOffsetMinutes: -300, abbreviation: 'EST'),
    WorldCity(name: 'Toronto', country: 'Canada', continent: 'North America', utcOffsetMinutes: -300, abbreviation: 'EST'),
    WorldCity(name: 'Chicago', country: 'United States', continent: 'North America', utcOffsetMinutes: -360, abbreviation: 'CST'),
    WorldCity(name: 'Mexico City', country: 'Mexico', continent: 'North America', utcOffsetMinutes: -360, abbreviation: 'CST'),
    WorldCity(name: 'Denver', country: 'United States', continent: 'North America', utcOffsetMinutes: -420, abbreviation: 'MST'),
    WorldCity(name: 'Los Angeles', country: 'United States', continent: 'North America', utcOffsetMinutes: -480, abbreviation: 'PST'),
    WorldCity(name: 'San Francisco', country: 'United States', continent: 'North America', utcOffsetMinutes: -480, abbreviation: 'PST'),
    WorldCity(name: 'Vancouver', country: 'Canada', continent: 'North America', utcOffsetMinutes: -480, abbreviation: 'PST'),
    WorldCity(name: 'Anchorage', country: 'United States', continent: 'North America', utcOffsetMinutes: -540, abbreviation: 'AKST'),
    WorldCity(name: 'Honolulu', country: 'United States', continent: 'North America', utcOffsetMinutes: -600, abbreviation: 'HST'),

    // Asia
    WorldCity(name: 'Dubai', country: 'United Arab Emirates', continent: 'Asia', utcOffsetMinutes: 240, abbreviation: 'GST'),
    WorldCity(name: 'Karachi', country: 'Pakistan', continent: 'Asia', utcOffsetMinutes: 300, abbreviation: 'PKT'),
    WorldCity(name: 'New Delhi', country: 'India', continent: 'Asia', utcOffsetMinutes: 330, abbreviation: 'IST'),
    WorldCity(name: 'Kathmandu', country: 'Nepal', continent: 'Asia', utcOffsetMinutes: 345, abbreviation: 'NPT'),
    WorldCity(name: 'Dhaka', country: 'Bangladesh', continent: 'Asia', utcOffsetMinutes: 360, abbreviation: 'BST'),
    WorldCity(name: 'Bangkok', country: 'Thailand', continent: 'Asia', utcOffsetMinutes: 420, abbreviation: 'ICT'),
    WorldCity(name: 'Jakarta', country: 'Indonesia', continent: 'Asia', utcOffsetMinutes: 420, abbreviation: 'WIB'),
    WorldCity(name: 'Singapore', country: 'Singapore', continent: 'Asia', utcOffsetMinutes: 480, abbreviation: 'SGT'),
    WorldCity(name: 'Hong Kong', country: 'China', continent: 'Asia', utcOffsetMinutes: 480, abbreviation: 'HKT'),
    WorldCity(name: 'Beijing', country: 'China', continent: 'Asia', utcOffsetMinutes: 480, abbreviation: 'CST'),
    WorldCity(name: 'Shanghai', country: 'China', continent: 'Asia', utcOffsetMinutes: 480, abbreviation: 'CST'),
    WorldCity(name: 'Seoul', country: 'South Korea', continent: 'Asia', utcOffsetMinutes: 540, abbreviation: 'KST'),
    WorldCity(name: 'Tokyo', country: 'Japan', continent: 'Asia', utcOffsetMinutes: 540, abbreviation: 'JST'),

    // South America
    WorldCity(name: 'Buenos Aires', country: 'Argentina', continent: 'South America', utcOffsetMinutes: -180, abbreviation: 'ART'),
    WorldCity(name: 'São Paulo', country: 'Brazil', continent: 'South America', utcOffsetMinutes: -180, abbreviation: 'BRT'),
    WorldCity(name: 'Santiago', country: 'Chile', continent: 'South America', utcOffsetMinutes: -240, abbreviation: 'CLT'),
    WorldCity(name: 'Bogotá', country: 'Colombia', continent: 'South America', utcOffsetMinutes: -300, abbreviation: 'COT'),
    WorldCity(name: 'Lima', country: 'Peru', continent: 'South America', utcOffsetMinutes: -300, abbreviation: 'PET'),

    // Oceania
    WorldCity(name: 'Perth', country: 'Australia', continent: 'Oceania', utcOffsetMinutes: 480, abbreviation: 'AWST'),
    WorldCity(name: 'Adelaide', country: 'Australia', continent: 'Oceania', utcOffsetMinutes: 570, abbreviation: 'ACST'),
    WorldCity(name: 'Sydney', country: 'Australia', continent: 'Oceania', utcOffsetMinutes: 600, abbreviation: 'AEST'),
    WorldCity(name: 'Melbourne', country: 'Australia', continent: 'Oceania', utcOffsetMinutes: 600, abbreviation: 'AEST'),
    WorldCity(name: 'Brisbane', country: 'Australia', continent: 'Oceania', utcOffsetMinutes: 600, abbreviation: 'AEST'),
    WorldCity(name: 'Auckland', country: 'New Zealand', continent: 'Oceania', utcOffsetMinutes: 720, abbreviation: 'NZST'),
    WorldCity(name: 'Fiji', country: 'Fiji', continent: 'Oceania', utcOffsetMinutes: 720, abbreviation: 'FJT'),

    // Africa
    WorldCity(name: 'Cairo', country: 'Egypt', continent: 'Africa', utcOffsetMinutes: 120, abbreviation: 'EEST'),
    WorldCity(name: 'Johannesburg', country: 'South Africa', continent: 'Africa', utcOffsetMinutes: 120, abbreviation: 'SAST'),
    WorldCity(name: 'Lagos', country: 'Nigeria', continent: 'Africa', utcOffsetMinutes: 60, abbreviation: 'WAT'),
    WorldCity(name: 'Nairobi', country: 'Kenya', continent: 'Africa', utcOffsetMinutes: 180, abbreviation: 'EAT'),
    WorldCity(name: 'Casablanca', country: 'Morocco', continent: 'Africa', utcOffsetMinutes: 60, abbreviation: 'WEST'),
    WorldCity(name: 'Accra', country: 'Ghana', continent: 'Africa', utcOffsetMinutes: 0, abbreviation: 'GMT'),
  ];

  static List<String> get continents {
    return allCities.map((c) => c.continent).toSet().toList()..sort();
  }

  static List<WorldCity> searchCities(String query) {
    if (query.trim().isEmpty) return allCities;
    final q = query.trim().toLowerCase();
    return allCities.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.country.toLowerCase().contains(q) ||
          c.abbreviation.toLowerCase().contains(q) ||
          c.continent.toLowerCase().contains(q);
    }).toList();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/time_calculation_test.dart`
Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/data/world_cities_data.dart test/time_calculation_test.dart
git commit -m "feat(core): add offline WorldCitiesData and timezone offset tests"
```

---

### Task 3: Feature 1 UI — Time Math Screen

**Files:**
- Create: `lib/features/time_math/presentation/time_math_screen.dart`
- Consumes: `ClockTime`, `TimeDifferenceResult`, `TimeAddSubtractResult`, `TimeCalculationService`

- [ ] **Step 1: Implement `TimeMathScreen`**

Create `lib/features/time_math/presentation/time_math_screen.dart`:
- Segmented control / Tab controller for `Time Difference` vs `Add / Subtract`.
- *Time Difference*:
  - Start Time tile & End Time tile triggering Flutter `showTimePicker`.
  - Automatic overnight detection with indicator badge.
  - Result Card: Large bold formatted duration, chips for total minutes, seconds, decimal hours, and a copy button.
- *Add / Subtract*:
  - Base Time picker.
  - Operation toggle: Add (+) or Subtract (-).
  - Stepper or slider fields for Hours (0-99), Minutes (0-59), Seconds (0-59).
  - Result Card: Computed Clock Time in 12h/24h, Day Shift indicator (`Same day`, `+1 Day (Tomorrow)`, etc.).

- [ ] **Step 2: Verify static analysis**

Run: `flutter analyze lib/features/time_math/presentation/time_math_screen.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/features/time_math/presentation/time_math_screen.dart
git commit -m "feat(time_math): add TimeMathScreen with difference and add/subtract tabs"
```

---

### Task 4: Feature 2 UI — Duration Converter Screen

**Files:**
- Create: `lib/features/duration_converter/presentation/duration_converter_screen.dart`
- Consumes: `DurationUnit`, `DurationConversionResult`, `TimeCalculationService`

- [ ] **Step 1: Implement `DurationConverterScreen`**

Create `lib/features/duration_converter/presentation/duration_converter_screen.dart`:
- Text field for numeric value input with clear button.
- Dropdown or segmented buttons to choose source unit (`Milliseconds`, `Seconds`, `Minutes`, `Hours`, `Days`, `Weeks`).
- Quick preset buttons: `1 Hour`, `1 Day`, `1 Week`, `3,600s`, `86,400s`.
- Composite Breakdown Card: Shows human-readable breakdown (e.g. `90,000s = 1 day, 1 hour, 0 mins, 0 secs`).
- Conversion Grid/List: Cards for all 5 other units showing exact values, with tap-to-copy functionality.

- [ ] **Step 2: Verify static analysis**

Run: `flutter analyze lib/features/duration_converter/presentation/duration_converter_screen.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/features/duration_converter/presentation/duration_converter_screen.dart
git commit -m "feat(duration_converter): add DurationConverterScreen with multi-unit live conversions"
```

---

### Task 5: Feature 3 UI — 12h / 24h Military Time Screen

**Files:**
- Create: `lib/features/twelve_twenty_four/presentation/twelve_twenty_four_screen.dart`
- Consumes: `ClockTime`, `MilitaryTimeResult`, `TimeCalculationService`

- [ ] **Step 1: Implement `TwelveTwentyFourScreen`**

Create `lib/features/twelve_twenty_four/presentation/twelve_twenty_four_screen.dart`:
- Time picker button or interactive hour/minute sliders.
- Result Showcase Card:
  - 12-Hour formatted time (`08:45 PM`)
  - 24-Hour formatted time (`20:45`)
  - Military Designator (`2045 Hours`)
  - Spoken military guide (`"Twenty hundred forty-five hours"`)
  - Linear day progress indicator (`86.5% of day complete`).
- Quick Reference Table / Card:
  - Shows key military milestones (0000 = Midnight, 0600 = Reveille, 1200 = Noon, 1800 = Evening, 2359 = End of Day).

- [ ] **Step 2: Verify static analysis**

Run: `flutter analyze lib/features/twelve_twenty_four/presentation/twelve_twenty_four_screen.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/features/twelve_twenty_four/presentation/twelve_twenty_four_screen.dart
git commit -m "feat(twelve_twenty_four): add TwelveTwentyFourScreen with military time studio"
```

---

### Task 6: Feature 4 UI — World Time Offsets Screen

**Files:**
- Create: `lib/features/world_time_offsets/presentation/world_time_offsets_screen.dart`
- Consumes: `WorldCitiesData`, `WorldCity`, `ClockTime`, `WorldTimeOffsetResult`, `TimeCalculationService`

- [ ] **Step 1: Implement `WorldTimeOffsetsScreen`**

Create `lib/features/world_time_offsets/presentation/world_time_offsets_screen.dart`:
- Base Location Card:
  - Defaults to local device time & device UTC offset.
  - Allows picking base city or setting custom base UTC offset.
- Target Location Card:
  - Button to open searchable offline city bottom sheet (`WorldCitiesData.searchCities`).
  - Direct UTC offset slider (`UTC-12:00` to `UTC+14:00` in 15/30-minute intervals).
- Live Comparison Card:
  - Target clock time in 12h & 24h formats.
  - Relative offset badge (`+5h 30m ahead` / `-8h behind`).
  - Day indicator badge (`Same day`, `Tomorrow (+1d)`, `Yesterday (-1d)`).
  - Interactive time scrubber slider allowing the user to scrub hours and observe target time shift dynamically.

- [ ] **Step 2: Verify static analysis**

Run: `flutter analyze lib/features/world_time_offsets/presentation/world_time_offsets_screen.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/features/world_time_offsets/presentation/world_time_offsets_screen.dart
git commit -m "feat(world_time_offsets): add offline WorldTimeOffsetsScreen with city search and UTC slider"
```

---

### Task 7: Home Dashboard Integration & Category Filter Chips

**Files:**
- Modify: `lib/features/home/presentation/home_screen.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Update `HomeScreen`**
  - Add category filter chips row: `All (8)`, `Date Tools (4)`, `Time & Convert (4)`.
  - Add 4 new Tool Cards linking to:
    - `TimeMathScreen`
    - `DurationConverterScreen`
    - `TwelveTwentyFourScreen`
    - `WorldTimeOffsetsScreen`
  - Ensure filter state smoothly filters the visible cards list.

- [ ] **Step 2: Update Widget Tests (`test/widget_test.dart`)**
  - Verify all 8 tool cards render when `All` is selected.
  - Verify tapping `Date Tools` filters to 4 date cards.
  - Verify tapping `Time & Convert` filters to 4 time cards.
  - Verify tapping a time card navigates to the respective screen.

- [ ] **Step 3: Run widget tests**

Run: `flutter test test/widget_test.dart`
Expected: All widget tests pass.

- [ ] **Step 4: Commit**

```bash
git add lib/features/home/presentation/home_screen.dart test/widget_test.dart
git commit -m "feat(home): integrate Release 2 tool cards and category filter chips"
```

---

### Task 8: Verification, Documentation & Roadmap Update

**Files:**
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `pubspec.yaml` (bump version to 1.1.0+2)

- [ ] **Step 1: Update `AGENTS.md` and `README.md`**
  - In `AGENTS.md`, mark **Release 2: CONVERT & TIME** as **Active (Completed)** and document the new directory structure and feature set.
  - In `README.md`, document the 4 new Time & Conversion tools.
  - In `pubspec.yaml`, increment version to `1.1.0+2`.

- [ ] **Step 2: Run full project verification**

Run:
```bash
flutter analyze
flutter test
```
Expected:
- `flutter analyze` reports `No issues found!`.
- All tests pass (0 failures).

- [ ] **Step 3: Verify strict offline guarantees**

Run check to confirm `android.permission.INTERNET` is absent in `android/app/src/main/AndroidManifest.xml` and no network dependencies exist in `pubspec.yaml`.

- [ ] **Step 4: Final commit**

```bash
git add AGENTS.md README.md pubspec.yaml
git commit -m "chore(release): complete Release 2 (CONVERT & TIME) and bump version to 1.1.0+2"
```
