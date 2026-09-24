import 'package:flutter/material.dart';
import '../../app/controllers/theme_controller.dart';
import '../../core/services/date_calculation_service.dart';
import '../add_subtract_date/add_subtract_date_screen.dart';
import '../age_calculator/age_calculator_screen.dart';
import '../date_difference/date_difference_screen.dart';
import '../day_finder/day_finder_screen.dart';
import '../duration_converter/duration_converter_screen.dart';
import '../time_math/time_math_screen.dart';
import '../twelve_twenty_four/twelve_twenty_four_screen.dart';
import '../world_time_offsets/world_time_offsets_screen.dart';

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

class _DashboardView extends StatefulWidget {
  final ThemeController themeController;
  final ValueChanged<int> onNavigateToTab;

  const _DashboardView({
    required this.themeController,
    required this.onNavigateToTab,
  });

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  int _categoryIndex = 0; // 0: All, 1: Date Tools, 2: Time & Convert

  void _navigateToScreen(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateCalculationService.getTodayOverview();

    final showDateTools = _categoryIndex == 0 || _categoryIndex == 1;
    final showTimeTools = _categoryIndex == 0 || _categoryIndex == 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DateMath'),
        actions: [
          IconButton(
            icon: Icon(
              widget.themeController.themeMode == ThemeMode.dark
                  ? Icons.dark_mode_outlined
                  : (widget.themeController.themeMode == ThemeMode.light
                      ? Icons.light_mode_outlined
                      : Icons.brightness_auto_outlined),
            ),
            tooltip: 'Toggle Theme',
            onPressed: widget.themeController.toggleTheme,
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

          // Tools Section Header + Category Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tools',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Filter Chips Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All (8)'),
                  selected: _categoryIndex == 0,
                  onSelected: (_) => setState(() => _categoryIndex = 0),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Date Tools (4)'),
                  selected: _categoryIndex == 1,
                  onSelected: (_) => setState(() => _categoryIndex = 1),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Time & Convert (4)'),
                  selected: _categoryIndex == 2,
                  onSelected: (_) => setState(() => _categoryIndex = 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Date Tools
          if (showDateTools) ...[
            _ToolTile(
              title: 'Date Difference',
              subtitle: 'Count days, weeks, and months between two dates',
              icon: Icons.compare_arrows_outlined,
              onTap: () => widget.onNavigateToTab(1),
            ),
            const SizedBox(height: 8),
            _ToolTile(
              title: 'Add / Subtract Date',
              subtitle: 'Add or subtract years, months, weeks, or days from any date',
              icon: Icons.calendar_month_outlined,
              onTap: () => widget.onNavigateToTab(2),
            ),
            const SizedBox(height: 8),
            _ToolTile(
              title: 'Age Calculator',
              subtitle: 'Calculate exact age and countdown to next birthday',
              icon: Icons.cake_outlined,
              onTap: () => widget.onNavigateToTab(3),
            ),
            const SizedBox(height: 8),
            _ToolTile(
              title: 'Day Finder',
              subtitle: 'Find the weekday, day of year, and ISO week for any date',
              icon: Icons.today_outlined,
              onTap: () => widget.onNavigateToTab(4),
            ),
            if (showTimeTools) const SizedBox(height: 8),
          ],

          // Time & Conversion Tools (Release 2)
          if (showTimeTools) ...[
            _ToolTile(
              title: 'Time Math',
              subtitle: 'Calculate time difference or add/subtract hours and minutes',
              icon: Icons.access_time_filled_rounded,
              iconColor: Colors.amber.shade700,
              onTap: () => _navigateToScreen(const TimeMathScreen()),
            ),
            const SizedBox(height: 8),
            _ToolTile(
              title: 'Duration Converter',
              subtitle: 'Convert across seconds, minutes, hours, days, and weeks',
              icon: Icons.swap_horiz_rounded,
              iconColor: Colors.cyan.shade700,
              onTap: () => _navigateToScreen(const DurationConverterScreen()),
            ),
            const SizedBox(height: 8),
            _ToolTile(
              title: '12h / 24h Military Time',
              subtitle: 'Convert standard 12-hour AM/PM to 24-hour military notation',
              icon: Icons.timelapse_rounded,
              iconColor: Colors.deepPurple.shade600,
              onTap: () => _navigateToScreen(const TwelveTwentyFourScreen()),
            ),
            const SizedBox(height: 8),
            _ToolTile(
              title: 'World Time Offsets',
              subtitle: 'Compare time zones and UTC offsets 100% offline',
              icon: Icons.public_rounded,
              iconColor: Colors.teal.shade700,
              onTap: () => _navigateToScreen(const WorldTimeOffsetsScreen()),
            ),
          ],
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
  final Color? iconColor;
  final VoidCallback onTap;

  const _ToolTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
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
          color: iconColor ?? theme.colorScheme.primary,
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
