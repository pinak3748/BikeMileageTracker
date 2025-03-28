import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/database_helper.dart';
import '../models/fuel_entry.dart';

class FuelProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  List<FuelEntry> _fuelEntries = [];
  
  List<FuelEntry> get fuelEntries => [..._fuelEntries];
  
  // Get entries by bike
  List<FuelEntry> getEntriesByBikeId(String bikeId) {
    return _fuelEntries
        .where((entry) => entry.bikeId == bikeId)
        .toList();
  }
  
  // Get total fuel cost
  double getTotalFuelCost(String bikeId) {
    return _fuelEntries
        .where((entry) => entry.bikeId == bikeId)
        .map((entry) => entry.cost)
        .fold(0, (prev, cost) => prev + cost);
  }
  
  // Get total fuel volume
  double getTotalFuelVolume(String bikeId) {
    return _fuelEntries
        .where((entry) => entry.bikeId == bikeId)
        .map((entry) => entry.volume)
        .fold(0, (prev, amount) => prev + amount);
  }
  
  // Get average fuel economy (km/L)
  double getAverageFuelEconomy(String bikeId) {
    final entries = getEntriesByBikeId(bikeId);
    if (entries.length < 2) return 0;
    
    // Sort entries by odometer reading
    entries.sort((a, b) => a.odometer.compareTo(b.odometer));
    
    double totalDistance = 0;
    double totalFuel = 0;
    
    for (int i = 1; i < entries.length; i++) {
      final distance = entries[i].odometer - entries[i - 1].odometer;
      
      if (distance > 0 && entries[i - 1].isFillup) {
        totalDistance += distance;
        totalFuel += entries[i - 1].volume;
      }
    }
    
    if (totalFuel == 0) return 0;
    return totalDistance / totalFuel;
  }
  
  // Get last fuel price
  double getLastFuelPrice(String bikeId) {
    final entries = getEntriesByBikeId(bikeId);
    if (entries.isEmpty) return 0;
    
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries.first.pricePerLiter;
  }
  
  // Load fuel entries for a specific bike
  Future<void> loadFuelEntries(String bikeId) async {
    try {
      final entriesData = await _dbHelper.getFuelEntries(bikeId);
      
      _fuelEntries = entriesData
          .map((item) => FuelEntry.fromMap(item))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading fuel entries: $e');
      _fuelEntries = [];
      notifyListeners();
    }
  }
  
  // Add a new fuel entry
  Future<void> addFuelEntry(FuelEntry entry) async {
    try {
      final entryWithId = entry.copyWith(id: _uuid.v4());
      final entryMap = entryWithId.toMap();
      
      await _dbHelper.insertFuelEntry(entryMap);
      
      await loadFuelEntries(entry.bikeId);
    } catch (e) {
      debugPrint('Error adding fuel entry: $e');
      rethrow;
    }
  }
  
  // Update an existing fuel entry
  Future<void> updateFuelEntry(FuelEntry entry) async {
    try {
      if (entry.id == null) {
        throw Exception('Cannot update fuel entry without id');
      }
      
      final entryMap = entry.toMap();
      
      await _dbHelper.updateFuelEntry(entryMap);
      
      await loadFuelEntries(entry.bikeId);
    } catch (e) {
      debugPrint('Error updating fuel entry: $e');
      rethrow;
    }
  }
  
  // Delete a fuel entry
  Future<void> deleteFuelEntry(String entryId, String bikeId) async {
    try {
      await _dbHelper.deleteFuelEntry(entryId);
      
      await loadFuelEntries(bikeId);
    } catch (e) {
      debugPrint('Error deleting fuel entry: $e');
      rethrow;
    }
  }
  
  // Get fuel entries for a date range
  List<FuelEntry> getEntriesForDateRange(String bikeId, DateTime start, DateTime end) {
    return _fuelEntries
        .where((entry) => entry.bikeId == bikeId)
        .where((entry) => entry.date.isAfter(start.subtract(const Duration(days: 1))))
        .where((entry) => entry.date.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }
  
  // Get monthly fuel costs for charts
  Map<String, double> getMonthlyFuelCosts(String bikeId, int months) {
    final monthlyCosts = <String, double>{};
    final now = DateTime.now();
    
    // Initialize all months with zero amounts
    for (var i = 0; i < months; i++) {
      final month = now.month - i;
      final year = now.year - (month <= 0 ? 1 : 0);
      final adjustedMonth = month <= 0 ? month + 12 : month;
      
      final monthLabel = '${year}-${adjustedMonth.toString().padLeft(2, '0')}';
      monthlyCosts[monthLabel] = 0;
    }
    
    // Calculate actual costs for each month
    for (final entry in _fuelEntries.where((e) => e.bikeId == bikeId)) {
      final monthLabel = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
      
      if (monthlyCosts.containsKey(monthLabel)) {
        monthlyCosts[monthLabel] = (monthlyCosts[monthLabel] ?? 0) + entry.cost;
      }
    }
    
    return monthlyCosts;
  }
}