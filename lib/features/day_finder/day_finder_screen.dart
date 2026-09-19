import 'package:flutter/material.dart';
import '../../core/services/date_calculation_service.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/widgets/date_selector_tile.dart';
import '../../shared/widgets/result_card.dart';

class DayFinderScreen extends StatefulWidget {
  const DayFinderScreen({super.key});

  @override
  State<DayFinderScreen> createState() => _DayFinderScreenState();
}

class _DayFinderScreenState extends State<DayFinderScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  void _reset() {
    setState(() {
      final now = DateTime.now();
      _selectedDate = DateTime(now.year, now.month, now.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final details = DateCalculationService.findDayDetails(_selectedDate);

    final summary =
        '${AppUtils.formatFull(_selectedDate)}: ${details.weekdayName}, Day ${details.dayOfYear} of the year, '
        'Week ${details.isoWeekNumber}, Quarter Q${details.quarter}, '
        '${details.isLeapYear ? "Leap year" : "Common year"}.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Day Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Reset to today',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy details',
            onPressed: () {
              AppUtils.copyToClipboard(
                context,
                summary,
                message: 'Day details copied to clipboard',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DateSelectorTile(
            label: 'Select Date to Check',
            selectedDate: _selectedDate,
            onDateChanged: (dt) => setState(() => _selectedDate = dt),
          ),
          const SizedBox(height: 16),
          // Day of the Week Card
          ResultCard(
            title: 'DAY OF THE WEEK',
            primaryValue: details.weekdayName,
            subtitle: AppUtils.formatFull(_selectedDate),
            copyPayload: details.weekdayName,
            icon: Icons.today_outlined,
          ),
          const SizedBox(height: 8),
          // Day of Year & Days Left Card
          ResultCard(
            title: 'DAY OF THE YEAR',
            primaryValue: 'Day ${details.dayOfYear} of ${details.year}',
            subtitle: '${details.daysRemainingInYear} days remaining in ${details.year}',
            copyPayload: 'Day ${details.dayOfYear} of ${details.year}',
            icon: Icons.calendar_month_outlined,
          ),
          const SizedBox(height: 8),
          // Calendar Position Card
          ResultCard(
            title: 'CALENDAR POSITION',
            primaryValue: 'Week ${details.isoWeekNumber}',
            subtitle: 'Quarter Q${details.quarter} • ${details.isLeapYear ? "Leap Year (366 days)" : "Common Year (365 days)"}',
            copyPayload: 'Week ${details.isoWeekNumber}, Quarter Q${details.quarter}',
            icon: Icons.grid_view_outlined,
          ),
        ],
      ),
    );
  }
}
