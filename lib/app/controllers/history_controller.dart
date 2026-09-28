import 'package:flutter/foundation.dart';
import '../../core/models/history_item.dart';
import '../../core/services/history_service.dart';

class HistoryController extends ChangeNotifier {
  final HistoryService service;

  List<HistoryItem> _items = [];
  bool _isInitialized = false;

  HistoryController({required this.service});

  List<HistoryItem> get items => List.unmodifiable(_items);

  List<HistoryItem> get favorites =>
      _items.where((item) => item.isFavorite).toList();

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _items = await service.loadHistory();
    _isInitialized = true;
    notifyListeners();
  }

  static int _idCounter = 0;

  Future<void> addEntry({
    required String toolName,
    required String category,
    required String title,
    required String resultSummary,
  }) async {
    final newItem = HistoryItem(
      id: 'calc_${DateTime.now().microsecondsSinceEpoch}_${++_idCounter}',
      toolName: toolName,
      category: category,
      title: title,
      resultSummary: resultSummary,
      timestamp: DateTime.now(),
      isFavorite: false,
    );

    // Add to front of list and clamp to maxEntries
    _items.insert(0, newItem);
    if (_items.length > HistoryService.maxEntries) {
      _items = _items.sublist(0, HistoryService.maxEntries);
    }

    notifyListeners();
    await service.saveHistory(_items);
  }

  Future<void> toggleFavorite(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return;

    final current = _items[index];
    _items[index] = current.copyWith(isFavorite: !current.isFavorite);

    notifyListeners();
    await service.saveHistory(_items);
  }

  Future<void> deleteEntry(String id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    await service.saveHistory(_items);
  }

  Future<void> clearAll() async {
    _items.clear();
    notifyListeners();
    await service.saveHistory(_items);
  }

  String exportAsText() {
    if (_items.isEmpty) {
      return 'DateMath Calculation History is empty.';
    }

    final buffer = StringBuffer();
    buffer.writeln('=== DateMath Calculation History ===');
    buffer.writeln('Exported: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Total Calculations: ${_items.length}\n');

    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      buffer.writeln('${i + 1}. [${item.toolName}] ${item.title}');
      buffer.writeln('   Result: ${item.resultSummary}');
      buffer.writeln('   Time: ${item.timestamp}');
      if (item.isFavorite) {
        buffer.writeln('   ★ Starred Favorite');
      }
      buffer.writeln();
    }

    return buffer.toString();
  }
}
