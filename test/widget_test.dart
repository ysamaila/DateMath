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
    expect(find.text('All (14)'), findsOneWidget);
    expect(find.text('Date Tools (4)'), findsOneWidget);
    expect(find.text('Time & Convert (4)'), findsOneWidget);
    expect(find.text('Work & Planning (3)'), findsOneWidget);
    expect(find.text('Astronomy (3)'), findsOneWidget);

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
    expect(find.text('Moon Phases'), findsOneWidget);
    expect(find.text('Equinox & Solstice'), findsOneWidget);
    expect(find.text('Julian & Milestones'), findsOneWidget);

    // Test Filter Chip: Astronomy (3)
    await tester.ensureVisible(find.text('Astronomy (3)'));
    await tester.tap(find.text('Astronomy (3)'));
    await tester.pumpAndSettle();
    expect(find.text('Date Difference'), findsNothing);
    expect(find.text('Time Math'), findsNothing);
    expect(find.text('Business Days'), findsNothing);
    expect(find.text('Moon Phases'), findsOneWidget);
    expect(find.text('Equinox & Solstice'), findsOneWidget);
    expect(find.text('Julian & Milestones'), findsOneWidget);

    // Test Navigation to Moon Phases screen
    await tester.tap(find.text('Moon Phases'));
    await tester.pumpAndSettle();
    expect(find.text('Observation Date'), findsOneWidget);
    expect(find.text('Upcoming Primary Phases'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test Navigation to Equinox & Solstice screen
    await tester.tap(find.text('Equinox & Solstice'));
    await tester.pumpAndSettle();
    expect(find.text('Observation Year'), findsOneWidget);
    expect(find.text('March Equinox'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test Navigation to Julian & Milestones screen
    await tester.tap(find.text('Julian & Milestones'));
    await tester.pumpAndSettle();
    expect(find.text('JULIAN DATE (JD)'), findsOneWidget);
    expect(find.text('MODIFIED JULIAN DATE (MJD)'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test Filter Chip: Work & Planning (3)
    await tester.ensureVisible(find.text('Work & Planning (3)'));
    await tester.tap(find.text('Work & Planning (3)'));
    await tester.pumpAndSettle();
    expect(find.text('Date Difference'), findsNothing);
    expect(find.text('Time Math'), findsNothing);
    expect(find.text('Moon Phases'), findsNothing);
    expect(find.text('Business Days'), findsOneWidget);
    expect(find.text('Milestone Countdown'), findsOneWidget);
    expect(find.text('Recurrence Planner'), findsOneWidget);

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
