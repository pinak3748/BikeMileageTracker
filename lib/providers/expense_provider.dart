import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class ExpenseProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Implemented methods to be expanded later
  Future<void> loadExpenses(String bikeId) async {
    // Will be implemented in detail later
  }

  Future<Map<String, dynamic>> getExpenseStatistics(String bikeId) async {
    // Temporary implementation
    return {
      'totalExpenses': 0.0,
      'categoryCounts': {},
    };
  }
}