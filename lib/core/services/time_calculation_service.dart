/// Pure Dart Time & Duration calculation engine for DateMath.
/// 100% offline, zero Flutter UI dependencies.
library;

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
