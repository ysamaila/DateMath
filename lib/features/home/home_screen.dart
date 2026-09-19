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
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows_outlined),
            selectedIcon: Icon(Icons.compare_arrows),
            label: 'Difference',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Add / Sub',
          ),
          NavigationDestination(
            icon: Icon(Icons.cake_outlined),
            selectedIcon: Icon(Icons.cake),
            label: 'Age',
          ),
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateCalculationService.getTodayOverview();

    return Scaffold(
      appBar: AppBar(
        title: const Text('DateMath'),
        actions: [
          IconButton(
            icon: Icon(
              themeController.themeMode == ThemeMode.dark
                  ? Icons.dark_mode_outlined
                  : (themeController.themeMode == ThemeMode.light
                      ? Icons.light_mode_outlined
                      : Icons.brightness_auto_outlined),
            ),
            tooltip: 'Toggle Theme',
            onPressed: themeController.toggleTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Clean Today Summary Card
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TODAY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    today.formattedDate,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatColumn(
                        label: 'Day of Year',
                        value: '${today.dayOfYear} of ${today.totalDaysInYear}',
                      ),
                      _StatColumn(
                        label: 'Days Left',
                        value: '${today.daysRemainingInYear}',
                      ),
                      _StatColumn(
                        label: 'ISO Week',
                        value: 'Week ${today.isoWeekNumber}',
                      ),
                      _StatColumn(
                        label: 'Quarter',
                        value: 'Q${today.quarter}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Tools',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Clean list of tool items
          _ToolTile(
            title: 'Date Difference',
            subtitle: 'Count days, weeks, and months between two dates',
            icon: Icons.compare_arrows_outlined,
            onTap: () => onNavigateToTab(1),
          ),
          const SizedBox(height: 8),

          _ToolTile(
            title: 'Add / Subtract Date',
            subtitle: 'Add or subtract years, months, weeks, or days from any date',
            icon: Icons.calendar_month_outlined,
            onTap: () => onNavigateToTab(2),
          ),
          const SizedBox(height: 8),

          _ToolTile(
            title: 'Age Calculator',
            subtitle: 'Calculate exact age and countdown to next birthday',
            icon: Icons.cake_outlined,
            onTap: () => onNavigateToTab(3),
          ),
          const SizedBox(height: 8),

          _ToolTile(
            title: 'Day Finder',
            subtitle: 'Find the weekday, day of year, and ISO week for any date',
            icon: Icons.today_outlined,
            onTap: () => onNavigateToTab(4),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;

  const _StatColumn({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ToolTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
