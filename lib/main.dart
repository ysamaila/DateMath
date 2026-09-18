import 'package:flutter/material.dart';
import 'app/controllers/theme_controller.dart';
import 'app/theme/app_theme.dart';
import 'features/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final themeController = ThemeController();
  runApp(DateMathApp(themeController: themeController));
}

class DateMathApp extends StatelessWidget {
  final ThemeController themeController;

  const DateMathApp({
    super.key,
    required this.themeController,
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
          home: HomeScreen(themeController: themeController),
        );
      },
    );
  }
}
