# Release 2.0.0 (Work, History & Recurrence) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the unified Release 2.0.0 for DateMath, adding Work & Calendar math, Milestone Countdowns, Recurrence Schedules, and an offline local Calculation History & Favorites system.

**Architecture:** Pure Dart domain services for zero-UI business logic (`WorkCalendarService`, `RecurrenceService`, `MilestoneService`, `HistoryService`), paired with offline local storage via `shared_preferences` (`HistoryController`, `HolidayController`). Material 3 UI screens integrating seamlessly with the dashboard.

**Tech Stack:** Flutter 3.24+, Dart 3.5+, `shared_preferences` (pure offline), Material 3.

**Spec:** `docs/superpowers/specs/2026-09-28-work-history-recurrence-release-design.md`

## Global Constraints
- **Zero Internet Permissions**: `android.permission.INTERNET` must remain absent.
- **Zero Network Packages**: No `http`, `dio`, or cloud trackers.
- **100% Offline Usability**: Fully operational in Airplane Mode.
- **Zero Analyzer Errors**: `flutter analyze` must pass with 0 errors and 0 warnings.
- **Full Test Coverage**: All domain services must have comprehensive unit tests in `test/`.

---

### Task 1: Data Models & Holiday Catalog

**Files:**
- Create: `lib/core/models/custom_holiday.dart`
- Create: `lib/core/models/history_item.dart`
- Create: `lib/core/data/holidays_data.dart`
- Test: `test/models_and_holidays_test.dart`

**Interfaces:**
- Produces: `CustomHoliday`, `HistoryItem`, `HolidaysData` (regional holiday sets: International, US, UK, CA, NG)

- [ ] **Step 1: Write the failing test for models and holiday catalog**
- [ ] **Step 2: Run test to confirm it fails**
- [ ] **Step 3: Implement `CustomHoliday`, `HistoryItem`, and `HolidaysData`**
- [ ] **Step 4: Run test to confirm it passes**
- [ ] **Step 5: Commit changes**

---

### Task 2: WorkCalendarService (Business Days Engine)

**Files:**
- Create: `lib/core/services/work_calendar_service.dart`
- Test: `test/work_calendar_test.dart`

**Interfaces:**
- Produces: `WorkCalendarService.countBusinessDays()`, `WorkCalendarService.addBusinessDays()`, `BusinessDaysResult`

- [ ] **Step 1: Write the failing unit tests for business days counting and addition**
- [ ] **Step 2: Run test to confirm failure**
- [ ] **Step 3: Implement `WorkCalendarService` with weekend and holiday exclusion**
- [ ] **Step 4: Run test to confirm it passes**
- [ ] **Step 5: Commit changes**

---

### Task 3: MilestoneService

**Files:**
- Create: `lib/core/services/milestone_service.dart`
- Test: `test/milestone_test.dart`

**Interfaces:**
- Produces: `MilestoneService.calculateMilestone()`, `MilestoneResult` (elapsed, remaining, percentComplete, workingDaysRemaining)

- [ ] **Step 1: Write failing unit tests for milestone calculations**
- [ ] **Step 2: Run test to confirm failure**
- [ ] **Step 3: Implement `MilestoneService`**
- [ ] **Step 4: Run test to confirm it passes**
- [ ] **Step 5: Commit changes**

---

### Task 4: RecurrenceService

**Files:**
- Create: `lib/core/services/recurrence_service.dart`
- Test: `test/recurrence_test.dart`

**Interfaces:**
- Produces: `RecurrenceService.generateOccurrences()`, `RecurrencePattern`, `RecurrenceFrequency`

- [ ] **Step 1: Write failing unit tests for daily, weekly, monthly, and yearly patterns**
- [ ] **Step 2: Run test to confirm failure**
- [ ] **Step 3: Implement `RecurrenceService`**
- [ ] **Step 4: Run test to confirm it passes**
- [ ] **Step 5: Commit changes**

---

### Task 5: HistoryService & HistoryController

**Files:**
- Create: `lib/core/services/history_service.dart`
- Create: `lib/app/controllers/history_controller.dart`
- Test: `test/history_test.dart`

**Interfaces:**
- Produces: `HistoryService`, `HistoryController` (addEntry, toggleFavorite, deleteEntry, clearAll, capped at 100)

- [ ] **Step 1: Write failing unit tests for History persistence and capping**
- [ ] **Step 2: Run test to confirm failure**
- [ ] **Step 3: Implement `HistoryService` and `HistoryController`**
- [ ] **Step 4: Run test to confirm it passes**
- [ ] **Step 5: Commit changes**

---

### Task 6: Business Days Calculator Screen

**Files:**
- Create: `lib/features/business_days/screens/business_days_screen.dart`
- Modify: `lib/features/business_days/widgets/weekend_selector.dart`
- Modify: `lib/features/business_days/widgets/holidays_sheet.dart`

**Interfaces:**
- Consumes: `WorkCalendarService`, `HolidaysData`, `HistoryController`

- [ ] **Step 1: Build the Business Days Calculator UI with Between Dates & Add/Subtract tabs**
- [ ] **Step 2: Implement weekend chip selector and holiday picker sheet**
- [ ] **Step 3: Wire calculation results and history logging**
- [ ] **Step 4: Test in widget harness**
- [ ] **Step 5: Commit changes**

---

### Task 7: Milestone Countdown Screen

**Files:**
- Create: `lib/features/milestone_countdown/screens/milestone_countdown_screen.dart`

**Interfaces:**
- Consumes: `MilestoneService`, `WorkCalendarService`, `HistoryController`

- [ ] **Step 1: Build the Milestone Countdown UI with animated progress bar and presets**
- [ ] **Step 2: Implement dynamic countdown updates and share text summary**
- [ ] **Step 3: Commit changes**

---

### Task 8: Recurrence Planner Screen

**Files:**
- Create: `lib/features/recurrence_planner/screens/recurrence_planner_screen.dart`

**Interfaces:**
- Consumes: `RecurrenceService`, `HistoryController`

- [ ] **Step 1: Build the Recurrence Planner UI with pattern selector and occurrence list**
- [ ] **Step 2: Add timeline view and Export/Copy Schedule action**
- [ ] **Step 3: Commit changes**

---

### Task 9: History & Presets Screen

**Files:**
- Create: `lib/features/history_presets/screens/history_presets_screen.dart`

**Interfaces:**
- Consumes: `HistoryController`, `HistoryItem`

- [ ] **Step 1: Build History Screen with All History, Favorites tabs, and Category filter chips**
- [ ] **Step 2: Implement favorite toggle, copy summary, and clear all with confirmation**
- [ ] **Step 3: Commit changes**

---

### Task 10: Home Dashboard & App Integration

**Files:**
- Modify: `lib/features/home/screens/home_screen.dart`
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: `HistoryController`, 11 tool card routes

- [ ] **Step 1: Register `HistoryController` in `main.dart`**
- [ ] **Step 2: Add History AppBar icon to `HomeScreen`**
- [ ] **Step 3: Update `HomeScreen` with 11 cards and `Work & Planning (3)` category chip**
- [ ] **Step 4: Update `test/widget_test.dart` for all 11 tools and history screen**
- [ ] **Step 5: Commit changes**

---

### Task 11: Final Polish, Roadmap Bump & Verification

**Files:**
- Modify: `pubspec.yaml` (bump to `2.0.0+3`)
- Modify: `AGENTS.md` (mark Release 3, 4, 5 as Completed in 2.0.0)
- Modify: `README.md` (document all new features)

- [ ] **Step 1: Bump version in `pubspec.yaml`**
- [ ] **Step 2: Update `AGENTS.md` and `README.md`**
- [ ] **Step 3: Run `flutter analyze` and `flutter test`**
- [ ] **Step 4: Commit changes**
