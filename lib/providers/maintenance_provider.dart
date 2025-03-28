import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/database_helper.dart';
import '../models/maintenance_record.dart';

class MaintenanceProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  List<MaintenanceRecord> _maintenanceRecords = [];
  
  List<MaintenanceRecord> get maintenanceRecords => [..._maintenanceRecords];
  
  // Filtered records
  List<MaintenanceRecord> getRecordsByBikeId(String bikeId) {
    return _maintenanceRecords
        .where((record) => record.bikeId == bikeId)
        .toList();
  }
  
  // Get recent maintenance count for dashboard
  int getRecentMaintenanceCount(String bikeId) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    return _maintenanceRecords
        .where((record) => record.bikeId == bikeId)
        .where((record) => record.date.isAfter(thirtyDaysAgo))
        .length;
  }
  
  // Get upcoming maintenance count for dashboard
  int getUpcomingMaintenanceCount(String bikeId) {
    final now = DateTime.now();
    
    return _maintenanceRecords
        .where((record) => record.bikeId == bikeId)
        .where((record) => record.nextDueDate != null && record.nextDueDate!.isAfter(now))
        .length;
  }
  
  // Get total maintenance cost
  double getTotalMaintenanceCost(String bikeId) {
    double total = 0.0;
    for (var record in _maintenanceRecords.where((r) => r.bikeId == bikeId)) {
      if (record.cost != null) {
        total += record.cost!;
      }
    }
    return total;
  }
  
  // Load maintenance records for a specific bike
  Future<void> loadMaintenanceRecords(String bikeId) async {
    try {
      final recordsData = await _dbHelper.getMaintenanceRecords(bikeId);
      
      _maintenanceRecords = recordsData
          .map((item) => MaintenanceRecord.fromMap(item))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading maintenance records: $e');
      _maintenanceRecords = [];
      notifyListeners();
    }
  }
  
  // Add a new maintenance record
  Future<void> addMaintenanceRecord(MaintenanceRecord record) async {
    try {
      final recordWithId = record.copyWith(id: _uuid.v4());
      final recordMap = recordWithId.toMap();
      
      await _dbHelper.insertMaintenanceRecord(recordMap);
      
      await loadMaintenanceRecords(record.bikeId);
    } catch (e) {
      debugPrint('Error adding maintenance record: $e');
      rethrow;
    }
  }
  
  // Update an existing maintenance record
  Future<void> updateMaintenanceRecord(MaintenanceRecord record) async {
    try {
      if (record.id == null) {
        throw Exception('Cannot update maintenance record without id');
      }
      
      final recordMap = record.toMap();
      
      await _dbHelper.updateMaintenanceRecord(recordMap);
      
      await loadMaintenanceRecords(record.bikeId);
    } catch (e) {
      debugPrint('Error updating maintenance record: $e');
      rethrow;
    }
  }
  
  // Delete a maintenance record
  Future<void> deleteMaintenanceRecord(String recordId, String bikeId) async {
    try {
      await _dbHelper.deleteMaintenanceRecord(recordId);
      
      await loadMaintenanceRecords(bikeId);
    } catch (e) {
      debugPrint('Error deleting maintenance record: $e');
      rethrow;
    }
  }
  
  // Get maintenance by type
  List<MaintenanceRecord> getMaintenanceByType(String bikeId, String type) {
    return _maintenanceRecords
        .where((record) => record.bikeId == bikeId)
        .where((record) => record.type == type)
        .toList();
  }
  
  // Get completed maintenance (records that have already happened)
  List<MaintenanceRecord> getCompletedMaintenance(String bikeId) {
    final now = DateTime.now();
    return _maintenanceRecords
        .where((record) => record.bikeId == bikeId)
        .where((record) => record.date.isBefore(now) || record.date.isAtSameMomentAs(now))
        .toList();
  }
  
  // Get scheduled maintenance (records with future dates)
  List<MaintenanceRecord> getScheduledMaintenance(String bikeId) {
    final now = DateTime.now();
    return _maintenanceRecords
        .where((record) => record.bikeId == bikeId)
        .where((record) => record.date.isAfter(now) || 
                           (record.nextDueDate != null && record.nextDueDate!.isAfter(now)))
        .toList();
  }
}