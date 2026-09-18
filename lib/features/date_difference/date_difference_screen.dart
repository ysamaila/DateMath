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
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset dates',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
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
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton.icon(
              onPressed: _swapDates,
              icon: const Icon(Icons.swap_vert_rounded, size: 18),
              label: const Text('Swap Dates'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          DateSelectorTile(
            label: 'End Date',
            selectedDate: _endDate,
            onDateChanged: (dt) => setState(() => _endDate = dt),
          ),
          const SizedBox(height: 16),
          // Inclusive switch
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Include End Date',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Adds 1 day to calculate inclusive date span',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
          const SizedBox(height: 24),
          // Results
          ResultCard(
            title: result.isNegative ? 'TOTAL DAYS (REVERSED)' : 'TOTAL DAYS',
            primaryValue: '${result.totalDays.abs()} Days',
            subtitle: result.isNegative
                ? 'Start date is after End date'
                : (_includeEndDate ? 'Inclusive period' : 'Exclusive of end date'),
            copyPayload: '${result.totalDays.abs()} days',
            icon: Icons.timelapse_rounded,
            accentColor: result.isNegative ? Colors.orange : theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          ResultCard(
            title: 'WEEKS & REMAINING DAYS',
            primaryValue: result.formattedWeeksDays,
            copyPayload: result.formattedWeeksDays,
            icon: Icons.calendar_view_week_rounded,
            accentColor: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          ResultCard(
            title: 'YEARS, MONTHS & DAYS',
            primaryValue: result.formattedBreakdown,
            copyPayload: result.formattedBreakdown,
            icon: Icons.pie_chart_outline_rounded,
            accentColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }
}
