import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/controllers/history_controller.dart';
import 'app/controllers/theme_controller.dart';
import 'app/theme/app_theme.dart';
import 'core/services/history_service.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  final prefs = await SharedPreferences.getInstance();
  final historyService = HistoryService(prefs: prefs);
  final historyController = HistoryController(service: historyService);
  await historyController.init();

  runApp(DateMathApp(
    themeController: themeController,
    historyController: historyController,
  ));
}

class DateMathApp extends StatelessWidget {
  final ThemeController themeController;
  final HistoryController historyController;

  const DateMathApp({
    super.key,
    required this.themeController,
    required this.historyController,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return MaterialApp(
          title: 'DateMath',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeController.themeMode,
          home: HomeScreen(
            themeController: themeController,
            historyController: historyController,
          ),
        );
      },
    );
  }
}
