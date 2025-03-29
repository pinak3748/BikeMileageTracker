import 'package:flutter/foundation.dart';
import '../utils/database_helper.dart';
import '../models/maintenance_record.dart';
import '../models/maintenance_reminder.dart';
import 'package:uuid/uuid.dart';

class MaintenanceProvider with ChangeNotifier {
  List<MaintenanceRecord> _maintenanceRecords = [];
  List<MaintenanceReminder> _reminders = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = Uuid();

  List<MaintenanceRecord> get maintenanceRecords => [..._maintenanceRecords];
  List<MaintenanceReminder> get reminders => [..._reminders];

  // Maintenance Records Management
  Future<void> loadMaintenanceRecords(String bikeId) async {
    final data = await _dbHelper.getRecords(
      table: 'maintenance_records',
      where: 'bike_id = ?',
      whereArgs: [bikeId],
    );
    
    _maintenanceRecords = data.map((item) => MaintenanceRecord.fromMap(item)).toList();
    notifyListeners();
  }

  Future<void> addMaintenanceRecord(MaintenanceRecord record) async {
    final newRecord = MaintenanceRecord(
      id: _uuid.v4(),
      bikeId: record.bikeId,
      title: record.title,
      category: record.category,
      date: record.date,
      odometer: record.odometer,
      cost: record.cost,
      notes: record.notes,
      serviceProvider: record.serviceProvider,
      partNumbers: record.partNumbers,
    );

    await _dbHelper.insertRecord(
      table: 'maintenance_records',
      data: newRecord.toMap(),
    );

    _maintenanceRecords.add(newRecord);
    notifyListeners();
  }

  Future<void> updateMaintenanceRecord(MaintenanceRecord record) async {
    await _dbHelper.updateRecord(
      table: 'maintenance_records',
      id: record.id!,
      data: record.toMap(),
    );

    final index = _maintenanceRecords.indexWhere((item) => item.id == record.id);
    if (index >= 0) {
      _maintenanceRecords[index] = record;
      notifyListeners();
    }
  }

  Future<void> deleteMaintenanceRecord(String id) async {
    await _dbHelper.deleteRecord(
      table: 'maintenance_records',
      id: id,
    );

    _maintenanceRecords.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // Maintenance Reminders Management
  Future<void> loadMaintenanceReminders(String bikeId) async {
    final data = await _dbHelper.getRecords(
      table: 'maintenance_reminders',
      where: 'bike_id = ?',
      whereArgs: [bikeId],
    );
    
    _reminders = data.map((item) => MaintenanceReminder.fromMap(item)).toList();
    notifyListeners();
  }

  Future<void> addReminder(MaintenanceReminder reminder) async {
    final newReminder = MaintenanceReminder(
      id: _uuid.v4(),
      bikeId: reminder.bikeId,
      title: reminder.title,
      description: reminder.description,
      reminderType: reminder.reminderType,
      intervalDays: reminder.intervalDays,
      intervalMileage: reminder.intervalMileage,
      nextDueDate: reminder.nextDueDate,
      nextDueMileage: reminder.nextDueMileage,
      lastServiceDate: reminder.lastServiceDate,
      lastServiceMileage: reminder.lastServiceMileage,
      isActive: reminder.isActive,
    );

    await _dbHelper.insertRecord(
      table: 'maintenance_reminders',
      data: newReminder.toMap(),
    );

    _reminders.add(newReminder);
    notifyListeners();
  }

  Future<void> updateReminder(MaintenanceReminder reminder) async {
    await _dbHelper.updateRecord(
      table: 'maintenance_reminders',
      id: reminder.id!,
      data: reminder.toMap(),
    );

    final index = _reminders.indexWhere((item) => item.id == reminder.id);
    if (index >= 0) {
      _reminders[index] = reminder;
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String id) async {
    await _dbHelper.deleteRecord(
      table: 'maintenance_reminders',
      id: id,
    );

    _reminders.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  Future<void> markReminderCompleted(String id, {DateTime? completionDate, double? currentOdometer}) async {
    final index = _reminders.indexWhere((item) => item.id == id);
    if (index >= 0) {
      final reminder = _reminders[index];
      DateTime? nextDate;
      double? nextMileage;
      
      if (reminder.reminderType == ReminderType.dateInterval || reminder.reminderType == ReminderType.both) {
        final date = completionDate ?? DateTime.now();
        if (reminder.intervalDays != null) {
          nextDate = date.add(Duration(days: reminder.intervalDays!));
        }
      }
      
      if (reminder.reminderType == ReminderType.mileageInterval || reminder.reminderType == ReminderType.both) {
        if (currentOdometer != null && reminder.intervalMileage != null) {
          nextMileage = currentOdometer + reminder.intervalMileage!;
        }
      }
      
      final updatedReminder = reminder.copyWith(
        lastServiceDate: completionDate ?? DateTime.now(),
        lastServiceMileage: currentOdometer,
        nextDueDate: nextDate,
        nextDueMileage: nextMileage,
      );
      
      await updateReminder(updatedReminder);
      
      // Also create a maintenance record for this service
      await addMaintenanceRecord(
        MaintenanceRecord(
          bikeId: reminder.bikeId,
          title: "Completed: ${reminder.title}",
          category: "Scheduled Service",
          date: completionDate ?? DateTime.now(),
          odometer: currentOdometer,
          notes: reminder.description,
        ),
      );
    }
  }

  // Analytics and helpers
  int getRecentMaintenanceCount(String bikeId) {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _maintenanceRecords.where(
      (record) => record.bikeId == bikeId && record.date.isAfter(thirtyDaysAgo)
    ).length;
  }

  int getUpcomingMaintenanceCount(String bikeId) {
    return _reminders.where((reminder) => 
      reminder.bikeId == bikeId && 
      reminder.isActive && 
      (reminder.isDueSoon || reminder.isOverdue)
    ).length;
  }

  double getTotalMaintenanceCost(String bikeId) {
    return _maintenanceRecords
      .where((record) => record.bikeId == bikeId)
      .fold(0, (sum, record) => sum + record.cost);
  }

  List<MaintenanceReminder> getUpcomingReminders(String bikeId, double currentOdometer) {
    return _reminders.where((reminder) => 
      reminder.bikeId == bikeId && 
      reminder.isActive && 
      (reminder.isDueSoon || 
       reminder.isOverdue || 
       reminder.isMileageDueSoon(currentOdometer) ||
       reminder.isMileageDue(currentOdometer))
    ).toList();
  }

  List<MaintenanceRecord> getMaintenanceByCategory(String bikeId, String category) {
    return _maintenanceRecords
      .where((record) => record.bikeId == bikeId && record.category == category)
      .toList();
  }

  Future<Map<String, dynamic>> getMaintenanceCostByCategory(String bikeId) async {
    final result = <String, double>{};
    
    // Get all unique categories
    final categories = _maintenanceRecords
      .where((record) => record.bikeId == bikeId)
      .map((record) => record.category)
      .toSet();
      
    for (final category in categories) {
      final records = getMaintenanceByCategory(bikeId, category);
      final total = records.fold(0.0, (sum, record) => sum + record.cost);
      result[category] = total;
    }
    
    return {
      'categories': result,
      'totalCost': getTotalMaintenanceCost(bikeId),
    };
  }
}