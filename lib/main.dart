import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/bike_provider.dart';
import 'providers/maintenance_provider.dart';
import 'providers/fuel_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/document_provider.dart';
import 'utils/constants.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use the current app colors (light theme by default)
    final colors = AppColors.current;
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BikeProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => FuelProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
      ],
      child: MaterialApp(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: colors.primary,
            primary: colors.primary,
            secondary: colors.secondary,
            background: colors.background,
            surface: colors.surface,
            error: colors.error,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: colors.primary,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.primary,
              side: BorderSide(color: colors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: colors.primary,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: colors.border),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              borderSide: BorderSide(color: colors.error),
            ),
            fillColor: colors.surface,
          ),
          cardTheme: CardTheme(
            color: colors.cardBackground,
            elevation: AppConstants.cardElevation,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
          ),
          dividerTheme: DividerThemeData(
            color: colors.divider,
            thickness: 1,
            space: 1,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: colors.accent,
            foregroundColor: Colors.white,
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(color: colors.textPrimary),
            bodyMedium: TextStyle(color: colors.textPrimary),
            bodySmall: TextStyle(color: colors.textSecondary),
            titleLarge: TextStyle(color: colors.textDark, fontWeight: FontWeight.bold),
            titleMedium: TextStyle(color: colors.textDark, fontWeight: FontWeight.bold),
            titleSmall: TextStyle(color: colors.textDark, fontWeight: FontWeight.bold),
          ),
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}