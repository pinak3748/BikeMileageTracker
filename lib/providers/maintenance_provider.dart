import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/database_helper.dart';
import '../utils/constants.dart';
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
        .where((record) => record.status == 'Completed')
        .length;
  }
  
  // Get upcoming maintenance count for dashboard
  int getUpcomingMaintenanceCount(String bikeId) {
    final now = DateTime.now();
    
    return _maintenanceRecords
        .where((record) => record.bikeId == bikeId)
        .where((record) => record.date.isAfter(now))
        .where((record) => record.status != 'Completed')
        .length;
  }
  
  // Get total maintenance cost
  double getTotalMaintenanceCost(String bikeId) {
    return _maintenanceRecords
        .where((record) => record.bikeId == bikeId)
        .map((record) => record.cost)
        .fold(0, (prev, cost) => prev + cost);
  }
  
  // Load maintenance records for a specific bike
  Future<void> loadMaintenanceRecords(String bikeId) async {
    try {
      final recordsData = await _dbHelper.query(
        AppConstants.maintenanceTable,
        where: 'bike_id = ?',
        whereArgs: [bikeId],
        orderBy: 'date DESC',
      );
      
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
      
      await _dbHelper.insert(AppConstants.maintenanceTable, recordMap);
      
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
      
      await _dbHelper.update(
        AppConstants.maintenanceTable,
        recordMap,
        where: 'id = ?',
        whereArgs: [record.id],
      );
      
      await loadMaintenanceRecords(record.bikeId);
    } catch (e) {
      debugPrint('Error updating maintenance record: $e');
      rethrow;
    }
  }
  
  // Delete a maintenance record
  Future<void> deleteMaintenanceRecord(String recordId, String bikeId) async {
    try {
      await _dbHelper.delete(
        AppConstants.maintenanceTable,
        where: 'id = ?',
        whereArgs: [recordId],
      );
      
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
        .where((record) => record.maintenanceType == type)
        .toList();
  }
  
  // Get completed maintenance
  List<MaintenanceRecord> getCompletedMaintenance(String bikeId) {
    return _maintenanceRecords
        .where((record) => record.bikeId == bikeId)
        .where((record) => record.status == 'Completed')
        .toList();
  }
  
  // Get scheduled maintenance
  List<MaintenanceRecord> getScheduledMaintenance(String bikeId) {
    return _maintenanceRecords
        .where((record) => record.bikeId == bikeId)
        .where((record) => record.status != 'Completed')
        .toList();
  }
}