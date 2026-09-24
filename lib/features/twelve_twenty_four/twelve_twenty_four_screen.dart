import 'package:flutter/material.dart';
import '../../core/services/time_calculation_service.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/time_selector_tile.dart';

class TwelveTwentyFourScreen extends StatefulWidget {
  const TwelveTwentyFourScreen({super.key});

  @override
  State<TwelveTwentyFourScreen> createState() => _TwelveTwentyFourScreenState();
}

class _TwelveTwentyFourScreenState extends State<TwelveTwentyFourScreen> {
  late ClockTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = ClockTime.fromDateTime(DateTime.now());
  }

  void _reset() {
    setState(() {
      _currentTime = ClockTime.fromDateTime(DateTime.now());
    });
  }

  void _setTime(int hour, int minute) {
    setState(() {
      _currentTime = ClockTime(hour: hour, minute: minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final milResult = TimeCalculationService.toMilitary(_currentTime);

    final copySummary =
        '12h: ${milResult.format12} | 24h: ${milResult.format24} | Military: ${milResult.militaryDesignation} ("${milResult.spokenMilitary}")';

    return Scaffold(
      appBar: AppBar(
        title: const Text('12h / 24h Military Time'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to Current Time',
            onPressed: _reset,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TimeSelectorTile(
            label: 'Selected Time',
            selectedTime: _currentTime,
            onTimeChanged: (val) => setState(() => _currentTime = val),
          ),
          const SizedBox(height: 12),

          // Preset Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickTimeChip(
                  label: 'Midnight (00:00)',
                  onTap: () => _setTime(0, 0),
                ),
                const SizedBox(width: 8),
                _QuickTimeChip(
                  label: '06:00 AM (0600)',
                  onTap: () => _setTime(6, 0),
                ),
                const SizedBox(width: 8),
                _QuickTimeChip(
                  label: 'Noon (12:00)',
                  onTap: () => _setTime(12, 0),
                ),
                const SizedBox(width: 8),
                _QuickTimeChip(
                  label: '06:30 PM (1830)',
                  onTap: () => _setTime(18, 30),
                ),
                const SizedBox(width: 8),
                _QuickTimeChip(
                  label: '11:59 PM (2359)',
                  onTap: () => _setTime(23, 59),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Primary Military Conversion Showcase Card
          ResultCard(
            title: 'MILITARY DESIGNATION',
            primaryValue: milResult.militaryDesignation,
            subtitle: 'Standard 24-hour format: ${milResult.format24}',
            copyPayload: copySummary,
            icon: Icons.shield_outlined,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.record_voice_over_outlined,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Spoken Military Convention:',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '"${milResult.spokenMilitary}"',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Day Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Day Progress:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${milResult.dayPercentage.toStringAsFixed(1)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: milResult.dayPercentage / 100.0,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Dual Comparison Grid
          Row(
            children: [
              Expanded(
                child: _FormatCard(
                  label: '12-Hour (AM/PM)',
                  value: milResult.format12,
                  icon: Icons.wb_sunny_outlined,
                  onCopy: () => AppUtils.copyToClipboard(context, milResult.format12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FormatCard(
                  label: '24-Hour Military',
                  value: milResult.format24,
                  icon: Icons.timelapse_rounded,
                  onCopy: () => AppUtils.copyToClipboard(context, milResult.format24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Reference Cheat Sheet Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Military Time Reference',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _ReferenceRow(time12: '12:00 AM (Midnight)', mil: '0000 Hours', spoken: 'Zero zero zero zero'),
                  const Divider(height: 16),
                  const _ReferenceRow(time12: '06:00 AM', mil: '0600 Hours', spoken: 'Zero six hundred'),
                  const Divider(height: 16),
                  const _ReferenceRow(time12: '12:00 PM (Noon)', mil: '1200 Hours', spoken: 'Twelve hundred'),
                  const Divider(height: 16),
                  const _ReferenceRow(time12: '06:00 PM', mil: '1800 Hours', spoken: 'Eighteen hundred'),
                  const Divider(height: 16),
                  const _ReferenceRow(time12: '11:59 PM', mil: '2359 Hours', spoken: 'Twenty-three hundred fifty-nine'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onCopy;

  const _FormatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined, size: 14),
                  tooltip: 'Copy',
                  visualDensity: VisualDensity.compact,
                  onPressed: onCopy,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickTimeChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickTimeChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  final String time12;
  final String mil;
  final String spoken;

  const _ReferenceRow({
    required this.time12,
    required this.mil,
    required this.spoken,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            time12,
            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            mil,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            spoken,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
