import 'package:flutter/material.dart';
import '../../core/services/date_calculation_service.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/widgets/date_selector_tile.dart';
import '../../shared/widgets/result_card.dart';

class DateDifferenceScreen extends StatefulWidget {
  const DateDifferenceScreen({super.key});

  @override
  State<DateDifferenceScreen> createState() => _DateDifferenceScreenState();
}

class _DateDifferenceScreenState extends State<DateDifferenceScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  bool _includeEndDate = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 30));
  }

  void _reset() {
    setState(() {
      final now = DateTime.now();
      _startDate = DateTime(now.year, now.month, now.day);
      _endDate = _startDate.add(const Duration(days: 30));
      _includeEndDate = false;
    });
  }

  void _swapDates() {
    setState(() {
      final temp = _startDate;
      _startDate = _endDate;
      _endDate = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = DateCalculationService.calculateDifference(
      _startDate,
      _endDate,
      includeEndDate: _includeEndDate,
    );

    final summaryText =
        'Difference between ${AppUtils.formatShort(_startDate)} and ${AppUtils.formatShort(_endDate)}: '
        '${result.totalDays.abs()} days (${result.formattedWeeksDays}, ${result.formattedBreakdown})'
        '${_includeEndDate ? " [inclusive]" : ""}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Difference'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Reset dates',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy summary',
            onPressed: () {
              AppUtils.copyToClipboard(
                context,
                summaryText,
                message: 'Difference summary copied to clipboard',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DateSelectorTile(
            label: 'Start Date',
            selectedDate: _startDate,
            onDateChanged: (dt) => setState(() => _startDate = dt),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _swapDates,
              icon: const Icon(Icons.swap_vert, size: 18),
              label: const Text('Swap Dates'),
            ),
          ),
          const SizedBox(height: 4),
          DateSelectorTile(
            label: 'End Date',
            selectedDate: _endDate,
            onDateChanged: (dt) => setState(() => _endDate = dt),
          ),
          const SizedBox(height: 12),
          // Clean Inclusive Switch Tile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Include End Date (+1 day)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Counts the final day as a full day in the total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _includeEndDate,
                  onChanged: (val) => setState(() => _includeEndDate = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Results
          ResultCard(
            title: result.isNegative ? 'TOTAL DAYS (REVERSED)' : 'TOTAL DAYS',
            primaryValue: '${result.totalDays.abs()} Days',
            subtitle: result.isNegative
                ? 'Start date is after end date'
                : (_includeEndDate ? 'Inclusive period' : 'Exclusive of end date'),
            copyPayload: '${result.totalDays.abs()} days',
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 8),
          ResultCard(
            title: 'WEEKS & REMAINING DAYS',
            primaryValue: result.formattedWeeksDays,
            copyPayload: result.formattedWeeksDays,
            icon: Icons.view_week_outlined,
          ),
          const SizedBox(height: 8),
          ResultCard(
            title: 'YEARS, MONTHS & DAYS',
            primaryValue: result.formattedBreakdown,
            copyPayload: result.formattedBreakdown,
            icon: Icons.pie_chart_outline,
          ),
        ],
      ),
    );
  }
}
