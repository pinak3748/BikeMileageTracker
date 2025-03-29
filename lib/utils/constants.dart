import 'package:flutter/material.dart';

class AppConstants {
  // Maintenance categories
  static const List<String> maintenanceCategories = [
    'Oil Change',
    'Chain Maintenance',
    'Tire Replacement',
    'Brake Service',
    'Air Filter',
    'Spark Plugs',
    'Engine Tune-up',
    'Valve Adjustment',
    'Battery Replacement',
    'Other',
  ];

  // Expense categories
  static const List<String> expenseCategories = [
    'Fuel',
    'Maintenance',
    'Insurance',
    'Registration',
    'Gear & Accessories',
    'Modifications',
    'Other',
  ];

  // Document types
  static const List<String> documentTypes = [
    'Insurance Policy',
    'Registration',
    'Owner\'s Manual',
    'Service Manual',
    'Purchase Receipt',
    'Warranty Information',
    'Other',
  ];

  // Units
  static const String distanceUnit = 'km';
  static const String volumeUnit = 'L';
  static const String currencySymbol = '₹';
}

class AppColors {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color onPrimary;
  final Color secondary;
  final Color secondaryLight;
  final Color secondaryDark;
  final Color onSecondary;
  final Color background;
  final Color surface;
  final Color error;
  final Color onError;
  final Color success;
  final Color warning;
  final Color info;
  final Color accent;
  final Color text;
  final Color textSecondary;
  final Color textLight;
  final Color border;
  final Color divider;

  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.onPrimary,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.onSecondary,
    required this.background,
    required this.surface,
    required this.error,
    required this.onError,
    required this.success,
    required this.warning,
    required this.info,
    required this.accent,
    required this.text,
    required this.textSecondary,
    required this.textLight,
    required this.border,
    required this.divider,
  });

  // Light theme colors
  static final light = AppColors(
    primary: const Color(0xFF0D47A1),
    primaryLight: const Color(0xFF5472D3),
    primaryDark: const Color(0xFF002171),
    onPrimary: Colors.white,
    secondary: const Color(0xFF00897B),
    secondaryLight: const Color(0xFF4EBAAA),
    secondaryDark: const Color(0xFF005B4F),
    onSecondary: Colors.white,
    background: Colors.grey.shade100,
    surface: Colors.white,
    error: const Color(0xFFB71C1C),
    onError: Colors.white,
    success: const Color(0xFF2E7D32),
    warning: const Color(0xFFF57F17),
    info: const Color(0xFF0288D1),
    accent: const Color(0xFFFF6F00),
    text: Colors.black87,
    textSecondary: Colors.black54,
    textLight: Colors.black38,
    border: Colors.grey.shade300,
    divider: Colors.grey.shade200,
  );

  // Dark theme colors
  static final dark = AppColors(
    primary: const Color(0xFF5472D3),
    primaryLight: const Color(0xFF8A9FE5),
    primaryDark: const Color(0xFF0D47A1),
    onPrimary: Colors.black,
    secondary: const Color(0xFF4EBAAA),
    secondaryLight: const Color(0xFF82ECCB),
    secondaryDark: const Color(0xFF00897B),
    onSecondary: Colors.black,
    background: const Color(0xFF121212),
    surface: const Color(0xFF1E1E1E),
    error: const Color(0xFFCF6679),
    onError: Colors.black,
    success: const Color(0xFF81C784),
    warning: const Color(0xFFFFD54F),
    info: const Color(0xFF64B5F6),
    accent: const Color(0xFFFFB74D),
    text: Colors.white,
    textSecondary: Colors.white70,
    textLight: Colors.white54,
    border: Colors.grey.shade800,
    divider: Colors.grey.shade900,
  );

  // Get current theme colors based on system brightness
  static AppColors get current {
    if (WidgetsBinding.instance.window.platformBrightness == Brightness.dark) {
      return dark;
    }
    return light;
  }
}

class DateFormatter {
  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  static String formatDistance(double distance) {
    return '${formatNumber(distance)} ${AppConstants.distanceUnit}';
  }

  static String formatVolume(double volume) {
    return '${formatNumber(volume)} ${AppConstants.volumeUnit}';
  }

  static String formatCurrency(double amount) {
    return '${AppConstants.currencySymbol}${formatNumber(amount)}';
  }

  static String formatNumber(double number) {
    if (number == number.toInt()) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(2);
  }
}