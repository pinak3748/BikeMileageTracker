import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1E88E5);
  static const Color secondary = Color(0xFF03A9F4);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  static const Color background = Color(0xFFF5F5F5);
}

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