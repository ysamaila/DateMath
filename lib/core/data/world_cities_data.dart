/// Immutable offline dataset of major world cities and their standard UTC offsets.
/// 100% offline, zero network dependencies.
library;

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
