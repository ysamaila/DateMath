import 'package:flutter/material.dart';
import '../../core/services/time_calculation_service.dart';
import '../../shared/widgets/number_stepper_field.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/time_selector_tile.dart';

class TimeMathScreen extends StatefulWidget {
  const TimeMathScreen({super.key});

  @override
  State<TimeMathScreen> createState() => _TimeMathScreenState();
}

class _TimeMathScreenState extends State<TimeMathScreen> {
  int _selectedTabIndex = 0; // 0: Difference, 1: Add/Subtract

  // Difference state
  late ClockTime _startTime;
  late ClockTime _endTime;

  // Add/Subtract state
  late ClockTime _baseTime;
  bool _isSubtract = false;
  int _hoursToAdd = 1;
  int _minutesToAdd = 30;
  int _secondsToAdd = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startTime = ClockTime(hour: 9, minute: 0);
    _endTime = ClockTime(hour: 17, minute: 30);
    _baseTime = ClockTime.fromDateTime(now);
  }

  void _reset() {
    setState(() {
      final now = DateTime.now();
      _startTime = ClockTime(hour: 9, minute: 0);
      _endTime = ClockTime(hour: 17, minute: 30);
      _baseTime = ClockTime.fromDateTime(now);
      _isSubtract = false;
      _hoursToAdd = 1;
      _minutesToAdd = 30;
      _secondsToAdd = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Math'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(
                value: 0,
                label: Text('Time Difference'),
                icon: Icon(Icons.compare_arrows_rounded),
              ),
              ButtonSegment<int>(
                value: 1,
                label: Text('Add / Subtract'),
                icon: Icon(Icons.exposure_rounded),
              ),
            ],
            selected: {_selectedTabIndex},
            onSelectionChanged: (newSelection) {
              setState(() {
                _selectedTabIndex = newSelection.first;
              });
            },
          ),
          const SizedBox(height: 20),
          if (_selectedTabIndex == 0) _buildDifferenceTab(theme) else _buildAddSubtractTab(theme),
        ],
      ),
    );
  }

  Widget _buildDifferenceTab(ThemeData theme) {
    final diffResult = TimeCalculationService.difference(_startTime, _endTime);
    final hoursDecimal = (diffResult.totalSeconds / 3600.0).toStringAsFixed(2);
    final totalMinutes = diffResult.totalSeconds ~/ 60;

    final copyPayload =
        'Time Difference: ${_startTime.formatted12()} to ${_endTime.formatted12()} = ${diffResult.formattedDuration} ($hoursDecimal hours)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TimeSelectorTile(
                label: 'Start Time',
                selectedTime: _startTime,
                onTimeChanged: (val) => setState(() => _startTime = val),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TimeSelectorTile(
                label: 'End Time',
                selectedTime: _endTime,
                onTimeChanged: (val) => setState(() => _endTime = val),
              ),
            ),
          ],
        ),
        if (diffResult.isOvernight) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.tertiary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.nightlight_round, size: 16, color: theme.colorScheme.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Crosses midnight: Overnight duration (+1 day)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        ResultCard(
          title: 'DURATION DIFFERENCE',
          primaryValue: diffResult.formattedDuration,
          subtitle: '$hoursDecimal hours total',
          copyPayload: copyPayload,
          icon: Icons.timer_outlined,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricChip(label: 'Minutes', value: '$totalMinutes mins'),
                  _MetricChip(label: 'Seconds', value: '${diffResult.totalSeconds} secs'),
                  _MetricChip(label: 'Decimal', value: '$hoursDecimal hrs'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddSubtractTab(ThemeData theme) {
    final calcResult = TimeCalculationService.addSubtract(
      _baseTime,
      hours: _hoursToAdd,
      minutes: _minutesToAdd,
      seconds: _secondsToAdd,
      isSubtract: _isSubtract,
    );

    final copyPayload =
        '${_baseTime.formatted12()} ${_isSubtract ? "-" : "+"} $_hoursToAdd h $_minutesToAdd m $_secondsToAdd s = ${calcResult.resultTime.formatted12()} (${calcResult.dayOffsetBadge})';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TimeSelectorTile(
          label: 'Base Time',
          selectedTime: _baseTime,
          onTimeChanged: (val) => setState(() => _baseTime = val),
        ),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(
              value: false,
              label: Text('Add Time (+)'),
              icon: Icon(Icons.add),
            ),
            ButtonSegment<bool>(
              value: true,
              label: Text('Subtract Time (-)'),
              icon: Icon(Icons.remove),
            ),
          ],
          selected: {_isSubtract},
          onSelectionChanged: (val) => setState(() => _isSubtract = val.first),
        ),
        const SizedBox(height: 16),
        NumberStepperField(
          label: 'Hours',
          value: _hoursToAdd,
          min: 0,
          max: 999,
          onChanged: (val) => setState(() => _hoursToAdd = val),
        ),
        const SizedBox(height: 12),
        NumberStepperField(
          label: 'Minutes',
          value: _minutesToAdd,
          min: 0,
          max: 59,
          onChanged: (val) => setState(() => _minutesToAdd = val),
        ),
        const SizedBox(height: 12),
        NumberStepperField(
          label: 'Seconds',
          value: _secondsToAdd,
          min: 0,
          max: 59,
          onChanged: (val) => setState(() => _secondsToAdd = val),
        ),
        const SizedBox(height: 20),
        ResultCard(
          title: 'RESULTING TIME',
          primaryValue: calcResult.resultTime.formatted12(),
          subtitle: '24h Military: ${calcResult.resultTime.formatted24()}',
          copyPayload: copyPayload,
          icon: Icons.access_time_filled_rounded,
          content: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: calcResult.dayOffset == 0
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                  : theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              calcResult.dayOffsetBadge,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: calcResult.dayOffset == 0
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: RichText(
        text: TextSpan(
          text: '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          children: [
            TextSpan(
              text: value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
