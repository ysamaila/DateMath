import 'package:flutter/material.dart';
import '../../core/data/world_cities_data.dart';
import '../../core/services/time_calculation_service.dart';
import '../../shared/widgets/result_card.dart';
import '../../shared/widgets/time_selector_tile.dart';

class WorldTimeOffsetsScreen extends StatefulWidget {
  const WorldTimeOffsetsScreen({super.key});

  @override
  State<WorldTimeOffsetsScreen> createState() => _WorldTimeOffsetsScreenState();
}

class _WorldTimeOffsetsScreenState extends State<WorldTimeOffsetsScreen> {
  late ClockTime _baseTime;
  late int _baseOffsetMinutes;
  String _baseLocationName = 'Local Device Time';

  late int _targetOffsetMinutes;
  String _targetLocationName = 'Tokyo (JST)';
  WorldCity? _targetCity;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _baseTime = ClockTime.fromDateTime(now);
    _baseOffsetMinutes = now.timeZoneOffset.inMinutes;

    // Default target: Tokyo or London
    final defaultCity = WorldCitiesData.allCities.firstWhere(
      (c) => c.name == 'Tokyo',
      orElse: () => WorldCitiesData.allCities.first,
    );
    _targetCity = defaultCity;
    _targetOffsetMinutes = defaultCity.utcOffsetMinutes;
    _targetLocationName = '${defaultCity.name} (${defaultCity.abbreviation})';
  }

  void _reset() {
    final now = DateTime.now();
    setState(() {
      _baseTime = ClockTime.fromDateTime(now);
      _baseOffsetMinutes = now.timeZoneOffset.inMinutes;
      _baseLocationName = 'Local Device Time';

      final defaultCity = WorldCitiesData.allCities.firstWhere(
        (c) => c.name == 'Tokyo',
        orElse: () => WorldCitiesData.allCities.first,
      );
      _targetCity = defaultCity;
      _targetOffsetMinutes = defaultCity.utcOffsetMinutes;
      _targetLocationName = '${defaultCity.name} (${defaultCity.abbreviation})';
    });
  }

  String _formatOffset(int offsetMin) {
    final sign = offsetMin >= 0 ? '+' : '-';
    final absMin = offsetMin.abs();
    final h = (absMin ~/ 60).toString().padLeft(2, '0');
    final m = (absMin % 60).toString().padLeft(2, '0');
    return 'UTC$sign$h:$m';
  }

  void _openCitySearchModal(bool isTarget) {
    showModalBottomSheet<WorldCity>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _CitySearchSheet(
        title: isTarget ? 'Select Target City' : 'Select Base City',
      ),
    ).then((selected) {
      if (selected != null) {
        setState(() {
          if (isTarget) {
            _targetCity = selected;
            _targetOffsetMinutes = selected.utcOffsetMinutes;
            _targetLocationName = '${selected.name} (${selected.abbreviation})';
          } else {
            _baseOffsetMinutes = selected.utcOffsetMinutes;
            _baseLocationName = '${selected.name} (${selected.abbreviation})';
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final comparison = TimeCalculationService.calculateOffsetDifference(
      baseTime: _baseTime,
      baseOffsetMinutes: _baseOffsetMinutes,
      targetOffsetMinutes: _targetOffsetMinutes,
    );

    final summary =
        '$_baseLocationName (${_formatOffset(_baseOffsetMinutes)}) at ${_baseTime.formatted12()} → $_targetLocationName (${_formatOffset(_targetOffsetMinutes)}) is ${comparison.targetTime.formatted12()} (${comparison.offsetDeltaLabel}, ${comparison.relativeDay})';

    return Scaffold(
      appBar: AppBar(
        title: const Text('World Time Offsets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to Defaults',
            onPressed: _reset,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Base Location Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.home_outlined, size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            'BASE LOCATION',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.location_city, size: 16),
                        label: const Text('Change City'),
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        onPressed: () => _openCitySearchModal(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _baseLocationName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Offset: ${_formatOffset(_baseOffsetMinutes)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  TimeSelectorTile(
                    label: 'Base Clock Time',
                    selectedTime: _baseTime,
                    onTimeChanged: (val) => setState(() => _baseTime = val),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Target Location Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.flight_takeoff_rounded, size: 18, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            'TARGET LOCATION',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      FilledButton.tonalIcon(
                        icon: const Icon(Icons.search, size: 16),
                        label: const Text('Select City'),
                        style: FilledButton.styleFrom(visualDensity: VisualDensity.compact),
                        onPressed: () => _openCitySearchModal(true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _targetLocationName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _targetCity != null
                        ? '${_targetCity!.country} • Offset: ${_formatOffset(_targetOffsetMinutes)}'
                        : 'Offset: ${_formatOffset(_targetOffsetMinutes)}',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),

                  // Direct UTC offset slider
                  Text(
                    'Manual UTC Offset Adjustment:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _formatOffset(_targetOffsetMinutes),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _targetOffsetMinutes.toDouble(),
                          min: -720, // -12:00
                          max: 840,  // +14:00
                          divisions: (840 - (-720)) ~/ 15, // 15-minute steps
                          label: _formatOffset(_targetOffsetMinutes),
                          onChanged: (val) {
                            setState(() {
                              _targetOffsetMinutes = val.round();
                              _targetLocationName = 'Custom Offset (${_formatOffset(_targetOffsetMinutes)})';
                              _targetCity = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Comparison Result Card
          ResultCard(
            title: 'TARGET CLOCK TIME',
            primaryValue: comparison.targetTime.formatted12(),
            subtitle: '24h Format: ${comparison.targetTime.formatted24()}',
            copyPayload: summary,
            icon: Icons.public_rounded,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        comparison.offsetDeltaLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: comparison.relativeDay == 'Same day'
                            ? theme.colorScheme.surfaceContainerHighest
                            : theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        comparison.relativeDay,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: comparison.relativeDay == 'Same day'
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Interactive time scrubbing slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Interactive Base Hour Scrubbing:',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    Text(
                      '${_baseTime.hour.toString().padLeft(2, '0')}:00',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider(
                  value: _baseTime.hour.toDouble(),
                  min: 0,
                  max: 23,
                  divisions: 23,
                  label: '${_baseTime.hour}:00',
                  onChanged: (val) {
                    setState(() {
                      _baseTime = ClockTime(
                        hour: val.round(),
                        minute: _baseTime.minute,
                        second: _baseTime.second,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CitySearchSheet extends StatefulWidget {
  final String title;

  const _CitySearchSheet({required this.title});

  @override
  State<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<_CitySearchSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedContinent = 'All';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allContinents = ['All', ...WorldCitiesData.continents];

    var filtered = WorldCitiesData.searchCities(_query);
    if (_selectedContinent != 'All') {
      filtered = filtered.where((c) => c.continent == _selectedContinent).toList();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Column(
          children: [
            // Handle bar
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search city, country, or timezone...',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => _query = val),
              ),
            ),
            const SizedBox(height: 8),

            // Continent filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: allContinents.map((continent) {
                  final isSelected = _selectedContinent == continent;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: FilterChip(
                      label: Text(continent),
                      selected: isSelected,
                      visualDensity: VisualDensity.compact,
                      onSelected: (selected) {
                        setState(() {
                          _selectedContinent = continent;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(),

            // Cities List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No matching cities found',
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      controller: scrollController,
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (ctx, idx) {
                        final city = filtered[idx];
                        return ListTile(
                          title: Text(
                            city.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${city.country} • ${city.continent}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${city.abbreviation} (${city.formattedOffset})',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          onTap: () => Navigator.of(context).pop(city),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
