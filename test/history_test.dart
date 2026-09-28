import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:datemath/core/models/history_item.dart';
import 'package:datemath/core/services/history_service.dart';
import 'package:datemath/app/controllers/history_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HistoryService & HistoryController', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('addEntry adds item to front and persists it', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = HistoryService(prefs: prefs);
      final controller = HistoryController(service: service);

      await controller.init();
      expect(controller.items.isEmpty, isTrue);

      await controller.addEntry(
        toolName: 'Date Difference',
        category: 'Date Tools',
        title: 'Oct 1 to Oct 15',
        resultSummary: '14 days',
      );

      expect(controller.items.length, 1);
      expect(controller.items.first.toolName, 'Date Difference');
      expect(controller.items.first.title, 'Oct 1 to Oct 15');
      expect(controller.items.first.resultSummary, '14 days');
    });

    test('caps history items at max 100 entries', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = HistoryService(prefs: prefs);
      final controller = HistoryController(service: service);
      await controller.init();

      for (var i = 0; i < 105; i++) {
        await controller.addEntry(
          toolName: 'Tool $i',
          category: 'General',
          title: 'Title $i',
          resultSummary: 'Result $i',
        );
      }

      expect(controller.items.length, 100);
      expect(controller.items.first.title, 'Title 104');
    });

    test('toggleFavorite updates favorite state and filters favorites list', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = HistoryService(prefs: prefs);
      final controller = HistoryController(service: service);
      await controller.init();

      await controller.addEntry(
        toolName: 'Age Calculator',
        category: 'Date Tools',
        title: 'My Birthday',
        resultSummary: '25 years',
      );

      final id = controller.items.first.id;
      expect(controller.favorites.isEmpty, isTrue);

      await controller.toggleFavorite(id);
      expect(controller.favorites.length, 1);
      expect(controller.favorites.first.id, id);

      await controller.toggleFavorite(id);
      expect(controller.favorites.isEmpty, isTrue);
    });

    test('deleteEntry removes specific item', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = HistoryService(prefs: prefs);
      final controller = HistoryController(service: service);
      await controller.init();

      await controller.addEntry(
        toolName: 'Tool A',
        category: 'Category A',
        title: 'A',
        resultSummary: 'Res A',
      );
      await controller.addEntry(
        toolName: 'Tool B',
        category: 'Category B',
        title: 'B',
        resultSummary: 'Res B',
      );

      expect(controller.items.length, 2);
      final idToDelete = controller.items.first.id;
      await controller.deleteEntry(idToDelete);

      expect(controller.items.length, 1);
      expect(controller.items.any((i) => i.id == idToDelete), isFalse);
    });

    test('clearAll wipes history', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = HistoryService(prefs: prefs);
      final controller = HistoryController(service: service);
      await controller.init();

      await controller.addEntry(
        toolName: 'Tool',
        category: 'Cat',
        title: 'T',
        resultSummary: 'R',
      );
      expect(controller.items.isNotEmpty, isTrue);

      await controller.clearAll();
      expect(controller.items.isEmpty, isTrue);
    });

    test('exportAsText produces formatted summary', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = HistoryService(prefs: prefs);
      final controller = HistoryController(service: service);
      await controller.init();

      await controller.addEntry(
        toolName: 'Time Math',
        category: 'Time & Convert',
        title: '09:00 to 17:00',
        resultSummary: '8 hours',
      );

      final text = controller.exportAsText();
      expect(text.contains('DateMath Calculation History'), isTrue);
      expect(text.contains('Time Math'), isTrue);
      expect(text.contains('09:00 to 17:00'), isTrue);
      expect(text.contains('8 hours'), isTrue);
    });
  });
}
