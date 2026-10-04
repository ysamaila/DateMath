import 'package:flutter/material.dart';
import '../../app/controllers/history_controller.dart';
import '../../app/controllers/theme_controller.dart';
import '../../core/services/date_calculation_service.dart';
import '../add_subtract_date/add_subtract_date_screen.dart';
import '../age_calculator/age_calculator_screen.dart';
import '../business_days/business_days_screen.dart';
import '../date_difference/date_difference_screen.dart';
import '../day_finder/day_finder_screen.dart';
import '../duration_converter/duration_converter_screen.dart';
import '../equinox_solstice/equinox_solstice_screen.dart';
import '../history_presets/history_presets_screen.dart';
import '../julian_milestones/julian_milestones_screen.dart';
import '../milestone_countdown/milestone_countdown_screen.dart';
import '../moon_phases/moon_phases_screen.dart';
import '../recurrence_planner/recurrence_planner_screen.dart';
import '../time_math/time_math_screen.dart';
import '../twelve_twenty_four/twelve_twenty_four_screen.dart';
import '../world_time_offsets/world_time_offsets_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeController themeController;
  final HistoryController? historyController;

  const HomeScreen({
    super.key,
    required this.themeController,
    this.historyController,
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
        historyController: widget.historyController,
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
  final HistoryController? historyController;
  final ValueChanged<int> onNavigateToTab;

  const _DashboardView({
    required this.themeController,
    this.historyController,
    required this.onNavigateToTab,
  });

  @override
  State<_DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<_DashboardView> {
  int _categoryIndex = 0; // 0: All, 1: Date Tools, 2: Time & Convert, 3: Work & Planning, 4: Astronomy

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
    final showWorkTools = _categoryIndex == 0 || _categoryIndex == 3;
    final showAstronomyTools = _categoryIndex == 0 || _categoryIndex == 4;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DateMath'),
        actions: [
          if (widget.historyController != null)
            IconButton(
              icon: const Icon(Icons.history_rounded),
              tooltip: 'Calculation History',
              onPressed: () => _navigateToScreen(
                HistoryPresetsScreen(
                  historyController: widget.historyController!,
                ),
              ),
            ),
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
                    style: theme.textTheme.titleMedium?.copyWith(
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
                        value: '${today.daysRemainingInYear} days',
                      ),
                      _StatColumn(
                        label: 'Quarter',
                        value: 'Q${today.quarter}',
                      ),
                      _StatColumn(
                        label: 'ISO Week',
                        value: 'Wk ${today.isoWeekNumber}',
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
                  label: const Text('All (14)'),
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
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Work & Planning (3)'),
                  selected: _categoryIndex == 3,
                  onSelected: (_) => setState(() => _categoryIndex = 3),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Astronomy (3)'),
                  selected: _categoryIndex == 4,
                  onSelected: (_) => setState(() => _categoryIndex = 4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Date Tools (Release 1)
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
            if (showTimeTools || showWorkTools) const SizedBox(height: 8),
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
            if (showWorkTools) const SizedBox(height: 8),
          ],

          // Work, History & Planning Tools (Release 3, 4, 5)
          if (showWorkTools) ...[
            _ToolTile(
              title: 'Business Days',
              subtitle: 'Calculate working days, exclude custom weekends and holidays',
              icon: Icons.business_center_rounded,
              iconColor: Colors.indigo.shade600,
              onTap: () => _navigateToScreen(
                BusinessDaysScreen(historyController: widget.historyController),
              ),
            ),
            const SizedBox(height: 8),
            _ToolTile(
              title: 'Milestone Countdown',
              subtitle: 'Track deadlines, target dates, and countdown progress',
              icon: Icons.flag_circle_rounded,
              iconColor: Colors.deepOrange.shade600,
              onTap: () => _navigateToScreen(
                MilestoneCountdownScreen(
                  historyController: widget.historyController,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _ToolTile(
              title: 'Recurrence Planner',
              subtitle: 'Generate repeating meeting schedules and event occurrences',
              icon: Icons.event_repeat_rounded,
              iconColor: Colors.green.shade700,
              onTap: () => _navigateToScreen(
                RecurrencePlannerScreen(
                  historyController: widget.historyController,
                ),
              ),
            ),
            if (showAstronomyTools) const SizedBox(height: 8),
          ],

          // Astronomy Tools (Release 6)
          if (showAstronomyTools) ...[
            _ToolTile(
              title: 'Moon Phases',
              subtitle: 'Track lunar illumination, cycle age, and upcoming primary phases',
              icon: Icons.nightlight_round,
              iconColor: Colors.amber.shade800,
              onTap: () => _navigateToScreen(
                MoonPhasesScreen(historyController: widget.historyController),
              ),
            ),
            const SizedBox(height: 8),
            _ToolTile(
              title: 'Equinox & Solstice',
              subtitle: 'Calculate exact dates and times for seasonal equinoxes and solstices',
              icon: Icons.wb_sunny_rounded,
              iconColor: Colors.deepOrange.shade500,
              onTap: () => _navigateToScreen(
                EquinoxSolsticeScreen(historyController: widget.historyController),
              ),
            ),
            const SizedBox(height: 8),
            _ToolTile(
              title: 'Julian & Milestones',
              subtitle: 'Astronomical Julian Dates (JD, MJD) and day-of-year milestone targets',
              icon: Icons.auto_awesome_rounded,
              iconColor: Colors.indigo.shade400,
              onTap: () => _navigateToScreen(
                JulianMilestonesScreen(historyController: widget.historyController),
              ),
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
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? theme.colorScheme.primary,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          size: 20,
          color: theme.colorScheme.outline,
        ),
        onTap: onTap,
      ),
    );
  }
}
