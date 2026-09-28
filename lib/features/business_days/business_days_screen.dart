import 'package:flutter/material.dart';
import '../../app/controllers/history_controller.dart';
import '../../core/data/holidays_data.dart';
import '../../core/models/custom_holiday.dart';
import '../../core/services/work_calendar_service.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/widgets/date_selector_tile.dart';
import '../../shared/widgets/number_stepper_field.dart';
import '../../shared/widgets/result_card.dart';

class BusinessDaysScreen extends StatefulWidget {
  final HistoryController? historyController;

  const BusinessDaysScreen({super.key, this.historyController});

  @override
  State<BusinessDaysScreen> createState() => _BusinessDaysScreenState();
}

class _BusinessDaysScreenState extends State<BusinessDaysScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final WorkCalendarService _calendarService = const WorkCalendarService();

  // Tab 1 state: Between Dates
  late DateTime _startDate;
  late DateTime _endDate;
  bool _includeEndDate = true;

  // Tab 2 state: Add / Subtract
  late DateTime _addBaseDate;
  int _daysToAdd = 10;
  bool _isAdd = true;

  // Shared settings
  Set<int> _weekendDays = {DateTime.saturday, DateTime.sunday};
  String _selectedRegion = 'United States';
  List<CustomHoliday> _holidays = [];
  final List<CustomHoliday> _customHolidays = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, now.day);
    _endDate = _startDate.add(const Duration(days: 30));
    _addBaseDate = _startDate;
    _refreshHolidays();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshHolidays() {
    final year = _startDate.year;
    final regional = HolidaysData.getHolidaysForRegion(_selectedRegion, year);
    setState(() {
      _holidays = [...regional, ..._customHolidays];
    });
  }

  void _reset() {
    final now = DateTime.now();
    setState(() {
      _startDate = DateTime(now.year, now.month, now.day);
      _endDate = _startDate.add(const Duration(days: 30));
      _addBaseDate = _startDate;
      _daysToAdd = 10;
      _isAdd = true;
      _includeEndDate = true;
      _weekendDays = {DateTime.saturday, DateTime.sunday};
      _selectedRegion = 'United States';
      _customHolidays.clear();
      _refreshHolidays();
    });
  }

  void _swapDates() {
    setState(() {
      final tmp = _startDate;
      _startDate = _endDate;
      _endDate = tmp;
    });
  }

  void _showHolidaySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.65,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Holiday Settings',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Custom'),
                            onPressed: () => _showAddHolidayDialog(setSheetState),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Regional Preset',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedRegion,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        items: HolidaysData.regions.map((r) {
                          return DropdownMenuItem(value: r, child: Text(r));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedRegion = val;
                              _refreshHolidays();
                            });
                            setSheetState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Observed Holidays (${_holidays.length})',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ..._holidays.map((h) {
                        final isCustom = _customHolidays.any((c) => c.id == h.id);
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(h.name),
                          subtitle: Text(AppUtils.formatShort(h.date)),
                          trailing: isCustom
                              ? IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 18, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _customHolidays
                                          .removeWhere((c) => c.id == h.id);
                                      _refreshHolidays();
                                    });
                                    setSheetState(() {});
                                  },
                                )
                              : null,
                        );
                      }),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddHolidayDialog(StateSetter setSheetState) {
    final nameController = TextEditingController();
    var pickedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              title: const Text('Add Custom Holiday'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Holiday Name',
                      hintText: 'e.g. Company Picnic',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppUtils.formatShort(pickedDate)),
                      TextButton(
                        child: const Text('Select Date'),
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: pickedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (d != null) {
                            setDialogState(() {
                              pickedDate = d;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      final newH = CustomHoliday(
                        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        date: pickedDate,
                      );
                      setState(() {
                        _customHolidays.add(newH);
                        _refreshHolidays();
                      });
                      setSheetState(() {});
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildWeekendSelector() {
    final days = [
      {'label': 'M', 'day': DateTime.monday},
      {'label': 'T', 'day': DateTime.tuesday},
      {'label': 'W', 'day': DateTime.wednesday},
      {'label': 'T', 'day': DateTime.thursday},
      {'label': 'F', 'day': DateTime.friday},
      {'label': 'S', 'day': DateTime.saturday},
      {'label': 'S', 'day': DateTime.sunday},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weekend Days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            InkWell(
              onTap: _showHolidaySheet,
              child: Text(
                '$_selectedRegion (${_holidays.length} holidays)',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((d) {
            final dayInt = d['day'] as int;
            final isWeekend = _weekendDays.contains(dayInt);
            return FilterChip(
              label: Text(d['label'] as String),
              selected: isWeekend,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _weekendDays.add(dayInt);
                  } else {
                    if (_weekendDays.length > 1) {
                      _weekendDays.remove(dayInt);
                    }
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Days'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Between Dates'),
            Tab(text: 'Add / Subtract'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBetweenDatesTab(),
          _buildAddSubtractTab(),
        ],
      ),
    );
  }

  Widget _buildBetweenDatesTab() {
    final result = _calendarService.countBusinessDays(
      start: _startDate,
      end: _endDate,
      weekendDays: _weekendDays,
      holidays: _holidays,
      includeEndDate: _includeEndDate,
    );

    final summary =
        '${result.businessDays} business days (${result.totalDays} total, ${result.weekendDays} weekend, ${result.holidayDays} holidays)';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: DateSelectorTile(
                label: 'Start Date',
                selectedDate: _startDate,
                onDateChanged: (d) => setState(() => _startDate = d),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.swap_horiz_outlined),
              tooltip: 'Swap dates',
              onPressed: _swapDates,
            ),
            Expanded(
              child: DateSelectorTile(
                label: 'End Date',
                selectedDate: _endDate,
                onDateChanged: (d) => setState(() => _endDate = d),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildWeekendSelector(),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Include End Date in calculation'),
          value: _includeEndDate,
          onChanged: (val) => setState(() => _includeEndDate = val),
        ),
        const SizedBox(height: 16),
        ResultCard(
          title: 'WORKING DAYS',
          primaryValue: '${result.businessDays} Days',
          subtitle: '${result.percentageWorking.toStringAsFixed(1)}% of total period',
          copyPayload: summary,
          icon: Icons.business_center_outlined,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              _buildMetricRow('Calendar Days', '${result.totalDays}'),
              _buildMetricRow('Weekend Days Excluded', '${result.weekendDays}'),
              _buildMetricRow('Holidays Excluded', '${result.holidayDays}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Save to History'),
          onPressed: () {
            widget.historyController?.addEntry(
              toolName: 'Business Days',
              category: 'Work & Planning',
              title:
                  '${AppUtils.formatShort(_startDate)} → ${AppUtils.formatShort(_endDate)}',
              resultSummary: '${result.businessDays} working days',
            );
            AppUtils.copyToClipboard(
              context,
              summary,
              message: 'Saved to history and copied to clipboard',
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddSubtractTab() {
    final signedDays = _isAdd ? _daysToAdd : -_daysToAdd;
    final result = _calendarService.addBusinessDays(
      start: _addBaseDate,
      days: signedDays,
      weekendDays: _weekendDays,
      holidays: _holidays,
    );

    final summary =
        '${_isAdd ? "Add" : "Subtract"} $_daysToAdd business days from ${AppUtils.formatShort(_addBaseDate)} = ${AppUtils.formatFull(result.targetDate)}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DateSelectorTile(
          label: 'Start Date',
          selectedDate: _addBaseDate,
          onDateChanged: (d) => setState(() => _addBaseDate = d),
        ),
        const SizedBox(height: 12),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Add Business Days')),
            ButtonSegment(value: false, label: Text('Subtract Business Days')),
          ],
          selected: {_isAdd},
          onSelectionChanged: (val) => setState(() => _isAdd = val.first),
        ),
        const SizedBox(height: 12),
        NumberStepperField(
          label: 'Business Days',
          value: _daysToAdd,
          min: 1,
          max: 365,
          onChanged: (v) => setState(() => _daysToAdd = v),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [5, 10, 15, 20, 30].map((preset) {
            return ActionChip(
              label: Text('+$preset'),
              onPressed: () => setState(() => _daysToAdd = preset),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        _buildWeekendSelector(),
        const SizedBox(height: 16),
        ResultCard(
          title: 'TARGET DATE',
          primaryValue: AppUtils.formatFull(result.targetDate),
          subtitle:
              'Spanned ${result.calendarDaysSpanned} calendar days (${result.weekendDaysSkipped} weekend + ${result.holidaysSkipped} holidays)',
          copyPayload: summary,
          icon: Icons.event_available_outlined,
        ),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          icon: const Icon(Icons.save_outlined, size: 18),
          label: const Text('Save to History'),
          onPressed: () {
            widget.historyController?.addEntry(
              toolName: 'Business Days',
              category: 'Work & Planning',
              title:
                  '${_isAdd ? "+" : "-"}$_daysToAdd business days from ${AppUtils.formatShort(_addBaseDate)}',
              resultSummary: AppUtils.formatShort(result.targetDate),
            );
            AppUtils.copyToClipboard(
              context,
              summary,
              message: 'Saved to history and copied to clipboard',
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
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
