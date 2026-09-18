# DateMath

**DateMath** is a fast, reliable, 100% offline date and time calculation application for Android built with Flutter and Material 3.

---

## Features (Release 1 — CALCULATE)

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
* **Productivity & Convenience**:
  * One-tap copy to clipboard with toast/snackbar confirmation.
  * Quick Reset action on every tool.
  * Light, Dark, and System theme support with local persistence.
  * 100% offline — zero internet permissions, zero analytics, zero external network requests.

---

## Screenshots & Architecture

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
