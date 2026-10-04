# Design Document: Release 6 (Astronomical)

**Date:** 2026-10-04  
**Release Version:** `2.1.0+4` (Release 6: Astronomical)  
**Status:** Approved  

---

## 1. Executive Summary & Intent
DateMath is delivering its sixth and final product roadmap release: **Release 6: ASTRONOMICAL**.
This introduces offline astronomical and solar-lunar calculations to DateMath, expanding the application from 11 tools to **14 tools** with dedicated cards on the home dashboard under a new **`Astronomy (3)`** category filter chip.

---

## 2. Core Architectural Principles

1. **Strict Offline Guarantee:**
   - 0 internet permissions (`android.permission.INTERNET` remains omitted).
   - 0 network dependencies or API calls.
   - 100% offline pure analytical formulas (Meeus astronomical algorithms) accurate within minutes.
2. **Pure Dart Engines:**
   - All astronomical calculations reside in `AstronomicalService` with zero Flutter UI imports, ensuring fast, deterministic unit test coverage.
3. **Consistent UI & History Integration:**
   - Follows Material 3 styling and existing widget patterns (`ResultCard`, `DateSelectorTile`, stepper fields).
   - Calculations integrate with `HistoryController` for local persistence.

---

## 3. Detailed Specifications

### 3.1 Domain Service & Engine (`lib/core/services/astronomical_service.dart`)
1. **Julian Date & Day-of-Year Milestones:**
   - Computes standard continuous Julian Date (`JD`) and Modified Julian Date (`MJD = JD - 2400000.5`).
   - Computes Julian Day Number (`JDN`).
   - Computes Day of Year progress (Day $N$ of 365/366, percentage of year complete, days left in year).
   - Generates annual milestones: Day 50, Day 100, Mid-Year Point (Day 182/183), Day 200, Day 250, Day 300, 100 Days Left, and quarter transitions.
2. **Moon Phase Engine:**
   - Determines moon age (0 to 29.53 days), illuminated percentage ($0.0\%$ to $100.0\%$), and 8 discrete lunar phases:
     - New Moon, Waxing Crescent, First Quarter, Waxing Gibbous, Full Moon, Waning Gibbous, Last Quarter, Waning Crescent.
   - Calculates the upcoming primary phases (Next New Moon, First Quarter, Full Moon, Last Quarter) with exact target dates and countdowns.
3. **Solar Events (Equinoxes & Solstices):**
   - High-precision polynomial series for the 4 cardinal solar points of any year (1900–2100):
     - March Equinox (Vernal Equinox)
     - June Solstice (Summer Solstice)
     - September Equinox (Autumnal Equinox)
     - December Solstice (Winter Solstice)
   - Provides UTC and local times, hemisphere context, and live countdown / elapsed days.

### 3.2 UI Screens (`lib/features/`)
1. **Moon Phases Screen (`lib/features/moon_phases/moon_phases_screen.dart`):**
   - Interactive date selector.
   - Hero visual card showing lunar phase name, illumination meter, lunar age, and waxing/waning badge.
   - Upcoming primary phases list with target dates and countdowns.
2. **Equinox & Solstice Screen (`lib/features/equinox_solstice/equinox_solstice_screen.dart`):**
   - Year selector with increment/decrement stepper and quick reset to current year.
   - 4 seasonal event cards with exact local times and countdowns.
3. **Julian & Milestones Screen (`lib/features/julian_milestones/julian_milestones_screen.dart`):**
   - Date and time picker.
   - JD and MJD cards with copy-to-clipboard actions.
   - Year progress percentage bar and upcoming milestone timeline.

### 3.3 Home Dashboard Updates (`lib/features/home/home_screen.dart`)
- Updated filter chips: `All (14)`, `Date Tools (4)`, `Time & Convert (4)`, `Work & Planning (3)`, `Astronomy (3)`.
- 3 new tool tiles with distinct astronomy icons and colors:
  - Moon Phases (`Icons.nightlight_round`, `Colors.amber.shade800`)
  - Equinox & Solstice (`Icons.wb_sunny_rounded`, `Colors.deepOrange.shade500`)
  - Julian & Year Milestones (`Icons.auto_awesome_rounded`, `Colors.indigo.shade400`)

---

## 4. Testing & Quality Verification

1. **Unit Tests (`test/astronomical_service_test.dart`):**
   - Validates Julian dates against known historical standard epochs.
   - Validates moon phase illumination and primary phase transitions.
   - Validates equinox and solstice calculations against astronomical almanacs.
2. **Widget Tests (`test/widget_test.dart`):**
   - Verifies dashboard renders all 14 tools and all 5 category chips.
   - Verifies navigation to the 3 new astronomical screens.
3. **Quality Gate:**
   - `flutter analyze`: 0 warnings, 0 errors.
   - `flutter test`: 100% passing tests.
