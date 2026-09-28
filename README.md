# DateMath

**DateMath** is a fast, reliable, 100% offline date and time calculation toolkit for Android built with Flutter and Material 3.

---

## Features

### Release 1 — CALCULATE
* **Today Overview**: Live local date, day of year counter (e.g. Day 261 of 365), days remaining in current year, current quarter, and ISO week number.
* **Date Difference**:
  * Total day count between any two dates.
  * Weeks + remaining days conversion.
  * Exact years, months, and days breakdown.
  * Inclusive / exclusive calculation toggle (+1 day).
  * Bidirectional calculation (start date after end date supported).
* **Add / Subtract Date**:
  * Add or subtract years, months, weeks, and days from any starting date.
  * Exact calendar clamping for end-of-month dates (e.g. January 31 + 1 month = February 28 / 29 in leap years).
* **Age Calculator**:
  * Exact chronological age in years, months, and days.
  * Total days lived.
  * Next birthday countdown with day-of-the-week indicator.
  * Accurate leap-day handling for births on February 29th.
* **Day Finder**:
  * Exact day of the week for any past or future date.
  * Day of the year and days remaining.
  * ISO-8601 week number.
  * Leap year verification badge.

### Release 2 — CONVERT & TIME
* **Time Math**:
  * Accurate time difference calculation between two clock times.
  * Automatic midnight-crossing and overnight span detection (`+1 Day`).
  * Add or subtract hours, minutes, and seconds to any clock time with multi-day roll-over indicators.
* **Duration Converter**:
  * Universal live multi-unit converter spanning Milliseconds, Seconds, Minutes, Hours, Days, and Weeks.
  * Human-readable composite duration breakdown (e.g., `90,000s = 1 day, 1 hour, 0 mins, 0 secs`).
  * Quick presets for instant calculations (`1 hr`, `1 day`, `1 week`, `3,600s`, `86,400s`).
* **12h / 24h Military Time**:
  * Interactive conversion between 12-hour AM/PM and 24-hour military clock time.
  * Spoken phonetic military guide (e.g., `"Twenty hundred forty-five hours"`).
  * Real-time day completion progress bar and percentage.
  * Military time cheat sheet and reference guide.
* **World Time Offsets (100% Offline)**:
  * Dual time zone comparison between local device time and global target destinations.
  * Searchable offline database of ~60 major global cities grouped by continent.
  * Direct manual UTC offset slider from `UTC-12:00` to `UTC+14:00` with 15/30-minute accuracy.
  * Interactive hour scrubber to observe target time shift dynamically.

### Release 2.0.0 — WORK, HISTORY & RECURRENCE (Unified Major Release)
* **Business Days Calculator**:
  * Count exact working days between two dates or add/subtract business days.
  * Interactive custom weekend day selection (`Mon` through `Sun`).
  * Offline regional holiday presets (United States, United Kingdom, Canada, Nigeria, International).
  * Custom holiday management dialog with local persistence.
  * Full metric breakdown: working days, weekend days, holidays excluded, and % working time.
* **Milestone Countdown**:
  * Track project deadlines, events, weddings, and milestones with customizable titles.
  * Animated visual progress bar showing percentage of timeline completed.
  * Dynamic hero countdown cards (days remaining, overdue indicator, reached status).
  * Real-time working days remaining counter excluding weekends.
  * Quick target presets: Next Month End, End of Quarter, End of Year, +100 Days.
* **Recurrence Planner**:
  * Comprehensive repeating schedule generator for events, meetings, and intervals.
  * Supports Daily, Weekly (multi-weekday selection), Monthly (by day of month or relative Nth weekday e.g., "2nd Tuesday"), and Yearly patterns.
  * Occurrence timeline preview with ISO week numbers and relative day counters.
  * One-tap export and formatted schedule copying.
* **Local Calculation History & Starred Favorites**:
  * Automatic local recording of calculations across all tools (capped at 100 entries for zero bloat).
  * Star favorite calculations for instant recall.
  * Category-based history filtering (`Date Tools`, `Time & Convert`, `Work & Planning`).
  * Single entry deletion and full history clear with confirmation.
  * Export complete history log as formatted plain text.

* **Productivity & Convenience**:
  * Dashboard category filter chips: `All (11)`, `Date Tools (4)`, `Time & Convert (4)`, `Work & Planning (3)`.
  * Top AppBar quick-access button for Calculation History & Favorites.
  * One-tap copy to clipboard with floating confirmation.
  * Quick Reset action on every tool.
  * Light, Dark, and System theme support with local persistence.
  * **Strict 100% offline guarantee**: Zero internet permissions, zero analytics, zero external network requests.

---

## Architecture & Roadmap

See [AGENTS.md](AGENTS.md) for full architecture notes, offline guarantee specifications, and the product roadmap.

---

## Building and Running

### Prerequisites
- Flutter SDK (>= 3.24)
- Android SDK with JDK 17+

### Run Debug
```bash
flutter run
```

### Run Tests
```bash
flutter test
```

### Build Release APK
```bash
flutter build apk --release
```
