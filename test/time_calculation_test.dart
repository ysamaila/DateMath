import 'package:flutter_test/flutter_test.dart';
import 'package:datemath/core/services/time_calculation_service.dart';
import 'package:datemath/core/data/world_cities_data.dart';

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
}

