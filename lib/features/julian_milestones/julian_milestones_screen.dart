import 'package:flutter/material.dart';
import '../../app/controllers/history_controller.dart';
import '../../core/services/astronomical_service.dart';
import '../../core/services/time_calculation_service.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/widgets/date_selector_tile.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/time_selector_tile.dart';

class JulianMilestonesScreen extends StatefulWidget {
  final HistoryController? historyController;

  const JulianMilestonesScreen({super.key, this.historyController});

  @override
  State<JulianMilestonesScreen> createState() => _JulianMilestonesScreenState();
}

class _JulianMilestonesScreenState extends State<JulianMilestonesScreen> {
  late DateTime _selectedDate;
  late ClockTime _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _selectedTime = ClockTime(hour: now.hour, minute: now.minute, second: 0);
  }

  void _reset() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _selectedTime = ClockTime(hour: 12, minute: 0, second: 0); // Standard astronomical noon
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
      _selectedTime.second,
    );

    final result = AstronomicalService.calculateJulianDate(combinedDateTime);
    final milestones = AstronomicalService.getDayOfYearMilestones(_selectedDate.year);

    final summary =
        '${AppUtils.formatFull(_selectedDate)} ${_selectedTime.formatted}: '
        'JD: ${result.julianDate.toStringAsFixed(5)}, MJD: ${result.modifiedJulianDate.toStringAsFixed(5)}, '
        'Day ${result.dayOfYear} of ${result.totalDaysInYear} (${result.yearProgressPercentage.toStringAsFixed(1)}%).';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Julian & Year Milestones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Reset to noon today',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy details',
            onPressed: () {
              AppUtils.copyToClipboard(
                context,
                summary,
                message: 'Julian calculation details copied to clipboard',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: DateSelectorTile(
                  label: 'Date',
                  selectedDate: _selectedDate,
                  onDateChanged: (dt) => setState(() => _selectedDate = dt),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TimeSelectorTile(
                  label: 'Time',
                  selectedTime: _selectedTime,
                  onTimeChanged: (t) => setState(() => _selectedTime = t),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Julian Date Result Cards
          ResultCard(
            title: 'JULIAN DATE (JD)',
            primaryValue: result.julianDate.toStringAsFixed(5),
            subtitle: 'Standard continuous astronomical count from 4713 BC',
            copyPayload: result.julianDate.toStringAsFixed(6),
            icon: Icons.auto_awesome_rounded,
          ),
          const SizedBox(height: 8),

          ResultCard(
            title: 'MODIFIED JULIAN DATE (MJD)',
            primaryValue: result.modifiedJulianDate.toStringAsFixed(5),
            subtitle: 'Julian Day Number (JDN): ${result.julianDayNumber}',
            copyPayload: result.modifiedJulianDate.toStringAsFixed(6),
            icon: Icons.timelapse_rounded,
          ),
          const SizedBox(height: 16),

          // Year Progress Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'YEAR PROGRESS (${_selectedDate.year})',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        '${result.yearProgressPercentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: result.yearProgressPercentage / 100.0,
                      minHeight: 10,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Day ${result.dayOfYear} of ${result.totalDaysInYear}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${result.daysRemaining} days left',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Day-of-Year Milestones
          Text(
            '${_selectedDate.year} Day Milestones',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          ...milestones.map((m) {
            final formattedDate = AppUtils.formatFull(m.date);
            final statusText = m.isReached
                ? 'Reached'
                : (m.daysAway == 0 ? 'Today' : 'in ${m.daysAway} days');

            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: m.isReached
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    m.isReached ? Icons.check : Icons.flag_outlined,
                    size: 16,
                    color: m.isReached
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                title: Text(
                  m.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('Day ${m.dayNumber} • $formattedDate'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: m.isReached
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: m.isReached
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Save to History Action
          FilledButton.tonalIcon(
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save to Calculation History'),
            onPressed: () {
              widget.historyController?.addEntry(
                toolName: 'Julian & Milestones',
                category: 'Astronomy',
                title: 'JD ${result.julianDate.toStringAsFixed(2)} (${AppUtils.formatShort(_selectedDate)})',
                resultSummary:
                    'JD: ${result.julianDate.toStringAsFixed(4)}, Day ${result.dayOfYear}/${result.totalDaysInYear} (${result.yearProgressPercentage.toStringAsFixed(1)}%)',
              );
              AppUtils.copyToClipboard(
                context,
                summary,
                message: 'Julian calculation saved to history and copied to clipboard',
              );
            },
          ),
        ],
      ),
    );
  }
}
