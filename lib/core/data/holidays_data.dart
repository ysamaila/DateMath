import '../models/custom_holiday.dart';

class HolidaysData {
  static const List<String> regions = [
    'United States',
    'United Kingdom',
    'Canada',
    'Nigeria',
    'International',
  ];

  static List<CustomHoliday> getHolidaysForRegion(String region, int year) {
    switch (region) {
      case 'United States':
        return [
          CustomHoliday(
            id: 'us_new_year_$year',
            name: "New Year's Day",
            date: DateTime(year, 1, 1),
          ),
          CustomHoliday(
            id: 'us_mlk_$year',
            name: 'Martin Luther King Jr. Day',
            date: _getNthWeekdayOfMonth(year, 1, DateTime.monday, 3),
          ),
          CustomHoliday(
            id: 'us_presidents_$year',
            name: "Presidents' Day",
            date: _getNthWeekdayOfMonth(year, 2, DateTime.monday, 3),
          ),
          CustomHoliday(
            id: 'us_memorial_$year',
            name: 'Memorial Day',
            date: _getLastWeekdayOfMonth(year, 5, DateTime.monday),
          ),
          CustomHoliday(
            id: 'us_juneteenth_$year',
            name: 'Juneteenth National Independence Day',
            date: DateTime(year, 6, 19),
          ),
          CustomHoliday(
            id: 'us_independence_$year',
            name: 'Independence Day',
            date: DateTime(year, 7, 4),
          ),
          CustomHoliday(
            id: 'us_labor_$year',
            name: 'Labor Day',
            date: _getNthWeekdayOfMonth(year, 9, DateTime.monday, 1),
          ),
          CustomHoliday(
            id: 'us_columbus_$year',
            name: 'Columbus Day',
            date: _getNthWeekdayOfMonth(year, 10, DateTime.monday, 2),
          ),
          CustomHoliday(
            id: 'us_veterans_$year',
            name: 'Veterans Day',
            date: DateTime(year, 11, 11),
          ),
          CustomHoliday(
            id: 'us_thanksgiving_$year',
            name: 'Thanksgiving Day',
            date: _getNthWeekdayOfMonth(year, 11, DateTime.thursday, 4),
          ),
          CustomHoliday(
            id: 'us_christmas_$year',
            name: 'Christmas Day',
            date: DateTime(year, 12, 25),
          ),
        ];

      case 'United Kingdom':
        return [
          CustomHoliday(
            id: 'uk_new_year_$year',
            name: "New Year's Day",
            date: DateTime(year, 1, 1),
          ),
          CustomHoliday(
            id: 'uk_early_may_$year',
            name: 'Early May Bank Holiday',
            date: _getNthWeekdayOfMonth(year, 5, DateTime.monday, 1),
          ),
          CustomHoliday(
            id: 'uk_spring_bank_$year',
            name: 'Spring Bank Holiday',
            date: _getLastWeekdayOfMonth(year, 5, DateTime.monday),
          ),
          CustomHoliday(
            id: 'uk_summer_bank_$year',
            name: 'Summer Bank Holiday',
            date: _getLastWeekdayOfMonth(year, 8, DateTime.monday),
          ),
          CustomHoliday(
            id: 'uk_christmas_$year',
            name: 'Christmas Day',
            date: DateTime(year, 12, 25),
          ),
          CustomHoliday(
            id: 'uk_boxing_$year',
            name: 'Boxing Day',
            date: DateTime(year, 12, 26),
          ),
        ];

      case 'Canada':
        return [
          CustomHoliday(
            id: 'ca_new_year_$year',
            name: "New Year's Day",
            date: DateTime(year, 1, 1),
          ),
          CustomHoliday(
            id: 'ca_victoria_$year',
            name: 'Victoria Day',
            date: _getMondayBeforeMay25(year),
          ),
          CustomHoliday(
            id: 'ca_canada_day_$year',
            name: 'Canada Day',
            date: DateTime(year, 7, 1),
          ),
          CustomHoliday(
            id: 'ca_civic_$year',
            name: 'Civic Holiday',
            date: _getNthWeekdayOfMonth(year, 8, DateTime.monday, 1),
          ),
          CustomHoliday(
            id: 'ca_labour_$year',
            name: 'Labour Day',
            date: _getNthWeekdayOfMonth(year, 9, DateTime.monday, 1),
          ),
          CustomHoliday(
            id: 'ca_thanksgiving_$year',
            name: 'Thanksgiving',
            date: _getNthWeekdayOfMonth(year, 10, DateTime.monday, 2),
          ),
          CustomHoliday(
            id: 'ca_remembrance_$year',
            name: 'Remembrance Day',
            date: DateTime(year, 11, 11),
          ),
          CustomHoliday(
            id: 'ca_christmas_$year',
            name: 'Christmas Day',
            date: DateTime(year, 12, 25),
          ),
          CustomHoliday(
            id: 'ca_boxing_$year',
            name: 'Boxing Day',
            date: DateTime(year, 12, 26),
          ),
        ];

      case 'Nigeria':
        return [
          CustomHoliday(
            id: 'ng_new_year_$year',
            name: "New Year's Day",
            date: DateTime(year, 1, 1),
          ),
          CustomHoliday(
            id: 'ng_workers_$year',
            name: "Workers' Day",
            date: DateTime(year, 5, 1),
          ),
          CustomHoliday(
            id: 'ng_democracy_$year',
            name: 'Democracy Day',
            date: DateTime(year, 6, 12),
          ),
          CustomHoliday(
            id: 'ng_independence_$year',
            name: 'Independence Day',
            date: DateTime(year, 10, 1),
          ),
          CustomHoliday(
            id: 'ng_christmas_$year',
            name: 'Christmas Day',
            date: DateTime(year, 12, 25),
          ),
          CustomHoliday(
            id: 'ng_boxing_$year',
            name: 'Boxing Day',
            date: DateTime(year, 12, 26),
          ),
        ];

      case 'International':
      default:
        return [
          CustomHoliday(
            id: 'intl_new_year_$year',
            name: "New Year's Day",
            date: DateTime(year, 1, 1),
          ),
          CustomHoliday(
            id: 'intl_womens_day_$year',
            name: "International Women's Day",
            date: DateTime(year, 3, 8),
          ),
          CustomHoliday(
            id: 'intl_labour_day_$year',
            name: 'International Labour Day',
            date: DateTime(year, 5, 1),
          ),
          CustomHoliday(
            id: 'intl_environment_$year',
            name: 'World Environment Day',
            date: DateTime(year, 6, 5),
          ),
          CustomHoliday(
            id: 'intl_peace_$year',
            name: 'International Day of Peace',
            date: DateTime(year, 9, 21),
          ),
          CustomHoliday(
            id: 'intl_human_rights_$year',
            name: 'Human Rights Day',
            date: DateTime(year, 12, 10),
          ),
          CustomHoliday(
            id: 'intl_christmas_$year',
            name: 'Christmas Day',
            date: DateTime(year, 12, 25),
          ),
        ];
    }
  }

  static DateTime _getNthWeekdayOfMonth(
      int year, int month, int targetWeekday, int nth) {
    var date = DateTime(year, month, 1);
    var count = 0;
    while (date.month == month) {
      if (date.weekday == targetWeekday) {
        count++;
        if (count == nth) return date;
      }
      date = date.add(const Duration(days: 1));
    }
    return DateTime(year, month, 1);
  }

  static DateTime _getLastWeekdayOfMonth(
      int year, int month, int targetWeekday) {
    // Start at last day of month
    var date = DateTime(year, month + 1, 0);
    while (date.month == month) {
      if (date.weekday == targetWeekday) {
        return date;
      }
      date = date.subtract(const Duration(days: 1));
    }
    return DateTime(year, month, 1);
  }

  static DateTime _getMondayBeforeMay25(int year) {
    var date = DateTime(year, 5, 24);
    while (date.weekday != DateTime.monday) {
      date = date.subtract(const Duration(days: 1));
    }
    return date;
  }
}
