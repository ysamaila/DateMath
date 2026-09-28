import 'package:flutter/material.dart';
import '../../app/controllers/history_controller.dart';
import '../../core/models/history_item.dart';
import '../../core/utils/app_utils.dart';

class HistoryPresetsScreen extends StatefulWidget {
  final HistoryController historyController;

  const HistoryPresetsScreen({super.key, required this.historyController});

  @override
  State<HistoryPresetsScreen> createState() => _HistoryPresetsScreenState();
}

class _HistoryPresetsScreenState extends State<HistoryPresetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Date Tools',
    'Time & Convert',
    'Work & Planning',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showClearConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Calculation History?'),
        content: const Text(
          'This will remove all recorded calculations from local storage. Favorited items will also be removed. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              widget.historyController.clearAll();
              Navigator.pop(ctx);
              AppUtils.copyToClipboard(
                context,
                '',
                message: 'All calculation history cleared',
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return AppUtils.formatShort(dt);
  }

  IconData _getToolIcon(String toolName) {
    switch (toolName) {
      case 'Date Difference':
        return Icons.compare_arrows_outlined;
      case 'Add / Subtract Date':
        return Icons.calendar_month_outlined;
      case 'Age Calculator':
        return Icons.cake_outlined;
      case 'Day Finder':
        return Icons.today_outlined;
      case 'Time Math':
        return Icons.access_time_outlined;
      case 'Duration Converter':
        return Icons.hourglass_empty_outlined;
      case '12h / 24h Military Time':
        return Icons.military_tech_outlined;
      case 'World Time Offsets':
        return Icons.public_outlined;
      case 'Business Days':
        return Icons.business_center_outlined;
      case 'Milestone Countdown':
        return Icons.flag_outlined;
      case 'Recurrence Planner':
        return Icons.event_repeat_rounded;
      default:
        return Icons.calculate_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.historyController,
      builder: (context, _) {
        final allItems = widget.historyController.items;
        final favorites = widget.historyController.favorites;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Calculation History'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Export as Text',
                onPressed: () {
                  final text = widget.historyController.exportAsText();
                  AppUtils.copyToClipboard(
                    context,
                    text,
                    message: 'Full calculation history copied to clipboard',
                  );
                },
              ),
              if (allItems.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: 'Clear History',
                  onPressed: _showClearConfirmDialog,
                ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('All History'),
                      if (allItems.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${allItems.length}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded, size: 16),
                      const SizedBox(width: 4),
                      const Text('Favorites'),
                      if (favorites.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${favorites.length}',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Category filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildHistoryList(allItems),
                    _buildHistoryList(favorites),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryList(List<HistoryItem> sourceItems) {
    final filtered = _selectedCategory == 'All'
        ? sourceItems
        : sourceItems.where((i) => i.category == _selectedCategory).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_toggle_off_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                sourceItems.isEmpty
                    ? 'No calculations recorded yet'
                    : 'No items in this category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Calculations performed in any tool are automatically logged here offline.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final toolIcon = _getToolIcon(item.toolName);
        final relativeTime = _formatRelativeTime(item.timestamp);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      toolIcon,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.toolName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      relativeTime,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.resultSummary,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        item.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: item.isFavorite ? Colors.amber : null,
                        size: 20,
                      ),
                      tooltip: item.isFavorite
                          ? 'Remove from Favorites'
                          : 'Star as Favorite',
                      onPressed: () =>
                          widget.historyController.toggleFavorite(item.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_outlined, size: 18),
                      tooltip: 'Copy Calculation',
                      onPressed: () {
                        final payload =
                            '[${item.toolName}] ${item.title}: ${item.resultSummary}';
                        AppUtils.copyToClipboard(
                          context,
                          payload,
                          message: 'Calculation copied to clipboard',
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 18, color: Colors.red),
                      tooltip: 'Delete',
                      onPressed: () =>
                          widget.historyController.deleteEntry(item.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
