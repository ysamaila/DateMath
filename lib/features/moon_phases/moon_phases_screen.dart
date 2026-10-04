import 'package:flutter/material.dart';
import '../../app/controllers/history_controller.dart';
import '../../core/services/astronomical_service.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/widgets/date_selector_tile.dart';
import '../../shared/widgets/result_card.dart';

class MoonPhasesScreen extends StatefulWidget {
  final HistoryController? historyController;

  const MoonPhasesScreen({super.key, this.historyController});

  @override
  State<MoonPhasesScreen> createState() => _MoonPhasesScreenState();
}

class _MoonPhasesScreenState extends State<MoonPhasesScreen> {
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

  IconData _getMoonIcon(MoonPhase phase) {
    switch (phase) {
      case MoonPhase.newMoon:
        return Icons.radio_button_unchecked;
      case MoonPhase.waxingCrescent:
        return Icons.nightlight_outlined;
      case MoonPhase.firstQuarter:
        return Icons.contrast_rounded;
      case MoonPhase.waxingGibbous:
        return Icons.brightness_medium_rounded;
      case MoonPhase.fullMoon:
        return Icons.brightness_1_rounded;
      case MoonPhase.waningGibbous:
        return Icons.brightness_medium_outlined;
      case MoonPhase.lastQuarter:
        return Icons.tonality_rounded;
      case MoonPhase.waningCrescent:
        return Icons.nightlight_round;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moonInfo = AstronomicalService.calculateMoonPhase(_selectedDate);

    final summary =
        '${AppUtils.formatFull(_selectedDate)} Moon Phase: ${moonInfo.name}, '
        '${moonInfo.illuminationPercentage.toStringAsFixed(1)}% illuminated, '
        'Age: ${moonInfo.ageInDays.toStringAsFixed(1)} days (${moonInfo.isWaxing ? "Waxing" : "Waning"}).';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moon Phases'),
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
                message: 'Moon phase details copied to clipboard',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DateSelectorTile(
            label: 'Observation Date',
            selectedDate: _selectedDate,
            onDateChanged: (dt) => setState(() => _selectedDate = dt),
          ),
          const SizedBox(height: 16),

          // Hero Moon Phase Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(
                    _getMoonIcon(moonInfo.phase),
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    moonInfo.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${moonInfo.illuminationPercentage.toStringAsFixed(1)}% Illuminated',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: moonInfo.illuminationPercentage / 100.0,
                      minHeight: 10,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Chip(
                        avatar: Icon(
                          moonInfo.isWaxing ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          size: 16,
                        ),
                        label: Text(moonInfo.isWaxing ? 'Waxing' : 'Waning'),
                      ),
                      Chip(
                        avatar: const Icon(Icons.timer_outlined, size: 16),
                        label: Text('Age: ${moonInfo.ageInDays.toStringAsFixed(1)}d'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lunar Cycle Details
          ResultCard(
            title: 'LUNAR CYCLE PROGRESS',
            primaryValue: '${moonInfo.ageInDays.toStringAsFixed(1)} of 29.5 days',
            subtitle: '${(moonInfo.fraction * 100).toStringAsFixed(1)}% of synodic month completed',
            copyPayload: '${moonInfo.ageInDays.toStringAsFixed(1)} days into synodic cycle',
            icon: Icons.timelapse_rounded,
          ),
          const SizedBox(height: 16),

          // Upcoming Primary Phases Section
          Text(
            'Upcoming Primary Phases',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          ...moonInfo.upcomingPhases.map((phase) {
            final daysText = phase.daysAway == 0
                ? 'Today'
                : (phase.daysAway == 1 ? 'Tomorrow' : 'in ${phase.daysAway} days');
            return Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.colorScheme.outlineVariant),
              ),
              child: ListTile(
                leading: Icon(
                  _getMoonIcon(phase.phase),
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                title: Text(
                  phase.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(AppUtils.formatFull(phase.targetDate)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    daysText,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Save to History Action
          FilledButton.tonalIcon(
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save to Calculation History'),
            onPressed: () {
              widget.historyController?.addEntry(
                toolName: 'Moon Phases',
                category: 'Astronomy',
                title: '${moonInfo.name} (${AppUtils.formatShort(_selectedDate)})',
                resultSummary:
                    '${moonInfo.illuminationPercentage.toStringAsFixed(1)}% illuminated, Age ${moonInfo.ageInDays.toStringAsFixed(1)}d',
              );
              AppUtils.copyToClipboard(
                context,
                summary,
                message: 'Moon phase saved to history and copied to clipboard',
              );
            },
          ),
        ],
      ),
    );
  }
}
