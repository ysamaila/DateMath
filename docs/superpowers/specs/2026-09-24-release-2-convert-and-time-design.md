# DateMath Release 2: CONVERT & TIME — Design Specification

**Author:** Antigravity & User  
**Status:** Approved  
**Date:** 2026-09-24  
**Release:** Release 2 (CONVERT & TIME)  
**Offline Guarantee:** 100% Offline, Zero Internet Permissions, Pure Dart Calculation Engines  

---

## 1. Overview & Objectives

DateMath Release 1 (**CALCULATE**) established the offline date calculation engine (Date Difference, Add/Subtract Date, Age Calculator, Day Finder, Today Overview, and Material 3 theming).

**Release 2 (CONVERT & TIME)** expands DateMath into clock-time mathematics, duration conversions, 12h/24h military time conversions, and offline world time offset calculations.

### Core Objectives
1. **100% Offline & Private**: Zero internet permissions, zero network dependencies, 100% on-device calculations.
2. **Pure Dart Engine**: All time math, conversions, and offset logic implemented in a UI-independent pure Dart service ([`TimeCalculationService`](file:///c:/Users/User/Desktop/mobile/flutter/datemath/lib/core/services/time_calculation_service.dart)) with 100% test coverage.
3. **Four Focused Tools**:
   - **Time Math**: Clock time difference & duration addition/subtraction with overnight rollover detection.
   - **Duration Converter**: Universal cross-unit converter (milliseconds, seconds, minutes, hours, days, weeks).
   - **12h / 24h Converter**: Interactive standard to military time converter with phonetic military spoken guide.
   - **World Time Offsets**: Offline timezone offset comparator using an embedded catalog of ~60 major global cities and a custom UTC slider (-12:00 to +14:00).
4. **Enhanced Dashboard**: Material 3 dashboard navigation with quick category filter chips (`All`, `Date Tools`, `Time & Convert`).

---

## 2. Architecture & File Structure

```
datemath/
├── lib/
│   ├── core/
│   │   ├── data/
│   │   │   └── world_cities_data.dart          # Offline catalog of ~60 major cities & UTC offsets
│   │   ├── services/
│   │   │   ├── date_calculation_service.dart   # Existing Release 1 engine
│   │   │   └── time_calculation_service.dart   # New Release 2 pure Dart time engine
│   │   └── utils/
│   ├── features/
│   │   ├── home/presentation/
│   │   │   └── home_screen.dart                # Updated with category filter chips & 4 new tool cards
│   │   ├── time_math/presentation/
│   │   │   └── time_math_screen.dart           # Time Difference & Add/Subtract tabs
│   │   ├── duration_converter/presentation/
│   │   │   └── duration_converter_screen.dart  # Multi-unit live conversion grid & presets
│   │   ├── twelve_twenty_four/presentation/
│   │   │   └── twelve_twenty_four_screen.dart  # 12h <-> 24h & military spoken guide
│   │   └── world_time_offsets/presentation/
│   │       └── world_time_offsets_screen.dart  # Dual location/offset comparator & scrubbing slider
│   └── shared/widgets/
└── test/
    ├── date_calculation_test.dart              # Existing Release 1 test suite
    ├── time_calculation_test.dart              # Release 2 pure Dart calculation unit tests
    └── widget_test.dart                        # Integration & navigation widget tests
```

---

## 3. Detailed Component Specifications

### 3.1 Core Engine: `TimeCalculationService`
The service contains zero UI imports (`dart:ui` or `package:flutter`), operating purely on Dart primitives and standard library types.

#### Models
1. **`ClockTime`**:
   - `final int hour;` (0–23)
   - `final int minute;` (0–59)
   - `final int second;` (0–59)
   - Methods: `toSeconds()`, `formatted12({bool showSeconds})`, `formatted24({bool showSeconds})`, `militaryString()`.
2. **`TimeDifferenceResult`**:
   - `final int hours;`
   - `final int minutes;`
   - `final int seconds;`
   - `final int totalSeconds;`
   - `final double totalHours;`
   - `final bool isOvernight;` (indicates span crossed midnight)
   - `String get formattedDuration;` (e.g., `"7 hours, 45 minutes"`)
3. **`TimeAddSubtractResult`**:
   - `final ClockTime resultTime;`
   - `final int dayOffset;` (`0` = same day, `+1` = next day, `-1` = previous day, etc.)
   - `final bool isSubtract;`
   - `String get dayOffsetBadge;`
4. **`DurationUnit` & `DurationConversionResult`**:
   - Enum: `milliseconds`, `seconds`, `minutes`, `hours`, `days`, `weeks`.
   - Result holds exact conversion factors to all 6 units as doubles.
   - `String get compositeBreakdown;` (e.g., `"1 day, 2 hours, 15 minutes, 30 seconds"`).
5. **`MilitaryTimeResult`**:
   - `final String format12;` (e.g. `"08:30 PM"`)
   - `final String format24;` (e.g. `"20:30"`)
   - `final String militaryDesignation;` (e.g. `"2030 Hours"`)
   - `final String spokenMilitary;` (e.g. `"Twenty hundred thirty hours"`)
   - `final double dayPercentage;` (0.0 to 100.0%)
6. **`WorldTimeOffsetResult`**:
   - `final ClockTime targetTime;`
   - `final int differenceMinutes;`
   - `final String offsetDeltaLabel;` (e.g., `"+5h 30m ahead"`, `"-8h behind"`)
   - `final String relativeDay;` (`"Same day"`, `"Tomorrow"`, `"Yesterday"`)

---

### 3.2 Offline World Cities Catalog (`world_cities_data.dart`)
- Curated list of ~60 major global cities spanning all continents and offset variations (e.g., London UTC+0, Paris UTC+1, Cairo UTC+2, Dubai UTC+4, New Delhi UTC+5:30, Kathmandu UTC+5:45, Tokyo UTC+9, Adelaide UTC+9:30, Sydney UTC+10, Auckland UTC+12, Honolulu UTC-10, New York UTC-5, Los Angeles UTC-8, Buenos Aires UTC-3).
- Model:
  ```dart
  class WorldCity {
    final String name;
    final String country;
    final String continent;
    final int utcOffsetMinutes;
    final String abbreviation;
  }
  ```
- Methods:
  - `List<WorldCity> searchCities(String query)`: Case-insensitive search on city name, country, and abbreviation.
  - `List<String> get continents`: Grouping helper.

---

### 3.3 Feature Screens & UX

#### 1. Home Dashboard (`home_screen.dart`)
- **Filter Chips**: `All (8)`, `Date Tools (4)`, `Time & Convert (4)`.
- Renders the 4 Release 1 cards plus 4 new Release 2 cards:
  - **Time Math**: Amber icon `Icons.access_time_filled_rounded`.
  - **Duration Converter**: Cyan icon `Icons.swap_horiz_rounded`.
  - **12h / 24h Converter**: Purple icon `Icons.timelapse_rounded`.
  - **World Time Offsets**: Teal icon `Icons.public_rounded`.

#### 2. Time Math Screen (`time_math_screen.dart`)
- Tab Bar:
  - **Tab 1: Time Difference**:
    - Start Time tile and End Time tile (triggers Material 3 `showTimePicker`).
    - Overnight detection: Automatically recognizes when End Time is numerically earlier than Start Time and adds a "+1 Day (Overnight)" indicator.
    - Result card: Formatted primary duration, total minutes, total seconds, and decimal hours with copy-to-clipboard.
  - **Tab 2: Add / Subtract**:
    - Base Time tile.
    - Operation toggle: Add (+) / Subtract (-).
    - Stepper inputs for Hours, Minutes, Seconds.
    - Result card: Computed clock time, day shift badge (`Same day`, `+1 Day`, `-1 Day`), and 12h/24h toggle.

#### 3. Duration Converter Screen (`duration_converter_screen.dart`)
- Number input field + source unit selector (`Milliseconds`, `Seconds`, `Minutes`, `Hours`, `Days`, `Weeks`).
- Quick preset buttons (`1 hour`, `1 day`, `1 week`, `3,600s`, `86,400s`).
- Result cards:
  - Live conversions into all 5 other units simultaneously with clean number formatting.
  - Composite breakdown tile (e.g. `90,000s = 1d 1h 0m 0s`).

#### 4. 12h / 24h Military Time Screen (`twelve_twenty_four_screen.dart`)
- Interactive dual input: Time picker dial and hour/minute sliders.
- Result card displays:
  - 12-Hour format (`08:45 PM`)
  - 24-Hour military format (`20:45` / `2045 Hours`)
  - Military spoken guide (`"Twenty hundred forty-five hours"`)
  - Day progress bar and percentage (`86.5% of day passed`).
- Quick Reference Guide bottom card explaining midnight, noon, and military time conventions.

#### 5. World Time Offsets Screen (`world_time_offsets_screen.dart`)
- Base Location Card: Defaults to device local time & device UTC offset.
- Target Location Selection:
  - **City Search Bottom Sheet**: Fast offline search through the curated global city list.
  - **UTC Offset Slider**: Direct slider adjustment from `UTC-12:00` to `UTC+14:00` with 15-minute / 30-minute step accuracy.
- Comparison Result Card:
  - Target clock time in 12h and 24h formats.
  - Relative offset delta badge (`"+5h 30m ahead"`, `"-8h behind"`).
  - Relative day indicator (`Same day`, `Tomorrow (+1d)`, `Yesterday (-1d)`).
  - Time scrubbing slider: Scrub the base time to see target time react in real time.

---

## 4. Verification & Testing Plan

1. **Pure Dart Unit Tests (`test/time_calculation_test.dart`)**:
   - Complete unit coverage of all methods in `TimeCalculationService`.
   - Comprehensive boundary tests: Midnight transitions, leap seconds, negative offsets, 0-duration inputs, overnight spans, multi-day roll-overs, non-integer timezone offsets (+5:30, +5:45, +9:30).
2. **Widget Tests (`test/widget_test.dart`)**:
   - Dashboard rendering all 8 tools.
   - Filter chips filtering cards accurately.
   - Navigation push & pop verification for each new screen.
3. **Static Analysis & Build Verification**:
   - `flutter analyze`: Zero warnings, zero errors.
   - `flutter test`: 100% passing tests.
   - Verification of `android.permission.INTERNET` absence in `AndroidManifest.xml`.
