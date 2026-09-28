import 'package:flutter_test/flutter_test.dart';
import 'package:datemath/core/services/recurrence_service.dart';

void main() {
  late RecurrenceService service;

  setUp(() {
    service = const RecurrenceService();
  });

  group('RecurrenceService - Daily', () {
    test('generates occurrences every 3 days', () {
      final start = DateTime(2026, 10, 1);
      final pattern = RecurrencePattern(
        frequency: RecurrenceFrequency.daily,
        interval: 3,
      );

      final occurrences = service.generateOccurrences(
        startDate: start,
        pattern: pattern,
        count: 4,
      );

      expect(occurrences.length, 4);
      expect(occurrences[0].date, DateTime(2026, 10, 1));
      expect(occurrences[1].date, DateTime(2026, 10, 4));
      expect(occurrences[2].date, DateTime(2026, 10, 7));
      expect(occurrences[3].date, DateTime(2026, 10, 10));
    });
  });

  group('RecurrenceService - Weekly', () {
    test('generates occurrences on specified weekdays (Mon & Wed)', () {
      // 2026-10-05 is Monday
      final start = DateTime(2026, 10, 5);
      final pattern = RecurrencePattern(
        frequency: RecurrenceFrequency.weekly,
        interval: 1,
        weekdays: {DateTime.monday, DateTime.wednesday},
      );

      final occurrences = service.generateOccurrences(
        startDate: start,
        pattern: pattern,
        count: 4,
      );

      expect(occurrences.length, 4);
      expect(occurrences[0].date, DateTime(2026, 10, 5)); // Mon
      expect(occurrences[1].date, DateTime(2026, 10, 7)); // Wed
      expect(occurrences[2].date, DateTime(2026, 10, 12)); // Mon
      expect(occurrences[3].date, DateTime(2026, 10, 14)); // Wed
    });

    test('bi-weekly interval skips alternate weeks', () {
      final start = DateTime(2026, 10, 2); // Friday
      final pattern = RecurrencePattern(
        frequency: RecurrenceFrequency.weekly,
        interval: 2,
        weekdays: {DateTime.friday},
      );

      final occurrences = service.generateOccurrences(
        startDate: start,
        pattern: pattern,
        count: 3,
      );

      expect(occurrences.length, 3);
      expect(occurrences[0].date, DateTime(2026, 10, 2));
      expect(occurrences[1].date, DateTime(2026, 10, 16));
      expect(occurrences[2].date, DateTime(2026, 10, 30));
    });
  });

  group('RecurrenceService - Monthly', () {
    test('generates occurrences on day of month with month-end clamping', () {
      final start = DateTime(2026, 1, 31);
      final pattern = RecurrencePattern(
        frequency: RecurrenceFrequency.monthlyByDay,
        interval: 1,
        dayOfMonth: 31,
      );

      final occurrences = service.generateOccurrences(
        startDate: start,
        pattern: pattern,
        count: 4,
      );

      expect(occurrences.length, 4);
      expect(occurrences[0].date, DateTime(2026, 1, 31));
      expect(occurrences[1].date, DateTime(2026, 2, 28)); // 2026 is non-leap
      expect(occurrences[2].date, DateTime(2026, 3, 31));
      expect(occurrences[3].date, DateTime(2026, 4, 30));
    });

    test('generates occurrences on 2nd Tuesday of every month', () {
      final start = DateTime(2026, 10, 1);
      final pattern = RecurrencePattern(
        frequency: RecurrenceFrequency.monthlyByWeekday,
        interval: 1,
        monthlyOrdinal: 2,
        monthlyWeekday: DateTime.tuesday,
      );

      final occurrences = service.generateOccurrences(
        startDate: start,
        pattern: pattern,
        count: 3,
      );

      expect(occurrences.length, 3);
      // Oct 2026: 1st Tue is Oct 6, 2nd Tue is Oct 13
      expect(occurrences[0].date, DateTime(2026, 10, 13));
      // Nov 2026: 1st Tue is Nov 3, 2nd Tue is Nov 10
      expect(occurrences[1].date, DateTime(2026, 11, 10));
      // Dec 2026: 1st Tue is Dec 1, 2nd Tue is Dec 8
      expect(occurrences[2].date, DateTime(2026, 12, 8));
    });

    test('generates occurrences on last Friday of every month', () {
      final start = DateTime(2026, 10, 1);
      final pattern = RecurrencePattern(
        frequency: RecurrenceFrequency.monthlyByWeekday,
        interval: 1,
        monthlyOrdinal: -1, // Last
        monthlyWeekday: DateTime.friday,
      );

      final occurrences = service.generateOccurrences(
        startDate: start,
        pattern: pattern,
        count: 2,
      );

      expect(occurrences.length, 2);
      expect(occurrences[0].date, DateTime(2026, 10, 30));
      expect(occurrences[1].date, DateTime(2026, 11, 27));
    });
  });

  group('RecurrenceService - Yearly', () {
    test('generates annual occurrences', () {
      final start = DateTime(2026, 4, 15);
      final pattern = RecurrencePattern(
        frequency: RecurrenceFrequency.yearly,
        interval: 1,
      );

      final occurrences = service.generateOccurrences(
        startDate: start,
        pattern: pattern,
        count: 3,
      );

      expect(occurrences.length, 3);
      expect(occurrences[0].date, DateTime(2026, 4, 15));
      expect(occurrences[1].date, DateTime(2027, 4, 15));
      expect(occurrences[2].date, DateTime(2028, 4, 15));
    });
  });
}
