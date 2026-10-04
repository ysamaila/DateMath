# Release 6 (Astronomical) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Release 6 (ASTRONOMICAL) for DateMath, adding pure Dart astronomical algorithms, 3 new feature screens (Moon Phases, Equinox & Solstice, Julian & Milestones), Home dashboard integration with 14 tools, and comprehensive test coverage.

**Architecture:** A standalone pure Dart engine `AstronomicalService` calculates moon phases, equinoxes/solstices, Julian dates, and day-of-year milestones without external dependencies or internet permissions. 3 dedicated Material 3 feature screens render the calculations, integrated into the Home dashboard under an "Astronomy (3)" category filter chip.

**Tech Stack:** Flutter, Dart, Material 3, shared_preferences (for history logging), zero external network dependencies.

**Spec:** `docs/superpowers/specs/2026-10-04-astronomical-release-design.md`

## Global Constraints
- Zero Internet Permissions: `android.permission.INTERNET` remains excluded from `AndroidManifest.xml`.
- Zero Network Packages: No network dependencies.
- Pure Dart Engines: Calculation services must have zero Flutter UI dependencies.
- Material 3 Theming: Follow existing theme and widget conventions (`ResultCard`, `DateSelectorTile`, `NumberStepperField`).

---

### Task 1: Domain Service & Unit Tests (`AstronomicalService`)

**Files:**
- Create: `lib/core/services/astronomical_service.dart`
- Create: `test/astronomical_service_test.dart`

**Interfaces:**
- Produces:
  - `enum MoonPhase`
  - `class MoonPhaseInfo`
  - `class NextMoonPhase`
  - `enum SolarEventType`
  - `class SolarEvent`
  - `class JulianDateResult`
  - `class DayOfYearMilestone`
  - `static MoonPhaseInfo calculateMoonPhase(DateTime date)`
  - `static List<SolarEvent> calculateSolarEvents(int year, {DateTime? referenceNow})`
  - `static JulianDateResult calculateJulianDate(DateTime dateTime)`
  - `static List<DayOfYearMilestone> getDayOfYearMilestones(int year, {DateTime? referenceNow})`

- [ ] **Step 1: Write unit tests for AstronomicalService in `test/astronomical_service_test.dart`**
- [ ] **Step 2: Run `flutter test test/astronomical_service_test.dart` to verify failure**
- [ ] **Step 3: Implement `AstronomicalService` with Meeus algorithms in `lib/core/services/astronomical_service.dart`**
- [ ] **Step 4: Run `flutter test test/astronomical_service_test.dart` to verify all tests pass**
- [ ] **Step 5: Git commit task 1**

---

### Task 2: Moon Phases Screen (`MoonPhasesScreen`)

**Files:**
- Create: `lib/features/moon_phases/moon_phases_screen.dart`

**Interfaces:**
- Consumes: `AstronomicalService.calculateMoonPhase`
- Produces: `class MoonPhasesScreen extends StatefulWidget`

- [ ] **Step 1: Implement `MoonPhasesScreen` with interactive date selector, hero lunar phase visual, illumination progress bar, lunar age, and upcoming phase cards**
- [ ] **Step 2: Add calculation logging to `HistoryController` on date selection**
- [ ] **Step 3: Git commit task 2**

---

### Task 3: Equinox & Solstice Screen (`EquinoxSolsticeScreen`)

**Files:**
- Create: `lib/features/equinox_solstice/equinox_solstice_screen.dart`

**Interfaces:**
- Consumes: `AstronomicalService.calculateSolarEvents`
- Produces: `class EquinoxSolsticeScreen extends StatefulWidget`

- [ ] **Step 1: Implement `EquinoxSolsticeScreen` with year stepper, quick current year button, and 4 event cards showing local times, UTC times, and countdown/elapsed badges**
- [ ] **Step 2: Git commit task 3**

---

### Task 4: Julian & Day Milestones Screen (`JulianMilestonesScreen`)

**Files:**
- Create: `lib/features/julian_milestones/julian_milestones_screen.dart`

**Interfaces:**
- Consumes: `AstronomicalService.calculateJulianDate`, `AstronomicalService.getDayOfYearMilestones`
- Produces: `class JulianMilestonesScreen extends StatefulWidget`

- [ ] **Step 1: Implement `JulianMilestonesScreen` with date & time pickers, copyable JD & MJD ResultCards, year progress bar, and scrollable milestone checklist**
- [ ] **Step 2: Git commit task 4**

---

### Task 5: Home Dashboard & Widget Test Updates

**Files:**
- Modify: `lib/features/home/home_screen.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Update `home_screen.dart` to add `Astronomy (3)` filter chip, update `All (14)`, and add tool cards for Moon Phases, Equinox & Solstice, and Julian & Day Milestones**
- [ ] **Step 2: Update `test/widget_test.dart` to verify 14 tools, 5 category chips, and navigation to the 3 new astronomical screens**
- [ ] **Step 3: Run `flutter test test/widget_test.dart` and confirm all tests pass**
- [ ] **Step 4: Git commit task 5**

---

### Task 6: Release Bump, Roadmap Finalization & Full Verification

**Files:**
- Modify: `pubspec.yaml` (bump version to `2.1.0+4`)
- Modify: `AGENTS.md` (mark Release 6 as Completed)

- [ ] **Step 1: Update version in `pubspec.yaml` to `2.1.0+4`**
- [ ] **Step 2: Update `AGENTS.md` product roadmap table to mark Release 6 as Completed (`v2.1.0+4`) and add release log entry**
- [ ] **Step 3: Run `flutter analyze` to ensure 0 errors and 0 warnings**
- [ ] **Step 4: Run full `flutter test` test suite to verify 100% pass**
- [ ] **Step 5: Git commit task 6**
