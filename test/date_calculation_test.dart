import 'package:flutter_test/flutter_test.dart';
import 'package:datemath/core/services/date_calculation_service.dart';

void main() {
  group('DateCalculationService - Leap Year & Month Days', () {
    test('isLeapYear identifies leap years correctly', () {
      expect(DateCalculationService.isLeapYear(2024), isTrue);
      expect(DateCalculationService.isLeapYear(2020), isTrue);
      expect(DateCalculationService.isLeapYear(2000), isTrue); // divisible by 400
      expect(DateCalculationService.isLeapYear(2023), isFalse);
      expect(DateCalculationService.isLeapYear(1900), isFalse); // century rule
      expect(DateCalculationService.isLeapYear(2100), isFalse);
    });

    test('daysInMonth returns exact days including leap February', () {
      expect(DateCalculationService.daysInMonth(2024, 1), 31);
      expect(DateCalculationService.daysInMonth(2024, 2), 29);
      expect(DateCalculationService.daysInMonth(2023, 2), 28);
      expect(DateCalculationService.daysInMonth(2024, 4), 30);
      expect(DateCalculationService.daysInMonth(2024, 12), 31);
    });
  });

  group('DateCalculationService - Date Difference', () {
    test('Same date difference (exclusive vs inclusive)', () {
      final d = DateTime.utc(2024, 6, 15);
      final exclusive = DateCalculationService.calculateDifference(d, d, includeEndDate: false);
      expect(exclusive.totalDays, 0);
      expect(exclusive.years, 0);
      expect(exclusive.months, 0);
      expect(exclusive.days, 0);

      final inclusive = DateCalculationService.calculateDifference(d, d, includeEndDate: true);
      expect(inclusive.totalDays, 1);
      expect(inclusive.days, 1);
    });

    test('One month difference', () {
      final start = DateTime.utc(2024, 1, 1);
      final end = DateTime.utc(2024, 2, 1);
      final diff = DateCalculationService.calculateDifference(start, end);
      expect(diff.totalDays, 31);
      expect(diff.totalWeeks, 4);
      expect(diff.remainingDays, 3);
      expect(diff.months, 1);
      expect(diff.days, 0);
      expect(diff.formattedWeeksDays, '4 weeks, 3 days');
      expect(diff.formattedBreakdown, '1 month');
    });

    test('Full leap year difference', () {
      final start = DateTime.utc(2024, 1, 1);
      final end = DateTime.utc(2025, 1, 1);
      final diff = DateCalculationService.calculateDifference(start, end);
      expect(diff.totalDays, 366);
      expect(diff.years, 1);
      expect(diff.months, 0);
      expect(diff.days, 0);
    });

    test('Reversed date difference marks isNegative', () {
      final start = DateTime.utc(2024, 5, 20);
      final end = DateTime.utc(2024, 5, 10);
      final diff = DateCalculationService.calculateDifference(start, end);
      expect(diff.isNegative, isTrue);
      expect(diff.totalDays, -10);
      expect(diff.days, 10);
    });
  });

  group('DateCalculationService - Add & Subtract Date', () {
    test('Clamps end-of-month dates in leap year (Jan 31 + 1 month = Feb 29)', () {
      final base = DateTime.utc(2024, 1, 31);
      final result = DateCalculationService.addOrSubtractDate(base, months: 1);
      expect(result.resultDate, DateTime.utc(2024, 2, 29));
    });

    test('Clamps end-of-month dates in non-leap year (Jan 31 + 1 month = Feb 28)', () {
      final base = DateTime.utc(2023, 1, 31);
      final result = DateCalculationService.addOrSubtractDate(base, months: 1);
      expect(result.resultDate, DateTime.utc(2023, 2, 28));
    });

    test('Subtracting years and months', () {
      final base = DateTime.utc(2024, 6, 15);
      final result = DateCalculationService.addOrSubtractDate(
        base,
        years: 1,
        months: 2,
        isSubtract: true,
      );
      expect(result.resultDate, DateTime.utc(2023, 4, 15));
    });

    test('Adding weeks and days', () {
      final base = DateTime.utc(2024, 1, 1);
      final result = DateCalculationService.addOrSubtractDate(
        base,
        weeks: 2,
        days: 3,
      );
      // 14 + 3 = 17 days
      expect(result.resultDate, DateTime.utc(2024, 1, 18));
    });
  });

  group('DateCalculationService - Age Calculator', () {
    test('Calculates exact age in years, months, days', () {
      final birth = DateTime.utc(2000, 1, 1);
      final asOf = DateTime.utc(2024, 1, 1);
      final age = DateCalculationService.calculateAge(birth, asOf: asOf);

      expect(age.years, 24);
      expect(age.months, 0);
      expect(age.days, 0);
      expect(age.totalDaysLived, 8766); // includes leap years 2000, 2004, 2008, 2012, 2016, 2020
      expect(age.daysToNextBirthday, 0);
    });

    test('Handles next birthday in the future of the same year', () {
      final birth = DateTime.utc(2000, 10, 15);
      final asOf = DateTime.utc(2024, 3, 1);
      final age = DateCalculationService.calculateAge(birth, asOf: asOf);

      expect(age.years, 23);
      expect(age.nextBirthday, DateTime.utc(2024, 10, 15));
      expect(age.daysToNextBirthday, 228);
    });

    test('Handles leap day baby (Feb 29)', () {
      final birth = DateTime.utc(2004, 2, 29);
      final asOf = DateTime.utc(2023, 1, 1); // 2023 is not a leap year
      final age = DateCalculationService.calculateAge(birth, asOf: asOf);

      expect(age.isBornOnLeapDay, isTrue);
      // In 2023, next birthday celebrated Feb 28
      expect(age.nextBirthday, DateTime.utc(2023, 2, 28));
    });
  });

  group('DateCalculationService - Day Finder & Today Overview', () {
    test('Identifies day of week and day of year', () {
      // 2024-01-01 was a Monday
      final res = DateCalculationService.findDayDetails(DateTime.utc(2024, 1, 1));
      expect(res.weekdayName, 'Monday');
      expect(res.dayOfYear, 1);
      expect(res.daysRemainingInYear, 365);
      expect(res.isLeapYear, isTrue);
      expect(res.quarter, 1);
      expect(res.isoWeekNumber, 1);
    });

    test('Today Overview produces valid metrics', () {
      final overview = DateCalculationService.getTodayOverview(
        date: DateTime.utc(2024, 7, 2),
      );
      expect(overview.isLeapYear, isTrue);
      expect(overview.totalDaysInYear, 366);
      expect(overview.quarter, 3);
      expect(overview.percentageElapsed, greaterThan(50.0));
    });
  });
}
