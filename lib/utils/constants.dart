import 'package:flutter/material.dart';

class AppConstants {
  // Database constants
  static const String dbName = 'moto_tracker.db';
  static const int dbVersion = 1;
  static const String bikeTable = 'bikes';
  static const String fuelTable = 'fuel_entries';
  static const String maintenanceTable = 'maintenance';
  static const String reminderTable = 'reminders';
  static const String expenseTable = 'expenses';
  static const String documentTable = 'documents';

  // Navigation constants
  static const int dashboardIndex = 0;
  static const int fuelIndex = 1;
  static const int maintenanceIndex = 2;
  static const int expenseIndex = 3;
  static const int moreIndex = 4;

  // Fuel constants
  static const List<String> fuelTypes = [
    'Regular',
    'Premium',
    'Super',
    'Diesel',
    'E85',
    'Other',
  ];

  static const List<String> fillTypes = [
    'Full',
    'Partial',
    'Missed Previous',
  ];

  // Maintenance constants
  static const List<String> maintenanceTypes = [
    'Oil Change',
    'Chain Maintenance',
    'Tire Replacement',
    'Filter Change',
    'Brake Service',
    'Valve Adjustment',
    'Inspection',
    'Tune-up',
    'Electrical',
    'Fluids',
    'Repairs',
    'Customization',
    'Other',
  ];

  static const List<String> maintenanceStatus = [
    'Completed',
    'Scheduled',
    'In Progress',
    'Postponed',
  ];

  // Expense categories
  static const List<String> expenseCategories = [
    'Insurance',
    'Registration',
    'Gear',
    'Accessories',
    'Storage',
    'Tools',
    'Training',
    'Other',
  ];

  // Document types
  static const List<String> documentTypes = [
    'Insurance Policy',
    'Registration',
    'Purchase Receipt',
    'Service Records',
    'Warranty Information',
    'Manual',
    'Other',
  ];

  // Reminder types
  static const List<String> reminderTypes = [
    'Date Based',
    'Mileage Based',
    'Both',
  ];

  // Default values
  static const int defaultRecurrenceInterval = 30; // days
}

class AppColors {
  static Color primary = Colors.blue.shade700;
  static Color primaryLight = Colors.blue.shade500;
  static Color accent = Colors.amber.shade700;
  static Color success = Colors.green.shade600;
  static Color warning = Colors.orange.shade700;
  static Color danger = Colors.red.shade700;
  static Color text = Colors.grey.shade900;
  static Color textLight = Colors.grey.shade600;
  static Color background = Colors.grey.shade100;
  static Color cardBackground = Colors.white;
  static Color lightBackground = Colors.grey.shade50;
}