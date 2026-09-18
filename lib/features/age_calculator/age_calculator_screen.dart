import 'package:flutter/material.dart';
import '../../core/services/date_calculation_service.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/widgets/date_selector_tile.dart';
import '../../shared/widgets/result_card.dart';

class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({super.key});

  @override
  State<AgeCalculatorScreen> createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  late DateTime _birthDate;
  late DateTime _asOfDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _asOfDate = DateTime(now.year, now.month, now.day);
    // Default birth date to 25 years ago
    _birthDate = DateTime(_asOfDate.year - 25, 1, 1);
  }

  void _reset() {
    setState(() {
      final now = DateTime.now();
      _asOfDate = DateTime(now.year, now.month, now.day);
      _birthDate = DateTime(_asOfDate.year - 25, 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final age = DateCalculationService.calculateAge(
      _birthDate,
      asOf: _asOfDate,
    );

    final nextBirthdayFormatted = AppUtils.formatFull(age.nextBirthday);

    final summary =
        'Age as of ${AppUtils.formatShort(_asOfDate)}: ${age.formattedAge} '
        '(${age.totalDaysLived} total days lived). Next birthday in ${age.daysToNextBirthday} days (${age.nextBirthdayWeekday}).';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Age Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset calculation',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Copy age summary',
            onPressed: () {
              AppUtils.copyToClipboard(
                context,
                summary,
                message: 'Age summary copied to clipboard',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DateSelectorTile(
            label: 'Date of Birth',
            selectedDate: _birthDate,
            lastDate: _asOfDate,
            onDateChanged: (dt) => setState(() => _birthDate = dt),
          ),
          const SizedBox(height: 12),
          DateSelectorTile(
            label: 'Calculate Age As Of',
            selectedDate: _asOfDate,
            onDateChanged: (dt) => setState(() => _asOfDate = dt),
          ),
          const SizedBox(height: 24),
          // Chronological Age Card
          ResultCard(
            title: 'CHRONOLOGICAL AGE',
            primaryValue: '${age.years} Years',
            subtitle: '${age.months} months, ${age.days} days',
            copyPayload: age.formattedAge,
            icon: Icons.cake_rounded,
            accentColor: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          // Total Days & Weeks Lived Card
          ResultCard(
            title: 'LIFETIME DURATION',
            primaryValue: '${age.totalDaysLived} Days',
            subtitle: '${age.totalWeeksLived} weeks lived so far',
            copyPayload: '${age.totalDaysLived} days lived',
            icon: Icons.hourglass_bottom_rounded,
            accentColor: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          // Next Birthday Card
          ResultCard(
            title: 'NEXT BIRTHDAY',
            primaryValue: age.daysToNextBirthday == 0
                ? 'Happy Birthday Today! 🎉'
                : 'In ${age.daysToNextBirthday} Days',
            subtitle: '$nextBirthdayFormatted (${age.nextBirthdayWeekday})'
                '${age.isBornOnLeapDay ? "\n(Leap-day birthday: Feb 29)" : ""}',
            copyPayload:
                'Next birthday: $nextBirthdayFormatted (${age.daysToNextBirthday} days remaining)',
            icon: Icons.celebration_rounded,
            accentColor: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }
}
