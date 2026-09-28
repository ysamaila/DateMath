# Design Document: Unified Release 2.0.0 (Work, History & Recurrence)

**Date:** 2026-09-28  
**Release Version:** `2.0.0+3`  
**Status:** Approved  

---

## 1. Executive Summary & Intent
DateMath is combining three planned roadmap milestones (**Release 3: Work & Calendar**, **Release 4: History & Presets**, and **Release 5: Recurrence**) into a single, high-impact major release: **Version 2.0.0 (`WORK, HISTORY & RECURRENCE`)**.

This expands DateMath from 8 tools to 11 calculators and introduces a global, offline calculation history and favorites system.

---

## 2. Core Architectural Principles

1. **Strict Offline Guarantee:**
   - 0 internet permissions (`android.permission.INTERNET` remains excluded).
   - 0 third-party network SDKs or analytics.
   - All persistence stored locally using `shared_preferences` and local JSON serialization.
2. **Pure Dart Engines:**
   - Business days math, recurrence calculations, and milestone algorithms reside in pure Dart service classes with zero Flutter UI imports, enabling 100% fast, deterministic unit test coverage.
3. **Reactive Local State:**
   - Lightweight `ChangeNotifier` state controllers (`HistoryController`, `HolidayController`) matching the existing `ThemeController` pattern.

---

## 3. Detailed Specifications

### 3.1 Domain Services & Engines
1. **`WorkCalendarService`** (`lib/core/services/work_calendar_service.dart`):
   - Computes working days between two dates, accurately excluding weekends and holidays.
   - Adds or subtracts *N* working days from a starting date.
   - Supports custom weekend definitions (`Set<int>` weekdays, e.g. `{DateTime.saturday, DateTime.sunday}` or `{DateTime.friday, DateTime.saturday}`).
   - Filters out observed holidays.
2. **`HolidaysData`** (`lib/core/data/holidays_data.dart`):
   - Offline catalog of regional holiday presets (International, United States, United Kingdom, Canada, Nigeria).
   - Data model `CustomHoliday` for user-defined recurring or one-off organization holidays.
3. **`RecurrenceService`** (`lib/core/services/recurrence_service.dart`):
   - Evaluates repeating schedule patterns:
     - Daily (`every N days`)
     - Weekly (`every N weeks` on selected active days of week)
     - Monthly by day (`day X of every N months`)
     - Monthly by weekday rule (`e.g., 2nd Tuesday of every N months`, `last Friday of every month`)
     - Yearly (`every N years`)
   - Generates sorted list of occurrences with relative countdowns and ISO week numbers.
4. **`MilestoneService`** (`lib/core/services/milestone_service.dart`):
   - Calculates time remaining / elapsed, completion percentage (0.0 to 1.0), calendar days remaining, and business days remaining.
5. **`HistoryService`** (`lib/core/services/history_service.dart`):
   - Records calculation logs with tool name, icon identifier, timestamp, input summary, and output summary.
   - FIFO cap of 100 entries for zero performance degradation.
   - Favorite toggling and export formatted text.

### 3.2 Screens & UI Components
1. **Home Dashboard Updates (`lib/features/home/`)**:
   - Filter chips: `All (11)`, `Date Tools (4)`, `Time & Convert (4)`, `Work & Planning (3)`.
   - Top AppBar action: `Icons.history_rounded` button to navigate to History & Presets.
2. **Business Days Calculator (`lib/features/business_days/`)**:
   - Tab 1: **Between Dates** (working days calculation).
   - Tab 2: **Add/Subtract Working Days**.
   - Interactive weekend selector chips (`M`, `T`, `W`, `T`, `F`, `S`, `S`).
   - Regional holiday preset selector + custom holiday management dialog.
   - Breakdown card: working days, weekend days, holidays, total days, % working.
3. **Milestone Countdown (`lib/features/milestone_countdown/`)**:
   - Milestone title input, start date, target date.
   - Quick presets: Next Month, End of Quarter, End of Year, 100 Days.
   - Visual progress bar, hero countdown card, working days countdown.
4. **Recurrence Planner (`lib/features/recurrence_planner/`)**:
   - Frequency picker, interval stepper, weekday picker, monthly rule builder.
   - Occurrence count limit (10, 25, 50) or end date.
   - Scrollable timeline of upcoming occurrences with copy button.
5. **History & Presets (`lib/features/history_presets/`)**:
   - Tabs: **All History** and **Favorites**.
   - Filter by tool category.
   - Copy calculation receipt button, favorite star button, clear all action.

---

## 4. Testing & Verification

1. **Unit Tests**:
   - `test/work_calendar_test.dart`
   - `test/recurrence_test.dart`
   - `test/history_test.dart`
2. **Integration / Widget Tests**:
   - `test/widget_test.dart` updated for 11 tools, navigation to all 3 new screens, and history screen.
3. **Build & Quality Verification**:
   - `flutter analyze`: 0 warnings, 0 errors.
   - `flutter test`: 100% pass.
