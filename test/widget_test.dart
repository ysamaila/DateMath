import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:datemath/app/controllers/theme_controller.dart';
import 'package:datemath/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DateMathApp loads dashboard, verifies filter chips, and navigates all tools', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final themeController = ThemeController();

    await tester.pumpWidget(DateMathApp(themeController: themeController));
    await tester.pumpAndSettle();

    // Verify DateMath branding and Today banner
    expect(find.text('DateMath'), findsWidgets);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('Tools'), findsOneWidget);

    // Verify filter chips
    expect(find.text('All (8)'), findsOneWidget);
    expect(find.text('Date Tools (4)'), findsOneWidget);
    expect(find.text('Time & Convert (4)'), findsOneWidget);

    // Verify all 8 tool list items on dashboard in "All" mode
    expect(find.text('Date Difference'), findsWidgets);
    expect(find.text('Add / Subtract Date'), findsWidgets);
    expect(find.text('Age Calculator'), findsWidgets);
    expect(find.text('Day Finder'), findsWidgets);
    expect(find.text('Time Math'), findsOneWidget);
    expect(find.text('Duration Converter'), findsOneWidget);
    expect(find.text('12h / 24h Military Time'), findsOneWidget);
    expect(find.text('World Time Offsets'), findsOneWidget);

    // Test Filter Chip: Date Tools (4)
    await tester.tap(find.text('Date Tools (4)'));
    await tester.pumpAndSettle();
    expect(find.text('Date Difference'), findsWidgets);
    expect(find.text('Time Math'), findsNothing);

    // Test Filter Chip: Time & Convert (4)
    await tester.tap(find.text('Time & Convert (4)'));
    await tester.pumpAndSettle();
    expect(find.text('Date Difference'), findsNothing);
    expect(find.text('Time Math'), findsOneWidget);
    expect(find.text('Duration Converter'), findsOneWidget);

    // Test Navigation to Time Math screen
    await tester.tap(find.text('Time Math'));
    await tester.pumpAndSettle();
    expect(find.text('Start Time'), findsOneWidget);
    expect(find.text('End Time'), findsOneWidget);
    expect(find.text('DURATION DIFFERENCE'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test Navigation to Duration Converter screen
    await tester.tap(find.text('Duration Converter'));
    await tester.pumpAndSettle();
    expect(find.text('COMPOSITE BREAKDOWN'), findsOneWidget);
    expect(find.text('All Unit Conversions'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test Navigation to 12h / 24h Military Time screen
    await tester.tap(find.text('12h / 24h Military Time'));
    await tester.pumpAndSettle();
    expect(find.text('MILITARY DESIGNATION'), findsOneWidget);
    expect(find.text('Military Time Reference'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test Navigation to World Time Offsets screen
    await tester.tap(find.text('World Time Offsets'));
    await tester.pumpAndSettle();
    expect(find.text('BASE LOCATION'), findsOneWidget);
    expect(find.text('TARGET LOCATION'), findsOneWidget);
    expect(find.text('TARGET CLOCK TIME'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Test Bottom Navigation Bar: Date Difference tab
    await tester.tap(find.byIcon(Icons.compare_arrows_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text('Start Date'), findsOneWidget);
    expect(find.text('End Date'), findsOneWidget);
    expect(find.text('TOTAL DAYS'), findsOneWidget);
  });
}
