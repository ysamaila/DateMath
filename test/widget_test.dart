import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:datemath/app/controllers/history_controller.dart';
import 'package:datemath/app/controllers/theme_controller.dart';
import 'package:datemath/core/services/history_service.dart';
import 'package:datemath/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DateMathApp loads dashboard, verifies filter chips, and navigates all tools', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final prefs = await SharedPreferences.getInstance();
    final themeController = ThemeController();
    final historyService = HistoryService(prefs: prefs);
    final historyController = HistoryController(service: historyService);
    await historyController.init();

    await tester.pumpWidget(DateMathApp(
      themeController: themeController,
      historyController: historyController,
    ));
    await tester.pumpAndSettle();

    // Verify DateMath branding and Today banner
    expect(find.text('DateMath'), findsWidgets);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);

    // Verify filter chips
    expect(find.text('All (11)'), findsOneWidget);
    expect(find.text('Date Tools (4)'), findsOneWidget);
    expect(find.text('Time & Convert (4)'), findsOneWidget);
    expect(find.text('Work & Planning (3)'), findsOneWidget);

    // Verify tool list items on dashboard in "All" mode
    expect(find.text('Date Difference'), findsWidgets);
    expect(find.text('Add / Subtract Date'), findsWidgets);
    expect(find.text('Age Calculator'), findsWidgets);
    expect(find.text('Day Finder'), findsWidgets);
    expect(find.text('Time Math'), findsOneWidget);
    expect(find.text('Duration Converter'), findsOneWidget);
    expect(find.text('12h / 24h Military Time'), findsOneWidget);
    expect(find.text('World Time Offsets'), findsOneWidget);
    expect(find.text('Business Days'), findsOneWidget);
    expect(find.text('Milestone Countdown'), findsOneWidget);
    expect(find.text('Recurrence Planner'), findsOneWidget);

    // Test Filter Chip: Work & Planning (3)
    await tester.tap(find.text('Work & Planning (3)'));
    await tester.pumpAndSettle();
    expect(find.text('Date Difference'), findsNothing);
    expect(find.text('Time Math'), findsNothing);
    expect(find.text('Business Days'), findsOneWidget);
    expect(find.text('Milestone Countdown'), findsOneWidget);
    expect(find.text('Recurrence Planner'), findsOneWidget);

    // Test Navigation to Business Days screen
    await tester.tap(find.text('Business Days'));
    await tester.pumpAndSettle();
    expect(find.text('Between Dates'), findsOneWidget);
    expect(find.text('Add / Subtract'), findsOneWidget);
    expect(find.text('WORKING DAYS'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test Navigation to Milestone Countdown screen
    await tester.tap(find.text('Milestone Countdown'));
    await tester.pumpAndSettle();
    expect(find.text('Milestone Name'), findsOneWidget);
    expect(find.text('Quick Target Presets'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test Navigation to Recurrence Planner screen
    await tester.tap(find.text('Recurrence Planner'));
    await tester.pumpAndSettle();
    expect(find.text('Schedule Start Date'), findsOneWidget);
    expect(find.text('Recurrence Frequency'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test History AppBar Action
    await tester.tap(find.byIcon(Icons.history_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Calculation History'), findsOneWidget);
    expect(find.text('All History'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
  });
}
