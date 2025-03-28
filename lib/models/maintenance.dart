import 'package:moto_tracker/utils/constants.dart';

class Maintenance {
  final int? id;
  final int bikeId;
  final DateTime date;
  final String title;
  final String maintenanceType;
  final double odometer;
  final double cost;
  final String? partsReplaced;
  final String? serviceProvider;
  final String? notes;
  final String? receiptUrl;
  final MaintenanceStatus status;

  Maintenance({
    this.id,
    required this.bikeId,
    required this.date,
    required this.title,
    required this.maintenanceType,
    required this.odometer,
    required this.cost,
    this.partsReplaced,
    this.serviceProvider,
    this.notes,
    this.receiptUrl,
    this.status = MaintenanceStatus.completed,
  });

  Maintenance copyWith({
    int? id,
    int? bikeId,
    DateTime? date,
    String? title,
    String? maintenanceType,
    double? odometer,
    double? cost,
    String? partsReplaced,
    String? serviceProvider,
    String? notes,
    String? receiptUrl,
    MaintenanceStatus? status,
  }) {
    return Maintenance(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      date: date ?? this.date,
      title: title ?? this.title,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      odometer: odometer ?? this.odometer,
      cost: cost ?? this.cost,
      partsReplaced: partsReplaced ?? this.partsReplaced,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bike_id': bikeId,
      'date': date.toIso8601String(),
      'title': title,
      'maintenance_type': maintenanceType,
      'odometer': odometer,
      'cost': cost,
      'parts_replaced': partsReplaced,
      'service_provider': serviceProvider,
      'notes': notes,
      'receipt_url': receiptUrl,
      'status': status.index,
    };
  }

  factory Maintenance.fromMap(Map<String, dynamic> map) {
    return Maintenance(
      id: map['id'],
      bikeId: map['bike_id'],
      date: DateTime.parse(map['date']),
      title: map['title'],
      maintenanceType: map['maintenance_type'],
      odometer: map['odometer'],
      cost: map['cost'],
      partsReplaced: map['parts_replaced'],
      serviceProvider: map['service_provider'],
      notes: map['notes'],
      receiptUrl: map['receipt_url'],
      status: MaintenanceStatus.values[map['status']],
    );
  }

  @override
  String toString() {
    return 'Maintenance{id: $id, title: $title, date: $date, maintenanceType: $maintenanceType, cost: $cost, status: $status}';
  }
}

class MaintenanceReminder {
  final int? id;
  final int bikeId;
  final String title;
  final String maintenanceType;
  final DateTime? dueDate;
  final double? dueDistance;
  final ReminderType reminderType;
  final bool isCompleted;
  final int? relatedMaintenanceId;

  MaintenanceReminder({
    this.id,
    required this.bikeId,
    required this.title,
    required this.maintenanceType,
    this.dueDate,
    this.dueDistance,
    required this.reminderType,
    this.isCompleted = false,
    this.relatedMaintenanceId,
  });

  MaintenanceReminder copyWith({
    int? id,
    int? bikeId,
    String? title,
    String? maintenanceType,
    DateTime? dueDate,
    double? dueDistance,
    ReminderType? reminderType,
    bool? isCompleted,
    int? relatedMaintenanceId,
  }) {
    return MaintenanceReminder(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      title: title ?? this.title,
      maintenanceType: maintenanceType ?? this.maintenanceType,
      dueDate: dueDate ?? this.dueDate,
      dueDistance: dueDistance ?? this.dueDistance,
      reminderType: reminderType ?? this.reminderType,
      isCompleted: isCompleted ?? this.isCompleted,
      relatedMaintenanceId: relatedMaintenanceId ?? this.relatedMaintenanceId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bike_id': bikeId,
      'title': title,
      'maintenance_type': maintenanceType,
      'due_date': dueDate?.toIso8601String(),
      'due_distance': dueDistance,
      'reminder_type': reminderType.index,
      'is_completed': isCompleted ? 1 : 0,
      'related_maintenance_id': relatedMaintenanceId,
    };
  }

  factory MaintenanceReminder.fromMap(Map<String, dynamic> map) {
    return MaintenanceReminder(
      id: map['id'],
      bikeId: map['bike_id'],
      title: map['title'],
      maintenanceType: map['maintenance_type'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      dueDistance: map['due_distance'],
      reminderType: ReminderType.values[map['reminder_type']],
      isCompleted: map['is_completed'] == 1,
      relatedMaintenanceId: map['related_maintenance_id'],
    );
  }

  @override
  String toString() {
    return 'MaintenanceReminder{id: $id, title: $title, dueDate: $dueDate, dueDistance: $dueDistance, reminderType: $reminderType, isCompleted: $isCompleted}';
  }
}
