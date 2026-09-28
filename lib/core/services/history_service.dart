import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  static const String _historyKey = 'datemath_calculation_history';
  static const int maxEntries = 100;

  final SharedPreferences prefs;

  HistoryService({required this.prefs});

  Future<List<HistoryItem>> loadHistory() async {
    final list = prefs.getStringList(_historyKey);
    if (list == null || list.isEmpty) {
      return [];
    }

    final items = <HistoryItem>[];
    for (final raw in list) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        items.add(HistoryItem.fromJson(map));
      } catch (_) {
        // Skip malformed entries
      }
    }
    return items;
  }

  Future<void> saveHistory(List<HistoryItem> items) async {
    final capped = items.take(maxEntries).toList();
    final serialized = capped.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_historyKey, serialized);
  }
}
