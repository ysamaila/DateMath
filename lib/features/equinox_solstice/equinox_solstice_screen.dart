import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/controllers/history_controller.dart';
import '../../core/services/astronomical_service.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/widgets/number_stepper_field.dart';

class EquinoxSolsticeScreen extends StatefulWidget {
  final HistoryController? historyController;

  const EquinoxSolsticeScreen({super.key, this.historyController});

  @override
  State<EquinoxSolsticeScreen> createState() => _EquinoxSolsticeScreenState();
}

class _EquinoxSolsticeScreenState extends State<EquinoxSolsticeScreen> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  void _reset() {
    setState(() {
      _selectedYear = DateTime.now().year;
    });
  }

  IconData _getEventIcon(SolarEventType type) {
    switch (type) {
      case SolarEventType.vernalEquinox:
        return Icons.spa_rounded;
      case SolarEventType.summerSolstice:
        return Icons.wb_sunny_rounded;
      case SolarEventType.autumnalEquinox:
        return Icons.eco_rounded;
      case SolarEventType.winterSolstice:
        return Icons.ac_unit_rounded;
    }
  }

  Color _getEventColor(SolarEventType type, ColorScheme scheme) {
    switch (type) {
      case SolarEventType.vernalEquinox:
        return Colors.green.shade600;
      case SolarEventType.summerSolstice:
        return Colors.orange.shade700;
      case SolarEventType.autumnalEquinox:
        return Colors.amber.shade800;
      case SolarEventType.winterSolstice:
        return Colors.blue.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final events = AstronomicalService.calculateSolarEvents(_selectedYear);

    final eventsList = events
        .map((e) => '${e.name}: ${DateFormat('yyyy-MM-dd HH:mm').format(e.localDateTime)}')
        .join(', ');
    final summary = '$_selectedYear Solar Events: $eventsList';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equinox & Solstice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Reset to current year',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy all events',
            onPressed: () {
              AppUtils.copyToClipboard(
                context,
                summary,
                message: 'Solar events copied to clipboard',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Year Selection Stepper
          NumberStepperField(
            label: 'Observation Year',
            value: _selectedYear,
            min: 1900,
            max: 2100,
            onChanged: (y) => setState(() => _selectedYear = y),
          ),
          const SizedBox(height: 10),

          // Quick Year Switcher
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ActionChip(
                  label: Text('${now.year - 1}'),
                  onPressed: () => setState(() => _selectedYear = now.year - 1),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Icon(Icons.today, size: 16),
                  label: Text('Current (${now.year})'),
                  onPressed: () => setState(() => _selectedYear = now.year),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: Text('${now.year + 1}'),
                  onPressed: () => setState(() => _selectedYear = now.year + 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Solar Events Cards
          ...events.map((event) {
            final color = _getEventColor(event.type, theme.colorScheme);
            final localFormatted = DateFormat('EEEE, MMMM d, y • HH:mm').format(event.localDateTime);
            final utcFormatted = DateFormat('yyyy-MM-dd HH:mm UTC').format(event.utcDateTime);

            final statusText = event.daysDifference == 0
                ? 'Today'
                : (event.isPast
                    ? '${event.daysDifference} days ago'
                    : 'in ${event.daysDifference} days');

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_getEventIcon(event.type), color: color, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${event.northernHemisphereSeason} (North)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: event.isPast
                                ? theme.colorScheme.surfaceContainerHighest
                                : theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: event.isPast
                                  ? theme.colorScheme.onSurfaceVariant
                                  : theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            localFormatted,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.public, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            utcFormatted,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                toolName: 'Equinox & Solstice',
                category: 'Astronomy',
                title: 'Solar Events for $_selectedYear',
                resultSummary:
                    'March ${events[0].localDateTime.day}, June ${events[1].localDateTime.day}, Sept ${events[2].localDateTime.day}, Dec ${events[3].localDateTime.day}',
              );
              AppUtils.copyToClipboard(
                context,
                summary,
                message: 'Solar events saved to history and copied to clipboard',
              );
            },
          ),
        ],
      ),
    );
  }
}
