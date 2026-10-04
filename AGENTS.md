# DateMath — Developer & Agent Documentation

Welcome to **DateMath**, a 100% offline, private date and time calculation toolkit for Android built with Flutter + Dart.

---

## 1. Core Architecture & Philosophy

### Strict Offline Guarantee
- **Zero Internet Permissions**: `android.permission.INTERNET` is not included in `AndroidManifest.xml`.
- **Zero Network Packages**: No `http`, `dio`, `web_socket_channel`, or network transport dependencies.
- **Zero Cloud / Analytics**: No Firebase, Supabase, Google Analytics, Sentry, or remote trackers.
- **Instant Usability**: App operates completely in Airplane Mode immediately upon installation.
- **Local State**: User preferences and calculation history are stored strictly on-device using `shared_preferences`.

---

## 2. Six-Release Product Roadmap

| Release | Codename | Scope / Focus | Status |
|---|---|---|---|
| **Release 1** | **CALCULATE** | Core calculation toolkit: Date Difference, Add/Subtract Date, Age Calculator, Day Finder, Today Overview, Material 3 theming. | **Completed** (`v1.0.0+1`) |
| **Release 2** | **CONVERT & TIME** | Duration conversions (hours, minutes, seconds, etc.), world time offsets, 12h/24h conversion, time math. | **Completed** (`v1.1.0+2`) |
| **Release 3, 4, 5** | **WORK, HISTORY & RECURRENCE** | Unified Major Release: Business days math, custom weekend & holiday exclusion, milestone countdowns, local calculation history & favorites, repeating recurrence schedules. | **Completed** (`v2.0.0+3`) |
| **Release 6** | **ASTRONOMICAL** | Moon phases, equinox/solstice calculations, Julian date numbers, day-of-year milestones. | **Completed** (`v2.1.0+4`) |

> **Scope Note for Agents:** Always focus only on the active release. Do not implement future releases ahead of time.

---

## 3. Directory Structure

```
datemath/
├── android/                  # Android native project & release signing configs
├── assets/
│   ├── icon/                 # Application launcher icons
│   ├── screenshots/          # App store preview screenshots
│   └── feature_graphic.png   # Store feature graphic
├── lib/
│   ├── app/
│   │   ├── controllers/      # ThemeController, HistoryController
│   │   └── theme/            # Material 3 light & dark theme specifications
│   ├── core/
│   │   ├── data/             # WorldCitiesData, HolidaysData (offline regional presets)
│   │   ├── models/           # CustomHoliday, HistoryItem
│   │   ├── services/         # Pure Dart engines (DateCalculation, TimeCalculation, WorkCalendar, Milestone, Recurrence, History)
│   │   └── utils/            # Formatters, clipboard helpers, constants
│   ├── features/
│   │   ├── add_subtract_date/# Add & Subtract date calculator screen
│   │   ├── age_calculator/   # Age calculation & next birthday screen
│   │   ├── business_days/    # Business days & working days calculator screen
│   │   ├── date_difference/  # Between-dates difference screen
│   │   ├── day_finder/       # Day of week, day of year, ISO week screen
│   │   ├── duration_converter/# Multi-unit live duration converter screen
│   │   ├── equinox_solstice/ # Seasonal equinox & solstice calculator screen
│   │   ├── history_presets/  # Local calculation history & favorites screen
│   │   ├── home/             # Home Dashboard with Today Overview & category filter chips
│   │   ├── julian_milestones/# Julian date (JD/MJD) & day-of-year milestone targets screen
│   │   ├── milestone_countdown/# Milestone target progress & countdown screen
│   │   ├── moon_phases/      # Moon phases, illumination meter & primary phase timing screen
│   │   ├── recurrence_planner/# Repeating schedules and recurrence generator screen
│   │   ├── time_math/        # Time difference & duration add/subtract screen
│   │   ├── twelve_twenty_four/# 12h <-> 24h military time conversion screen
│   │   └── world_time_offsets/# Offline global timezone and UTC offset comparison screen
│   ├── shared/
│   │   └── widgets/          # ResultCard, DateSelectorTile, TimeSelectorTile, NumberStepperField
│   └── main.dart             # App entry point
└── test/
    ├── astronomical_service_test.dart # Unit tests for Julian date, moon phase, and solar events
    ├── date_calculation_test.dart # Unit tests for pure calendar calculations
    ├── history_test.dart          # Unit tests for history persistence & capping
    ├── milestone_test.dart        # Unit tests for milestone progress & deadlines
    ├── models_and_holidays_test.dart # Unit tests for models & holiday catalog
    ├── recurrence_test.dart       # Unit tests for recurrence schedule patterns
    ├── time_calculation_test.dart # Unit tests for pure clock & duration calculations
    ├── widget_test.dart           # Widget integration & navigation tests
    └── work_calendar_test.dart    # Unit tests for business days & holiday exclusions
```

---

## 4. Keystore & Signing Policy
- The development keystore `android/app/datemath-release.jks` and local configuration `android/key.properties` are strictly excluded from version control via `.gitignore`.
- Reference configuration is provided in `android/key.properties.example`.
- Never commit private signing keys or credentials.

---

## 5. Development Status Log
- **2026-09-18**: Release 1 (CALCULATE) initialized with pure Dart date calculation engine, comprehensive unit tests, Material 3 theming, offline guarantee, custom brand icon, and signed release build verification.
- **2026-09-24**: Release 2 (CONVERT & TIME) completed with pure Dart TimeCalculationService engine, offline WorldCitiesData catalog, 4 new feature screens (Time Math, Duration Converter, 12h/24h Military Time, World Time Offsets), dashboard category filter chips, and 100% passing test coverage.
- **2026-09-28**: Release 2.0.0 (WORK, HISTORY & RECURRENCE) completed: combining Releases 3, 4, and 5 into one unified major release. Adds WorkCalendarService with custom weekend & regional holiday exclusion, MilestoneService, RecurrenceService, local offline HistoryService capped at 100 items with favorites, 3 new feature screens (Business Days, Milestone Countdown, Recurrence Planner), History & Presets screen, 4 dashboard category chips, and 64 passing unit & widget tests.
- **2026-10-04**: Release 2.1.0 (ASTRONOMICAL) completed: delivering Release 6. Adds pure Dart AstronomicalService with offline Meeus algorithms for continuous Julian Date (JD, MJD, JDN), Day-of-Year Milestones, Moon phase illumination and primary phase projections, 4 cardinal solar events (Equinoxes & Solstices), 3 new feature screens (Moon Phases, Equinox & Solstice, Julian & Milestones), Astronomy category filter chip on Home Dashboard (total 14 tools), and 71 passing unit & widget tests.
