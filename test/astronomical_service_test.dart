import 'package:flutter_test/flutter_test.dart';
import 'package:datemath/core/services/astronomical_service.dart';

void main() {
  group('AstronomicalService - Julian Date & Day Milestones', () {
    test('calculates known reference Julian Date for J2000.0 epoch (2000-01-01 12:00 UTC)', () {
      final epoch = DateTime.utc(2000, 1, 1, 12, 0, 0);
      final result = AstronomicalService.calculateJulianDate(epoch);

      expect(result.julianDate, closeTo(2451545.0, 0.001));
      expect(result.modifiedJulianDate, closeTo(51544.5, 0.001));
      expect(result.julianDayNumber, equals(2451545));
      expect(result.dayOfYear, equals(1));
      expect(result.totalDaysInYear, equals(366)); // 2000 was a leap year
    });

    test('calculates Julian Date and Day of Year for standard date', () {
      final date = DateTime.utc(2026, 10, 4, 12, 0, 0);
      final result = AstronomicalService.calculateJulianDate(date);

      // JD for 2026-10-04 12:00 UTC is ~2461318.0
      expect(result.julianDate, closeTo(2461318.0, 0.5));
      expect(result.modifiedJulianDate, closeTo(result.julianDate - 2400000.5, 0.0001));
      expect(result.dayOfYear, equals(277));
      expect(result.totalDaysInYear, equals(365));
      expect(result.daysRemaining, equals(88));
      expect(result.yearProgressPercentage, closeTo((277 / 365) * 100, 0.1));
    });

    test('generates annual milestones for given year', () {
      final milestones = AstronomicalService.getDayOfYearMilestones(
        2026,
        referenceNow: DateTime.utc(2026, 6, 1),
      );

      expect(milestones.isNotEmpty, isTrue);
      // Check for presence of Day 100 and Mid-Year
      final day100 = milestones.firstWhere((m) => m.dayNumber == 100);
      expect(day100.date.year, equals(2026));
      expect(day100.isReached, isTrue); // June 1 is after Day 100 (April 10)

      final day300 = milestones.firstWhere((m) => m.dayNumber == 300);
      expect(day300.isReached, isFalse);
      expect(day300.daysAway, greaterThan(0));
    });
  });

  group('AstronomicalService - Moon Phase Calculations', () {
    test('calculates moon phase info accurately for known new moon and full moon', () {
      // 2024-08-04 was a New Moon (~11:13 UTC)
      final newMoonDate = DateTime.utc(2024, 8, 4, 11, 13);
      final newMoon = AstronomicalService.calculateMoonPhase(newMoonDate);
      expect(newMoon.illuminationPercentage, lessThan(8.0));
      expect(newMoon.phase, equals(MoonPhase.newMoon));

      // 2024-08-19 was a Full Moon (~18:26 UTC)
      final fullMoonDate = DateTime.utc(2024, 8, 19, 18, 26);
      final fullMoon = AstronomicalService.calculateMoonPhase(fullMoonDate);
      expect(fullMoon.illuminationPercentage, greaterThan(92.0));
      expect(fullMoon.phase, equals(MoonPhase.fullMoon));
    });

    test('generates 4 upcoming primary phases in chronological order', () {
      final now = DateTime.utc(2026, 10, 4);
      final moon = AstronomicalService.calculateMoonPhase(now);

      expect(moon.upcomingPhases.length, equals(4));
      for (int i = 0; i < moon.upcomingPhases.length - 1; i++) {
        expect(
          moon.upcomingPhases[i].targetDate.isBefore(moon.upcomingPhases[i + 1].targetDate),
          isTrue,
        );
      }
    });
  });

  group('AstronomicalService - Equinox & Solstice Calculations', () {
    test('calculates 4 cardinal solar events for 2026 with correct approximate dates', () {
      final events = AstronomicalService.calculateSolarEvents(
        2026,
        referenceNow: DateTime.utc(2026, 1, 1),
      );

      expect(events.length, equals(4));

      final marchEquinox = events.firstWhere((e) => e.type == SolarEventType.vernalEquinox);
      expect(marchEquinox.utcDateTime.month, equals(3));
      expect(marchEquinox.utcDateTime.day, inInclusiveRange(19, 21));

      final juneSolstice = events.firstWhere((e) => e.type == SolarEventType.summerSolstice);
      expect(juneSolstice.utcDateTime.month, equals(6));
      expect(juneSolstice.utcDateTime.day, inInclusiveRange(20, 22));

      final septEquinox = events.firstWhere((e) => e.type == SolarEventType.autumnalEquinox);
      expect(septEquinox.utcDateTime.month, equals(9));
      expect(septEquinox.utcDateTime.day, inInclusiveRange(21, 24));

      final decSolstice = events.firstWhere((e) => e.type == SolarEventType.winterSolstice);
      expect(decSolstice.utcDateTime.month, equals(12));
      expect(decSolstice.utcDateTime.day, inInclusiveRange(20, 23));
    });

    test('determines isPast and duration correctly based on referenceNow', () {
      final events = AstronomicalService.calculateSolarEvents(
        2026,
        referenceNow: DateTime.utc(2026, 7, 1), // July 1, 2026
      );

      final marchEquinox = events.firstWhere((e) => e.type == SolarEventType.vernalEquinox);
      final decSolstice = events.firstWhere((e) => e.type == SolarEventType.winterSolstice);

      expect(marchEquinox.isPast, isTrue);
      expect(decSolstice.isPast, isFalse);
      expect(decSolstice.daysDifference, greaterThan(0));
    });
  });
}
