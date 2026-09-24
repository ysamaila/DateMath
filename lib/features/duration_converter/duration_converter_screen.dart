import 'package:flutter/material.dart';
import '../../core/services/time_calculation_service.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/widgets/result_card.dart';

class DurationConverterScreen extends StatefulWidget {
  const DurationConverterScreen({super.key});

  @override
  State<DurationConverterScreen> createState() => _DurationConverterScreenState();
}

class _DurationConverterScreenState extends State<DurationConverterScreen> {
  final TextEditingController _inputController = TextEditingController(text: '3600');
  DurationUnit _selectedUnit = DurationUnit.seconds;
  double _currentValue = 3600;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final val = double.tryParse(_inputController.text.trim()) ?? 0.0;
    setState(() {
      _currentValue = val;
    });
  }

  void _setPreset(double val, DurationUnit unit) {
    setState(() {
      _selectedUnit = unit;
      _currentValue = val;
      _inputController.text = val % 1 == 0 ? val.toInt().toString() : val.toString();
    });
  }

  void _reset() {
    _setPreset(3600, DurationUnit.seconds);
  }

  String _formatNumber(double val) {
    if (val.isInfinite || val.isNaN) return '0';
    if (val.abs() >= 1e12 || (val.abs() > 0 && val.abs() < 1e-4)) {
      return val.toStringAsExponential(4);
    }
    if (val % 1 == 0) {
      return val.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
    }
    // Up to 4 decimal places without trailing zeroes
    final fixed = val.toStringAsFixed(4);
    return fixed.replaceAll(RegExp(r'\.?0+$'), '');
  }

  String _unitLabel(DurationUnit unit) {
    switch (unit) {
      case DurationUnit.milliseconds:
        return 'Milliseconds (ms)';
      case DurationUnit.seconds:
        return 'Seconds (s)';
      case DurationUnit.minutes:
        return 'Minutes (m)';
      case DurationUnit.hours:
        return 'Hours (h)';
      case DurationUnit.days:
        return 'Days (d)';
      case DurationUnit.weeks:
        return 'Weeks (w)';
    }
  }

  String _unitAbbr(DurationUnit unit) {
    switch (unit) {
      case DurationUnit.milliseconds:
        return 'ms';
      case DurationUnit.seconds:
        return 'sec';
      case DurationUnit.minutes:
        return 'min';
      case DurationUnit.hours:
        return 'hr';
      case DurationUnit.days:
        return 'day';
      case DurationUnit.weeks:
        return 'wk';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = TimeCalculationService.convertDuration(_currentValue, _selectedUnit);

    final summary =
        '${_formatNumber(_currentValue)} ${_unitAbbr(_selectedUnit)} = ${result.compositeBreakdown}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Duration Converter'),
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
          // Input row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _inputController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Value',
                    border: const OutlineInputBorder(),
                    suffixIcon: _inputController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _inputController.clear();
                              setState(() => _currentValue = 0);
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DurationUnit>(
                      value: _selectedUnit,
                      isExpanded: true,
                      items: DurationUnit.values.map((unit) {
                        return DropdownMenuItem<DurationUnit>(
                          value: unit,
                          child: Text(
                            _unitLabel(unit),
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedUnit = val);
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Preset Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _PresetChip(
                  label: '1 min',
                  onTap: () => _setPreset(1, DurationUnit.minutes),
                ),
                const SizedBox(width: 8),
                _PresetChip(
                  label: '1 hr',
                  onTap: () => _setPreset(1, DurationUnit.hours),
                ),
                const SizedBox(width: 8),
                _PresetChip(
                  label: '1 day',
                  onTap: () => _setPreset(1, DurationUnit.days),
                ),
                const SizedBox(width: 8),
                _PresetChip(
                  label: '1 week',
                  onTap: () => _setPreset(1, DurationUnit.weeks),
                ),
                const SizedBox(width: 8),
                _PresetChip(
                  label: '3,600s',
                  onTap: () => _setPreset(3600, DurationUnit.seconds),
                ),
                const SizedBox(width: 8),
                _PresetChip(
                  label: '86,400s',
                  onTap: () => _setPreset(86400, DurationUnit.seconds),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Composite breakdown Card
          ResultCard(
            title: 'COMPOSITE BREAKDOWN',
            primaryValue: result.compositeBreakdown.isEmpty ? '0 sec' : result.compositeBreakdown,
            subtitle: 'Equivalent duration breakdown',
            copyPayload: summary,
            icon: Icons.access_time_rounded,
          ),
          const SizedBox(height: 16),

          Text(
            'All Unit Conversions',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),

          // All units conversion list
          ...DurationUnit.values.map((unit) {
            final convertedVal = result.conversions[unit] ?? 0.0;
            final isCurrent = unit == _selectedUnit;
            final formattedVal = _formatNumber(convertedVal);
            final copyText = '$formattedVal ${_unitAbbr(unit)}';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isCurrent
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  width: isCurrent ? 2 : 1,
                ),
              ),
              color: isCurrent
                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25)
                  : theme.colorScheme.surface,
              child: ListTile(
                title: Text(
                  _unitLabel(unit),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedVal,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isCurrent
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined, size: 16),
                      tooltip: 'Copy',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => AppUtils.copyToClipboard(context, copyText),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
  }
}
