import 'package:flutter/material.dart';
import '../../app/controllers/history_controller.dart';
import '../../core/services/recurrence_service.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/widgets/date_selector_tile.dart';
import '../../shared/widgets/number_stepper_field.dart';

class RecurrencePlannerScreen extends StatefulWidget {
  final HistoryController? historyController;

  const RecurrencePlannerScreen({super.key, this.historyController});

  @override
  State<RecurrencePlannerScreen> createState() =>
      _RecurrencePlannerScreenState();
}

class _RecurrencePlannerScreenState extends State<RecurrencePlannerScreen> {
  final RecurrenceService _recurrenceService = const RecurrenceService();

  late DateTime _startDate;
  RecurrenceFrequency _frequency = RecurrenceFrequency.weekly;
  int _interval = 1;
  Set<int> _selectedWeekdays = {DateTime.monday};
  int _count = 10;

  // Monthly specific
  bool _monthlyByWeekday = false;
  int _monthlyOrdinal = 1; // 1=first, 2=second, 3=third, 4=fourth, -1=last
  int _monthlyWeekday = DateTime.monday;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
  }

  void _reset() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, now.day);
      _frequency = RecurrenceFrequency.weekly;
      _interval = 1;
      _selectedWeekdays = {DateTime.monday};
      _count = 10;
      _monthlyByWeekday = false;
      _monthlyOrdinal = 1;
      _monthlyWeekday = DateTime.monday;
    });
  }

  String _formatPatternDescription() {
    switch (_frequency) {
      case RecurrenceFrequency.daily:
        return _interval == 1 ? 'Every day' : 'Every $_interval days';
      case RecurrenceFrequency.weekly:
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final selectedNames =
            _selectedWeekdays.map((d) => days[d - 1]).join(', ');
        return _interval == 1
            ? 'Every week on $selectedNames'
            : 'Every $_interval weeks on $selectedNames';
      case RecurrenceFrequency.monthlyByDay:
        return _interval == 1
            ? 'Monthly on day ${_startDate.day}'
            : 'Every $_interval months on day ${_startDate.day}';
      case RecurrenceFrequency.monthlyByWeekday:
        final ordinals = {1: '1st', 2: '2nd', 3: '3rd', 4: '4th', -1: 'last'};
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final ordStr = ordinals[_monthlyOrdinal] ?? '1st';
        final dayStr = days[_monthlyWeekday - 1];
        return _interval == 1
            ? 'Monthly on the $ordStr $dayStr'
            : 'Every $_interval months on the $ordStr $dayStr';
      case RecurrenceFrequency.yearly:
        return _interval == 1
            ? 'Annually on ${AppUtils.formatShort(_startDate)}'
            : 'Every $_interval years on ${AppUtils.formatShort(_startDate)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    RecurrenceFrequency effectiveFreq = _frequency;
    if (_frequency == RecurrenceFrequency.monthlyByDay && _monthlyByWeekday) {
      effectiveFreq = RecurrenceFrequency.monthlyByWeekday;
    }

    final pattern = RecurrencePattern(
      frequency: effectiveFreq,
      interval: _interval,
      weekdays: _selectedWeekdays,
      dayOfMonth: _startDate.day,
      monthlyOrdinal: _monthlyOrdinal,
      monthlyWeekday: _monthlyWeekday,
    );

    final occurrences = _recurrenceService.generateOccurrences(
      startDate: _startDate,
      pattern: pattern,
      count: _count,
    );

    final patternDesc = _formatPatternDescription();

    final scheduleExport = occurrences.map((occ) {
      final relative = occ.daysFromToday == 0
          ? 'Today'
          : (occ.daysFromToday > 0
              ? 'in ${occ.daysFromToday}d'
              : '${occ.daysFromToday.abs()}d ago');
      return '#${occ.index}: ${AppUtils.formatFull(occ.date)} ($relative)';
    }).join('\n');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurrence Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Export Schedule',
            onPressed: () {
              final payload =
                  '=== Recurrence Schedule ($patternDesc) ===\n$scheduleExport';
              AppUtils.copyToClipboard(
                context,
                payload,
                message: 'Schedule exported to clipboard',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DateSelectorTile(
            label: 'Schedule Start Date',
            selectedDate: _startDate,
            onDateChanged: (d) => setState(() => _startDate = d),
          ),
          const SizedBox(height: 12),

          // Frequency selector
          Text(
            'Recurrence Frequency',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          SegmentedButton<RecurrenceFrequency>(
            segments: const [
              ButtonSegment(
                value: RecurrenceFrequency.daily,
                label: Text('Daily'),
              ),
              ButtonSegment(
                value: RecurrenceFrequency.weekly,
                label: Text('Weekly'),
              ),
              ButtonSegment(
                value: RecurrenceFrequency.monthlyByDay,
                label: Text('Monthly'),
              ),
              ButtonSegment(
                value: RecurrenceFrequency.yearly,
                label: Text('Yearly'),
              ),
            ],
            selected: {_frequency},
            onSelectionChanged: (val) =>
                setState(() => _frequency = val.first),
          ),
          const SizedBox(height: 12),

          // Interval Stepper
          NumberStepperField(
            label: _frequency == RecurrenceFrequency.daily
                ? 'Every X Days'
                : (_frequency == RecurrenceFrequency.weekly
                    ? 'Every X Weeks'
                    : (_frequency == RecurrenceFrequency.yearly
                        ? 'Every X Years'
                        : 'Every X Months')),
            value: _interval,
            min: 1,
            max: 52,
            onChanged: (v) => setState(() => _interval = v),
          ),
          const SizedBox(height: 12),

          // Weekly: Weekday Selection Chips
          if (_frequency == RecurrenceFrequency.weekly) ...[
            Text(
              'Repeat On',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                {'label': 'M', 'day': DateTime.monday},
                {'label': 'T', 'day': DateTime.tuesday},
                {'label': 'W', 'day': DateTime.wednesday},
                {'label': 'T', 'day': DateTime.thursday},
                {'label': 'F', 'day': DateTime.friday},
                {'label': 'S', 'day': DateTime.saturday},
                {'label': 'S', 'day': DateTime.sunday},
              ].map((item) {
                final dayInt = item['day'] as int;
                final isSelected = _selectedWeekdays.contains(dayInt);
                return FilterChip(
                  label: Text(item['label'] as String),
                  selected: isSelected,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedWeekdays.add(dayInt);
                      } else {
                        if (_selectedWeekdays.length > 1) {
                          _selectedWeekdays.remove(dayInt);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Monthly rule toggle
          if (_frequency == RecurrenceFrequency.monthlyByDay) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    _monthlyByWeekday
                        ? 'Rule: By weekday of month'
                        : 'Rule: By fixed day of month (${_startDate.day}th)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: _monthlyByWeekday,
                  onChanged: (val) => setState(() => _monthlyByWeekday = val),
                ),
              ],
            ),
            if (_monthlyByWeekday) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _monthlyOrdinal,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('1st')),
                        DropdownMenuItem(value: 2, child: Text('2nd')),
                        DropdownMenuItem(value: 3, child: Text('3rd')),
                        DropdownMenuItem(value: 4, child: Text('4th')),
                        DropdownMenuItem(value: -1, child: Text('Last')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _monthlyOrdinal = v);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _monthlyWeekday,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: DateTime.monday, child: Text('Monday')),
                        DropdownMenuItem(
                            value: DateTime.tuesday, child: Text('Tuesday')),
                        DropdownMenuItem(
                            value: DateTime.wednesday,
                            child: Text('Wednesday')),
                        DropdownMenuItem(
                            value: DateTime.thursday, child: Text('Thursday')),
                        DropdownMenuItem(
                            value: DateTime.friday, child: Text('Friday')),
                        DropdownMenuItem(
                            value: DateTime.saturday, child: Text('Saturday')),
                        DropdownMenuItem(
                            value: DateTime.sunday, child: Text('Sunday')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _monthlyWeekday = v);
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
          ],

          // Limit Count Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Occurrences to Generate',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Wrap(
                spacing: 6,
                children: [10, 25, 50].map((c) {
                  return ChoiceChip(
                    label: Text('$c'),
                    selected: _count == c,
                    visualDensity: VisualDensity.compact,
                    onSelected: (selected) {
                      if (selected) setState(() => _count = c);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pattern Summary Header Card
          Card(
            margin: EdgeInsets.zero,
            color: theme.colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.event_repeat_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patternDesc,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Showing next $_count occurrences',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.save_outlined, size: 20),
                    tooltip: 'Save to History',
                    onPressed: () {
                      widget.historyController?.addEntry(
                        toolName: 'Recurrence Planner',
                        category: 'Work & Planning',
                        title: patternDesc,
                        resultSummary: 'Next $_count occurrences generated',
                      );
                      AppUtils.copyToClipboard(
                        context,
                        '=== Recurrence Schedule ($patternDesc) ===\n$scheduleExport',
                        message: 'Schedule saved to history and copied',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Timeline Occurrence Tiles
          ...occurrences.map((occ) {
            final isToday = occ.daysFromToday == 0;
            final isPast = occ.daysFromToday < 0;

            String relativeLabel;
            if (isToday) {
              relativeLabel = 'Today';
            } else if (isPast) {
              relativeLabel = '${occ.daysFromToday.abs()} days ago';
            } else {
              relativeLabel = 'In ${occ.daysFromToday} days';
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 14,
                  backgroundColor: isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  child: Text(
                    '#${occ.index}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isToday
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                title: Text(
                  AppUtils.formatFull(occ.date),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Week ${_getIsoWeek(occ.date)} • $relativeLabel',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isToday
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 16),
                  onPressed: () {
                    AppUtils.copyToClipboard(
                      context,
                      AppUtils.formatFull(occ.date),
                      message: 'Date copied',
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  int _getIsoWeek(DateTime date) {
    final dayOfYear = int.parse(
        date.difference(DateTime(date.year, 1, 1)).inDays.toString());
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}
