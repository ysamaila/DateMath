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

* **Productivity & Convenience**:
  * Dashboard category filter chips: `All (8)`, `Date Tools (4)`, `Time & Convert (4)`.
  * One-tap copy to clipboard with floating confirmation.
  * Quick Reset action on every tool.
  * Light, Dark, and System theme support with local persistence.
  * **Strict 100% offline guarantee**: Zero internet permissions, zero analytics, zero external network requests.

---

## Architecture & Roadmap

See [AGENTS.md](AGENTS.md) for full architecture notes, offline guarantee specifications, and the 6-release roadmap.

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
