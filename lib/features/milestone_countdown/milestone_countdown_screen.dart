import 'package:flutter/material.dart';
import '../../app/controllers/history_controller.dart';
import '../../core/services/milestone_service.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/widgets/date_selector_tile.dart';
import '../../shared/widgets/result_card.dart';

class MilestoneCountdownScreen extends StatefulWidget {
  final HistoryController? historyController;

  const MilestoneCountdownScreen({super.key, this.historyController});

  @override
  State<MilestoneCountdownScreen> createState() =>
      _MilestoneCountdownScreenState();
}

class _MilestoneCountdownScreenState extends State<MilestoneCountdownScreen> {
  final MilestoneService _milestoneService = const MilestoneService();
  final TextEditingController _titleController =
      TextEditingController(text: 'Project Deadline');

  late DateTime _startDate;
  late DateTime _targetDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _targetDate = MilestonePresets.endOfQuarter(now);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _reset() {
    final now = DateTime.now();
    setState(() {
      _titleController.text = 'Project Deadline';
      _startDate = DateTime(now.year, now.month, 1);
      _targetDate = MilestonePresets.endOfQuarter(now);
    });
  }

  void _applyPreset(DateTime date) {
    setState(() {
      _targetDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = _milestoneService.calculateMilestone(
      start: _startDate,
      target: _targetDate,
      currentDate: today,
    );

    final title = _titleController.text.trim().isEmpty
        ? 'Milestone'
        : _titleController.text.trim();

    String heroText;
    Color heroColor;
    if (result.isOverdue) {
      heroText = '${result.daysOverdue} Days Overdue';
      heroColor = theme.colorScheme.error;
    } else if (result.isReached) {
      heroText = 'Milestone Reached!';
      heroColor = Colors.green;
    } else {
      heroText = '${result.daysRemaining} Days Left';
      heroColor = theme.colorScheme.primary;
    }

    final summary =
        '$title: $heroText (${(result.percentComplete * 100).toStringAsFixed(1)}% complete, '
        '${result.workingDaysRemaining} working days remaining from ${AppUtils.formatShort(today)} to ${AppUtils.formatShort(_targetDate)})';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Milestone Countdown'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy Summary',
            onPressed: () {
              AppUtils.copyToClipboard(
                context,
                summary,
                message: 'Milestone summary copied to clipboard',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Milestone Title input
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Milestone Name',
              hintText: 'e.g. Product Launch, Wedding, Exam',
              prefixIcon: const Icon(Icons.flag_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),

          // Date Pickers
          Row(
            children: [
              Expanded(
                child: DateSelectorTile(
                  label: 'Start Date',
                  selectedDate: _startDate,
                  onDateChanged: (d) => setState(() => _startDate = d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DateSelectorTile(
                  label: 'Target Date',
                  selectedDate: _targetDate,
                  onDateChanged: (d) => setState(() => _targetDate = d),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Preset Chips
          Text(
            'Quick Target Presets',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              ActionChip(
                label: const Text('Next Month'),
                onPressed: () =>
                    _applyPreset(MilestonePresets.nextMonthEnd(today)),
              ),
              ActionChip(
                label: const Text('Quarter End'),
                onPressed: () =>
                    _applyPreset(MilestonePresets.endOfQuarter(today)),
              ),
              ActionChip(
                label: const Text('Year End'),
                onPressed: () => _applyPreset(MilestonePresets.endOfYear(today)),
              ),
              ActionChip(
                label: const Text('+100 Days'),
                onPressed: () =>
                    _applyPreset(MilestonePresets.addDays(today, 100)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Hero Countdown Card
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    heroText,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: heroColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: result.percentComplete,
                      minHeight: 12,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(heroColor),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(result.percentComplete * 100).toStringAsFixed(1)}% Complete',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${result.daysElapsed} of ${result.totalDays} Days',
                        style: theme.textTheme.bodySmall?.copyWith(
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

          // Detailed Metrics Card
          ResultCard(
            title: 'COUNTDOWN METRICS',
            primaryValue: '${result.workingDaysRemaining} Working Days Left',
            subtitle:
                'Target Date: ${AppUtils.formatFull(_targetDate)}',
            copyPayload: summary,
            icon: Icons.timer_outlined,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _buildMetricRow('Calendar Days Remaining', '${result.daysRemaining}'),
                _buildMetricRow('Working Days Remaining (excl. weekends)',
                    '${result.workingDaysRemaining}'),
                _buildMetricRow('Days Elapsed So Far', '${result.daysElapsed}'),
                _buildMetricRow('Total Timeline Span', '${result.totalDays} days'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Save to History Button
          FilledButton.tonalIcon(
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save Milestone to History'),
            onPressed: () {
              widget.historyController?.addEntry(
                toolName: 'Milestone Countdown',
                category: 'Work & Planning',
                title: '$title (${AppUtils.formatShort(_targetDate)})',
                resultSummary: heroText,
              );
              AppUtils.copyToClipboard(
                context,
                summary,
                message: 'Milestone saved to history and copied to clipboard',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
