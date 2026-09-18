import 'package:flutter/material.dart';
import '../../app/controllers/theme_controller.dart';
import '../../core/services/date_calculation_service.dart';
import '../add_subtract_date/add_subtract_date_screen.dart';
import '../age_calculator/age_calculator_screen.dart';
import '../date_difference/date_difference_screen.dart';
import '../day_finder/day_finder_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeController themeController;

  const HomeScreen({
    super.key,
    required this.themeController,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _DashboardView(
        themeController: widget.themeController,
        onNavigateToTab: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
      const DateDifferenceScreen(),
      const AddSubtractDateScreen(),
      const AgeCalculatorScreen(),
      const DayFinderScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedNavIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (idx) {
          setState(() {
            _selectedNavIndex = idx;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.timelapse_outlined),
            selectedIcon: Icon(Icons.timelapse_rounded),
            label: 'Difference',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_time_rounded),
            selectedIcon: Icon(Icons.more_time_rounded),
            label: 'Add/Sub',
          ),
          NavigationDestination(
            icon: Icon(Icons.cake_outlined),
            selectedIcon: Icon(Icons.cake_rounded),
            label: 'Age',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Day Finder',
          ),
        ],
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  final ThemeController themeController;
  final ValueChanged<int> onNavigateToTab;

  const _DashboardView({
    required this.themeController,
    required this.onNavigateToTab,
  });

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.calculate_rounded,
                color: Theme.of(ctx).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            const Text('DateMath'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Version 1.0.0 (Release 1 — CALCULATE)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'DateMath is a private, fast, 100% offline date & time calculation suite.',
            ),
            const SizedBox(height: 8),
            const Text(
              '• Zero internet permissions\n'
              '• Zero external APIs or tracking\n'
              '• Works instantly in Airplane Mode\n'
              '• Pure local calendar math engine',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateCalculationService.getTodayOverview();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'DateMath',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeController.themeMode == ThemeMode.dark
                  ? Icons.dark_mode_rounded
                  : (themeController.themeMode == ThemeMode.light
                      ? Icons.light_mode_rounded
                      : Icons.brightness_auto_rounded),
            ),
            tooltip: 'Toggle Theme',
            onPressed: themeController.toggleTheme,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'About DateMath',
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 100% Offline Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  size: 16,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(width: 8),
                Text(
                  '100% Offline • Private, Fast & Airplane-Ready',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Today Overview Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TODAY OVERVIEW',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          letterSpacing: 1,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Quarter Q${today.quarter}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    today.formattedDate,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Day of Year',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              '${today.dayOfYear} of ${today.totalDaysInYear}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Days Left in ${today.date.year}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              '${today.daysRemainingInYear} days',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ISO Week',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              'Week ${today.isoWeekNumber}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: today.percentageElapsed / 100.0,
                      minHeight: 8,
                      backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${today.percentageElapsed.toStringAsFixed(1)}% of year elapsed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        today.isLeapYear ? 'Leap Year' : 'Common Year',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Tools Section Header
          Text(
            'Calculation Tools',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Tool 1: Date Difference
          _ToolCard(
            title: 'Date Difference',
            description:
                'Calculate exact days, weeks, months, and years between any two dates with inclusive toggle.',
            icon: Icons.timelapse_rounded,
            color: const Color(0xFF4F46E5),
            onTap: () => onNavigateToTab(1),
          ),
          const SizedBox(height: 10),

          // Tool 2: Add / Subtract Date
          _ToolCard(
            title: 'Add / Subtract Date',
            description:
                'Add or subtract years, months, weeks, and days with intelligent end-of-month calendar clamping.',
            icon: Icons.more_time_rounded,
            color: const Color(0xFF06B6D4),
            onTap: () => onNavigateToTab(2),
          ),
          const SizedBox(height: 10),

          // Tool 3: Age Calculator
          _ToolCard(
            title: 'Age Calculator',
            description:
                'Exact chronological age in years/months/days, total days lived, and next birthday countdown.',
            icon: Icons.cake_rounded,
            color: const Color(0xFFF59E0B),
            onTap: () => onNavigateToTab(3),
          ),
          const SizedBox(height: 10),

          // Tool 4: Day Finder
          _ToolCard(
            title: 'Day Finder',
            description:
                'Find weekday name, day of year, quarter, and ISO week number for any past or future date.',
            icon: Icons.calendar_today_rounded,
            color: const Color(0xFF8B5CF6),
            onTap: () => onNavigateToTab(4),
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
