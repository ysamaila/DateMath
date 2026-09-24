# DateMath — Developer & Agent Documentation

Welcome to **DateMath**, a 100% offline, private date and time calculation toolkit for Android built with Flutter + Dart.

---

## 1. Core Architecture & Philosophy

### Strict Offline Guarantee
- **Zero Internet Permissions**: `android.permission.INTERNET` is not included in `AndroidManifest.xml`.
- **Zero Network Packages**: No `http`, `dio`, `web_socket_channel`, or network transport dependencies.
- **Zero Cloud / Analytics**: No Firebase, Supabase, Google Analytics, Sentry, or remote trackers.
- **Instant Usability**: App operates completely in Airplane Mode immediately upon installation.
- **Local State**: User preferences (such as dark/light/system theme mode) are stored strictly on-device using `shared_preferences`.

---

## 2. Six-Release Product Roadmap

| Release | Codename | Scope / Focus | Status |
|---|---|---|---|
| **Release 1** | **CALCULATE** | Core calculation toolkit: Date Difference, Add/Subtract Date, Age Calculator, Day Finder, Today Overview, Material 3 theming. | **Completed** |
| **Release 2** | **CONVERT & TIME** | Duration conversions (hours, minutes, seconds, etc.), world time offsets, 12h/24h conversion, time math. | **Active (Current / Completed)** |
| **Release 3** | **WORK & CALENDAR** | Business/working days calculator, custom weekend exclusion, holidays list, milestone countdowns. | *Planned* |
| **Release 4** | **HISTORY & PRESETS** | Local calculation history log, favorite date pairs, quick preset intervals, export as text/summary. | *Planned* |
| **Release 5** | **RECURRENCE** | Repeating schedule generator, bi-weekly/monthly recurrence planner, meeting intervals. | *Planned* |
| **Release 6** | **ASTRONOMICAL** | Moon phases, equinox/solstice calculations, Julian date numbers, day-of-year milestones. | *Planned* |

> **Scope Note for Agents:** Always focus only on the active release. Do not implement future releases ahead of time.

---

## 3. Directory Structure

```
datemath/
├── android/                  # Android native project & release signing configs
├── assets/
│   └── icon/                 # Application launcher icons
├── lib/
│   ├── app/
│   │   ├── controllers/      # ThemeController and app-level state
│   │   └── theme/            # Material 3 light & dark theme specifications
│   ├── core/
│   │   ├── data/             # WorldCitiesData (offline catalog of ~60 major cities)
│   │   ├── services/         # DateCalculationService, TimeCalculationService (pure Dart, zero UI)
│   │   └── utils/            # Formatters, clipboard helpers, constants
│   ├── features/
│   │   ├── add_subtract_date/# Add & Subtract date calculator screen
│   │   ├── age_calculator/   # Age calculation & next birthday screen
│   │   ├── date_difference/  # Between-dates difference screen
│   │   ├── day_finder/       # Day of week, day of year, ISO week screen
│   │   ├── duration_converter/# Multi-unit live duration converter screen
│   │   ├── home/             # Home Dashboard with Today Overview & category filter chips
│   │   ├── time_math/        # Time difference & duration add/subtract screen
│   │   ├── twelve_twenty_four/# 12h <-> 24h military time conversion screen
│   │   └── world_time_offsets/# Offline global timezone and UTC offset comparison screen
│   ├── shared/
│   │   └── widgets/          # ResultCard, DateSelectorTile, TimeSelectorTile, NumberStepperField
│   └── main.dart             # App entry point
└── test/
    ├── date_calculation_test.dart # Unit tests for pure calendar calculations
    ├── time_calculation_test.dart # Unit tests for pure clock & duration calculations
    └── widget_test.dart           # Widget integration & navigation tests
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
