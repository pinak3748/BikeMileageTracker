import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class FuelProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Implemented methods to be expanded later
  Future<void> loadFuelEntries(String bikeId) async {
    // Will be implemented in detail later
  }

  Future<List<dynamic>> getFuelEntriesForBikeWithLimit(String bikeId, int limit) async {
    // Temporary implementation
    return [];
  }

  Future<Map<String, dynamic>> getFuelStatistics(String bikeId) async {
    // Temporary implementation
    return {
      'avgEfficiency': 0.0,
      'totalCost': 0.0,
    };
  }
}