import 'package:flutter_test/flutter_test.dart';
import 'package:datemath/core/services/work_calendar_service.dart';
import 'package:datemath/core/models/custom_holiday.dart';

void main() {
  late WorkCalendarService service;

  setUp(() {
    service = const WorkCalendarService();
  });

  group('WorkCalendarService - countBusinessDays', () {
    test('standard Monday to Friday inclusive returns 5 business days', () {
      final start = DateTime(2026, 10, 5); // Monday
      final end = DateTime(2026, 10, 9); // Friday

      final result = service.countBusinessDays(
        start: start,
        end: end,
        includeEndDate: true,
      );

      expect(result.businessDays, 5);
      expect(result.weekendDays, 0);
      expect(result.holidayDays, 0);
      expect(result.totalDays, 5);
    });

    test('standard 2-week period with default Sat/Sun weekend', () {
      final start = DateTime(2026, 10, 5); // Monday
      final end = DateTime(2026, 10, 18); // Sunday (14 days inclusive)

      final result = service.countBusinessDays(
        start: start,
        end: end,
        includeEndDate: true,
      );

      expect(result.totalDays, 14);
      expect(result.weekendDays, 4); // 2 Saturdays + 2 Sundays
      expect(result.businessDays, 10);
    });

    test('custom Friday and Saturday weekend', () {
      final start = DateTime(2026, 10, 5); // Monday
      final end = DateTime(2026, 10, 11); // Sunday (7 days inclusive)

      final result = service.countBusinessDays(
        start: start,
        end: end,
        weekendDays: {DateTime.friday, DateTime.saturday},
        includeEndDate: true,
      );

      expect(result.totalDays, 7);
      expect(result.weekendDays, 2); // Fri, Sat
      expect(result.businessDays, 5); // Mon, Tue, Wed, Thu, Sun
    });

    test('excludes holiday falling on a business day', () {
      final start = DateTime(2026, 10, 5); // Monday
      final end = DateTime(2026, 10, 9); // Friday

      final holiday = CustomHoliday(
        id: 'h-test',
        name: 'Test Holiday',
        date: DateTime(2026, 10, 7), // Wednesday
      );

      final result = service.countBusinessDays(
        start: start,
        end: end,
        holidays: [holiday],
        includeEndDate: true,
      );

      expect(result.businessDays, 4);
      expect(result.holidayDays, 1);
      expect(result.weekendDays, 0);
    });

    test('holiday falling on a weekend is not double-counted', () {
      final start = DateTime(2026, 10, 5); // Monday
      final end = DateTime(2026, 10, 11); // Sunday

      final weekendHoliday = CustomHoliday(
        id: 'h-weekend',
        name: 'Weekend Holiday',
        date: DateTime(2026, 10, 10), // Saturday
      );

      final result = service.countBusinessDays(
        start: start,
        end: end,
        holidays: [weekendHoliday],
        includeEndDate: true,
      );

      expect(result.weekendDays, 2);
      expect(result.holidayDays, 0); // Not counted as business day holiday reduction
      expect(result.businessDays, 5);
    });

    test('handles reversed dates gracefully with isReversed flag', () {
      final start = DateTime(2026, 10, 9);
      final end = DateTime(2026, 10, 5);

      final result = service.countBusinessDays(
        start: start,
        end: end,
        includeEndDate: true,
      );

      expect(result.businessDays, 5);
      expect(result.isReversed, true);
    });
  });

  group('WorkCalendarService - addBusinessDays', () {
    test('adding 5 business days from Monday lands on next Monday', () {
      final start = DateTime(2026, 10, 5); // Monday
      final result = service.addBusinessDays(
        start: start,
        days: 5,
      );

      expect(result.targetDate, DateTime(2026, 10, 12)); // Next Monday
      expect(result.weekendDaysSkipped, 2);
      expect(result.holidaysSkipped, 0);
    });

    test('subtracting 5 business days from Monday lands on previous Monday', () {
      final start = DateTime(2026, 10, 12); // Monday
      final result = service.addBusinessDays(
        start: start,
        days: -5,
      );

      expect(result.targetDate, DateTime(2026, 10, 5));
      expect(result.weekendDaysSkipped, 2);
    });

    test('skips holiday while adding business days', () {
      final start = DateTime(2026, 10, 5); // Monday
      final holiday = CustomHoliday(
        id: 'h1',
        name: 'Wed Off',
        date: DateTime(2026, 10, 7), // Wednesday
      );

      final result = service.addBusinessDays(
        start: start,
        days: 5,
        holidays: [holiday],
      );

      // Mon, Tue, (Wed holiday), Thu, Fri, (Sat, Sun weekend), Mon = 5 business days
      expect(result.targetDate, DateTime(2026, 10, 13)); // Tuesday
      expect(result.holidaysSkipped, 1);
      expect(result.weekendDaysSkipped, 2);
    });
  });
}
