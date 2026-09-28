import 'package:flutter_test/flutter_test.dart';
import 'package:datemath/core/models/custom_holiday.dart';
import 'package:datemath/core/models/history_item.dart';
import 'package:datemath/core/data/holidays_data.dart';

void main() {
  group('CustomHoliday model', () {
    test('serializes and deserializes to/from JSON correctly', () {
      final holiday = CustomHoliday(
        id: 'h-1',
        name: 'Company Foundation Day',
        date: DateTime(2026, 10, 15),
        isRecurringYearly: true,
      );

      final json = holiday.toJson();
      final restored = CustomHoliday.fromJson(json);

      expect(restored.id, 'h-1');
      expect(restored.name, 'Company Foundation Day');
      expect(restored.date, DateTime(2026, 10, 15));
      expect(restored.isRecurringYearly, true);
    });

    test('matchesDate matches same day/month when recurring', () {
      final holiday = CustomHoliday(
        id: 'h-2',
        name: 'Annual Day',
        date: DateTime(2020, 5, 20),
        isRecurringYearly: true,
      );

      expect(holiday.matchesDate(DateTime(2026, 5, 20)), isTrue);
      expect(holiday.matchesDate(DateTime(2026, 5, 21)), isFalse);
    });

    test('matchesDate matches exact date when not recurring', () {
      final holiday = CustomHoliday(
        id: 'h-3',
        name: 'One-off Holiday',
        date: DateTime(2026, 8, 12),
        isRecurringYearly: false,
      );

      expect(holiday.matchesDate(DateTime(2026, 8, 12)), isTrue);
      expect(holiday.matchesDate(DateTime(2027, 8, 12)), isFalse);
    });
  });

  group('HistoryItem model', () {
    test('serializes and deserializes to/from JSON correctly', () {
      final now = DateTime(2026, 9, 28, 15, 30);
      final item = HistoryItem(
        id: 'calc-101',
        toolName: 'Business Days',
        category: 'Work & Planning',
        title: 'Q4 Working Days',
        resultSummary: '64 working days',
        timestamp: now,
        isFavorite: false,
      );

      final json = item.toJson();
      final restored = HistoryItem.fromJson(json);

      expect(restored.id, 'calc-101');
      expect(restored.toolName, 'Business Days');
      expect(restored.category, 'Work & Planning');
      expect(restored.title, 'Q4 Working Days');
      expect(restored.resultSummary, '64 working days');
      expect(restored.timestamp, now);
      expect(restored.isFavorite, false);
    });

    test('copyWith updates fields correctly', () {
      final item = HistoryItem(
        id: 'calc-1',
        toolName: 'Age Calculator',
        category: 'Date Tools',
        title: 'Age calculation',
        resultSummary: '28 years, 4 months',
        timestamp: DateTime(2026, 1, 1),
        isFavorite: false,
      );

      final favorited = item.copyWith(isFavorite: true);
      expect(favorited.isFavorite, true);
      expect(favorited.title, 'Age calculation');
    });
  });

  group('HolidaysData regional presets', () {
    test('contains available regions', () {
      expect(HolidaysData.regions.length, greaterThanOrEqualTo(5));
      expect(HolidaysData.regions.contains('United States'), isTrue);
      expect(HolidaysData.regions.contains('United Kingdom'), isTrue);
      expect(HolidaysData.regions.contains('Canada'), isTrue);
      expect(HolidaysData.regions.contains('Nigeria'), isTrue);
      expect(HolidaysData.regions.contains('International'), isTrue);
    });

    test('retrieves holidays for United States', () {
      final usHolidays = HolidaysData.getHolidaysForRegion('United States', 2026);
      expect(usHolidays.isNotEmpty, isTrue);
      // New Year's Day
      expect(usHolidays.any((h) => h.date.month == 1 && h.date.day == 1), isTrue);
      // Independence Day
      expect(usHolidays.any((h) => h.date.month == 7 && h.date.day == 4), isTrue);
      // Christmas Day
      expect(usHolidays.any((h) => h.date.month == 12 && h.date.day == 25), isTrue);
    });
  });
}
