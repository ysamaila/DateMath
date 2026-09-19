import 'package:flutter/material.dart';
import '../../core/services/date_calculation_service.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/widgets/date_selector_tile.dart';
import '../../shared/widgets/number_stepper_field.dart';
import '../../shared/widgets/result_card.dart';

class AddSubtractDateScreen extends StatefulWidget {
  const AddSubtractDateScreen({super.key});

  @override
  State<AddSubtractDateScreen> createState() => _AddSubtractDateScreenState();
}

class _AddSubtractDateScreenState extends State<AddSubtractDateScreen> {
  late DateTime _baseDate;
  bool _isSubtract = false;
  int _years = 0;
  int _months = 1;
  int _weeks = 0;
  int _days = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _baseDate = DateTime(now.year, now.month, now.day);
  }

  void _reset() {
    setState(() {
      final now = DateTime.now();
      _baseDate = DateTime(now.year, now.month, now.day);
      _isSubtract = false;
      _years = 0;
      _months = 1;
      _weeks = 0;
      _days = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final calculation = DateCalculationService.addOrSubtractDate(
      _baseDate,
      years: _years,
      months: _months,
      weeks: _weeks,
      days: _days,
      isSubtract: _isSubtract,
    );

    final resultFormatted = AppUtils.formatFull(calculation.resultDate);
    final isoFormatted = AppUtils.formatIso(calculation.resultDate);

    final summary =
        '${_isSubtract ? "Subtracted" : "Added"} ${_years > 0 ? "$_years yrs " : ""}${_months > 0 ? "$_months mos " : ""}${_weeks > 0 ? "$_weeks wks " : ""}${_days > 0 ? "$_days days " : ""}to ${AppUtils.formatShort(_baseDate)} = $resultFormatted';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add / Subtract Date'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Reset calculation',
            onPressed: _reset,
          ),
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy result',
            onPressed: () {
              AppUtils.copyToClipboard(
                context,
                summary,
                message: 'Result copied to clipboard',
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          DateSelectorTile(
            label: 'Base Date',
            selectedDate: _baseDate,
            onDateChanged: (dt) => setState(() => _baseDate = dt),
          ),
          const SizedBox(height: 12),
          // Clean Add / Subtract Segmented Button
          Center(
            child: SegmentedButton<bool>(
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
              onSelectionChanged: (set) {
                setState(() => _isSubtract = set.first);
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Time Intervals to ${_isSubtract ? "Subtract" : "Add"}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          NumberStepperField(
            label: 'Years',
            value: _years,
            onChanged: (val) => setState(() => _years = val),
          ),
          const SizedBox(height: 8),
          NumberStepperField(
            label: 'Months',
            value: _months,
            onChanged: (val) => setState(() => _months = val),
          ),
          const SizedBox(height: 8),
          NumberStepperField(
            label: 'Weeks',
            value: _weeks,
            onChanged: (val) => setState(() => _weeks = val),
          ),
          const SizedBox(height: 8),
          NumberStepperField(
            label: 'Days',
            value: _days,
            onChanged: (val) => setState(() => _days = val),
          ),
          const SizedBox(height: 16),
          // Prominent Result Card
          ResultCard(
            title: _isSubtract ? 'RESULTING DATE (SUBTRACTED)' : 'RESULTING DATE (ADDED)',
            primaryValue: resultFormatted,
            subtitle: 'ISO Format: $isoFormatted',
            copyPayload: resultFormatted,
            icon: Icons.event_available_outlined,
          ),
        ],
      ),
    );
  }
}
