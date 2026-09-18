import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:datemath/app/controllers/theme_controller.dart';
import 'package:datemath/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DateMathApp loads dashboard and navigates through tools', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final themeController = ThemeController();

    await tester.pumpWidget(DateMathApp(themeController: themeController));
    await tester.pumpAndSettle();

    // Verify DateMath branding and offline badge
    expect(find.text('DateMath'), findsWidgets);
    expect(find.textContaining('100% Offline'), findsOneWidget);
    expect(find.text('TODAY OVERVIEW'), findsOneWidget);
    expect(find.text('Calculation Tools'), findsOneWidget);

    // Verify tool cards on dashboard
    expect(find.text('Date Difference'), findsWidgets);
    expect(find.text('Add / Subtract Date'), findsWidgets);
    expect(find.text('Age Calculator'), findsWidgets);
    expect(find.text('Day Finder'), findsWidgets);

    // Tap on Date Difference bottom nav item
    await tester.tap(find.byIcon(Icons.timelapse_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Start Date'), findsOneWidget);
    expect(find.text('End Date'), findsOneWidget);
    expect(find.text('TOTAL DAYS'), findsOneWidget);
    expect(find.text('WEEKS & REMAINING DAYS'), findsOneWidget);

    // Tap on Add/Subtract tab
    await tester.tap(find.byIcon(Icons.more_time_rounded).last);
    await tester.pumpAndSettle();

    expect(find.text('Add Time (+)'), findsOneWidget);
    expect(find.text('Subtract Time (-)'), findsOneWidget);
    expect(find.text('RESULTING DATE (ADDED)'), findsOneWidget);

    // Tap on Age tab
    await tester.tap(find.byIcon(Icons.cake_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('CHRONOLOGICAL AGE'), findsOneWidget);
    expect(find.text('LIFETIME DURATION'), findsOneWidget);
    expect(find.text('NEXT BIRTHDAY'), findsOneWidget);

    // Tap on Day Finder tab
    await tester.tap(find.byIcon(Icons.calendar_today_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Select Date to Analyze'), findsOneWidget);
    expect(find.text('DAY OF THE WEEK'), findsOneWidget);
    expect(find.text('DAY OF THE YEAR'), findsOneWidget);
  });
}
