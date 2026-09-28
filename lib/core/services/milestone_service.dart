class MilestoneResult {
  final int totalDays;
  final int daysElapsed;
  final int daysRemaining;
  final int daysOverdue;
  final double percentComplete;
  final bool isReached;
  final bool isOverdue;
  final int workingDaysRemaining;

  const MilestoneResult({
    required this.totalDays,
    required this.daysElapsed,
    required this.daysRemaining,
    required this.daysOverdue,
    required this.percentComplete,
    required this.isReached,
    required this.isOverdue,
    required this.workingDaysRemaining,
  });
}

class MilestonePresets {
  static DateTime nextMonthEnd(DateTime from) {
    return DateTime(from.year, from.month + 2, 0);
  }

  static DateTime endOfQuarter(DateTime from) {
    final currentQuarter = ((from.month - 1) ~/ 3) + 1;
    final endMonth = currentQuarter * 3;
    return DateTime(from.year, endMonth + 1, 0);
  }

  static DateTime endOfYear(DateTime from) {
    return DateTime(from.year, 12, 31);
  }

  static DateTime addDays(DateTime from, int days) {
    return from.add(Duration(days: days));
  }
}

class MilestoneService {
  const MilestoneService();

  MilestoneResult calculateMilestone({
    required DateTime start,
    required DateTime target,
    DateTime? currentDate,
    Set<int> weekendDays = const {DateTime.saturday, DateTime.sunday},
  }) {
    final s = DateTime(start.year, start.month, start.day);
    final t = DateTime(target.year, target.month, target.day);
    final now = currentDate ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final totalDays = t.difference(s).inDays;

    if (today.isAfter(t)) {
      final daysOverdue = today.difference(t).inDays;
      return MilestoneResult(
        totalDays: totalDays < 0 ? 0 : totalDays,
        daysElapsed: totalDays < 0 ? 0 : totalDays,
        daysRemaining: 0,
        daysOverdue: daysOverdue,
        percentComplete: 1.0,
        isReached: true,
        isOverdue: true,
        workingDaysRemaining: 0,
      );
    }

    if (today.isAtSameMomentAs(t)) {
      return MilestoneResult(
        totalDays: totalDays < 0 ? 0 : totalDays,
        daysElapsed: totalDays < 0 ? 0 : totalDays,
        daysRemaining: 0,
        daysOverdue: 0,
        percentComplete: 1.0,
        isReached: true,
        isOverdue: false,
        workingDaysRemaining: 0,
      );
    }

    final daysElapsed = today.isBefore(s) ? 0 : today.difference(s).inDays;
    final daysRemaining = t.difference(today).inDays;

    final double percent = totalDays <= 0
        ? 1.0
        : (daysElapsed / totalDays).clamp(0.0, 1.0);

    // Compute working days remaining from today up to target
    var workDays = 0;
    var cur = today;
    while (!cur.isAfter(t)) {
      if (!weekendDays.contains(cur.weekday)) {
        workDays++;
      }
      cur = cur.add(const Duration(days: 1));
    }

    return MilestoneResult(
      totalDays: totalDays,
      daysElapsed: daysElapsed,
      daysRemaining: daysRemaining,
      daysOverdue: 0,
      percentComplete: percent,
      isReached: false,
      isOverdue: false,
      workingDaysRemaining: workDays,
    );
  }
}
