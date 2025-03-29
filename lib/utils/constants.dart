import 'package:flutter/material.dart';

/// AppTheme class contains all the color configurations for the app
class AppTheme {
  /// Creates a theme with all the necessary colors for the application
  /// If [isDark] is true, then dark mode colors are returned
  static AppColors getAppColors({bool isDark = false}) {
    return isDark ? _DarkAppColors() : _LightAppColors();
  }
}

/// Abstract class that defines all color properties needed in the app
abstract class AppColors {
  // Primary and accent colors
  Color get primary;
  Color get secondary;
  Color get accent;
  
  // State colors
  Color get success;
  Color get warning;
  Color get error;
  Color get danger;
  Color get info;
  
  // UI colors
  Color get background;
  Color get surface;
  Color get cardBackground;
  Color get divider;
  Color get border;
  
  // Text colors
  Color get textPrimary;
  Color get textSecondary;
  Color get textLight;
  Color get textDark;
  
  // Chart colors
  List<Color> get chartColors;
  
  // Static access to light theme colors (default)
  static final AppColors light = _LightAppColors();
  
  // Static access to dark theme colors
  static final AppColors dark = _DarkAppColors();
  
  // Static access to current theme colors (defaults to light)
  static AppColors get current => light;
}

/// Implementation of light theme colors
class _LightAppColors implements AppColors {
  @override
  Color get primary => const Color(0xFF1E88E5);
  
  @override
  Color get secondary => const Color(0xFF03A9F4);
  
  @override
  Color get accent => const Color(0xFF00ACC1);
  
  @override
  Color get success => const Color(0xFF4CAF50);
  
  @override
  Color get warning => const Color(0xFFFFC107);
  
  @override
  Color get error => const Color(0xFFF44336);
  
  @override
  Color get danger => const Color(0xFFF44336); // Same as error for consistency
  
  @override
  Color get info => const Color(0xFF2196F3);
  
  @override
  Color get background => const Color(0xFFF5F5F5);
  
  @override
  Color get surface => Colors.white;
  
  @override
  Color get cardBackground => Colors.white;
  
  @override
  Color get divider => const Color(0xFFE0E0E0);
  
  @override
  Color get border => const Color(0xFFE0E0E0);
  
  @override
  Color get textPrimary => const Color(0xFF212121);
  
  @override
  Color get textSecondary => const Color(0xFF757575);
  
  @override
  Color get textLight => const Color(0xFF9E9E9E);
  
  @override
  Color get textDark => const Color(0xFF212121);
  
  @override
  List<Color> get chartColors => [
    accent,
    primary,
    secondary,
    warning,
    error,
    success,
    Colors.purple,
    Colors.teal,
    Colors.orange,
    Colors.indigo,
    Colors.pink,
    Colors.amber,
  ];
}

/// Implementation of dark theme colors (for future dark mode support)
class _DarkAppColors implements AppColors {
  @override
  Color get primary => const Color(0xFF64B5F6);
  
  @override
  Color get secondary => const Color(0xFF4FC3F7);
  
  @override
  Color get accent => const Color(0xFF26C6DA);
  
  @override
  Color get success => const Color(0xFF81C784);
  
  @override
  Color get warning => const Color(0xFFFFD54F);
  
  @override
  Color get error => const Color(0xFFE57373);
  
  @override
  Color get danger => const Color(0xFFE57373); // Same as error for consistency
  
  @override
  Color get info => const Color(0xFF64B5F6);
  
  @override
  Color get background => const Color(0xFF121212);
  
  @override
  Color get surface => const Color(0xFF1E1E1E);
  
  @override
  Color get cardBackground => const Color(0xFF1E1E1E);
  
  @override
  Color get divider => const Color(0xFF424242);
  
  @override
  Color get border => const Color(0xFF424242);
  
  @override
  Color get textPrimary => const Color(0xFFECEFF1);
  
  @override
  Color get textSecondary => const Color(0xFFB0BEC5);
  
  @override
  Color get textLight => const Color(0xFF78909C);
  
  @override
  Color get textDark => Colors.white;
  
  @override
  List<Color> get chartColors => [
    accent,
    primary,
    secondary,
    warning,
    error,
    success,
    const Color(0xFFCE93D8), // light purple
    const Color(0xFF80CBC4), // light teal
    const Color(0xFFFFB74D), // light orange
    const Color(0xFF9FA8DA), // light indigo
    const Color(0xFFF48FB1), // light pink
    const Color(0xFFFFD54F), // light amber
  ];
}

/// For backward compatibility until all files are updated
class AppConfig {
  static const String appName = 'Moto Tracker';
  static const String version = '1.0.0';
  static const String dbName = 'moto_tracker.db';
}

class AppConstants {
  static const double borderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double cardElevation = 2.0;
  
  // Maintenance types
  static const List<String> maintenanceTypes = [
    'Oil Change',
    'Oil Filter',
    'Air Filter',
    'Chain',
    'Sprocket',
    'Tire',
    'Brake Pad',
    'Brake Fluid',
    'Coolant',
    'Valve Adjustment',
    'Battery',
    'Spark Plug',
    'Inspection',
    'Other'
  ];
  
  // Expense categories
  static const List<String> expenseCategories = [
    'Parts',
    'Accessories',
    'Gear',
    'Service',
    'Insurance',
    'Registration',
    'Parking',
    'Other'
  ];
  
  // Fuel types
  static const List<String> fuelTypes = [
    'Regular',
    'Premium',
    'Diesel',
    'E85',
    'Other'
  ];
}