import 'package:flutter_test/flutter_test.dart';
import 'package:datemath/core/services/milestone_service.dart';

void main() {
  late MilestoneService service;

  setUp(() {
    service = const MilestoneService();
  });

  group('MilestoneService - calculateMilestone', () {
    test('calculates active milestone progress correctly', () {
      final start = DateTime(2026, 1, 1);
      final target = DateTime(2026, 1, 31);
      final current = DateTime(2026, 1, 16); // 15 days elapsed, 15 remaining

      final result = service.calculateMilestone(
        start: start,
        target: target,
        currentDate: current,
      );

      expect(result.totalDays, 30);
      expect(result.daysElapsed, 15);
      expect(result.daysRemaining, 15);
      expect(result.percentComplete, closeTo(0.5, 0.01));
      expect(result.isOverdue, isFalse);
      expect(result.isReached, isFalse);
    });

    test('detects overdue milestone', () {
      final start = DateTime(2026, 1, 1);
      final target = DateTime(2026, 1, 15);
      final current = DateTime(2026, 1, 20); // 5 days past target

      final result = service.calculateMilestone(
        start: start,
        target: target,
        currentDate: current,
      );

      expect(result.isOverdue, isTrue);
      expect(result.daysOverdue, 5);
      expect(result.percentComplete, 1.0);
    });

    test('target is today marks milestone as reached', () {
      final start = DateTime(2026, 1, 1);
      final target = DateTime(2026, 1, 10);
      final current = DateTime(2026, 1, 10);

      final result = service.calculateMilestone(
        start: start,
        target: target,
        currentDate: current,
      );

      expect(result.isReached, isTrue);
      expect(result.daysRemaining, 0);
      expect(result.percentComplete, 1.0);
    });

    test('calculates working days remaining', () {
      // 2026-10-05 is Monday, target 2026-10-09 is Friday
      final start = DateTime(2026, 10, 1);
      final target = DateTime(2026, 10, 9);
      final current = DateTime(2026, 10, 5);

      final result = service.calculateMilestone(
        start: start,
        target: target,
        currentDate: current,
      );

      expect(result.workingDaysRemaining, 5); // Mon, Tue, Wed, Thu, Fri
    });
  });

  group('MilestonePresets', () {
    test('returns future target dates', () {
      final today = DateTime(2026, 9, 28);
      final nextMonth = MilestonePresets.nextMonthEnd(today);
      expect(nextMonth.isAfter(today), isTrue);

      final endOfYear = MilestonePresets.endOfYear(today);
      expect(endOfYear, DateTime(2026, 12, 31));

      final hundredDays = MilestonePresets.addDays(today, 100);
      expect(hundredDays.difference(today).inDays, 100);
    });
  });
}
