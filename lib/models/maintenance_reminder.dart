enum ReminderType {
  dateInterval,
  mileageInterval,
  both
}

class MaintenanceReminder {
  final String? id;
  final String bikeId;
  final String title;
  final String description;
  final ReminderType reminderType;
  final int? intervalDays;
  final double? intervalMileage;
  final DateTime? nextDueDate;
  final double? nextDueMileage;
  final DateTime? lastServiceDate;
  final double? lastServiceMileage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceReminder({
    this.id,
    required this.bikeId,
    required this.title,
    required this.description,
    required this.reminderType,
    this.intervalDays,
    this.intervalMileage,
    this.nextDueDate,
    this.nextDueMileage,
    this.lastServiceDate,
    this.lastServiceMileage,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        assert(
          (reminderType == ReminderType.dateInterval && intervalDays != null) ||
          (reminderType == ReminderType.mileageInterval && intervalMileage != null) ||
          (reminderType == ReminderType.both && intervalDays != null && intervalMileage != null),
          'Interval days or mileage must be provided according to reminder type',
        );

  MaintenanceReminder copyWith({
    String? id,
    String? bikeId,
    String? title,
    String? description,
    ReminderType? reminderType,
    int? intervalDays,
    double? intervalMileage,
    DateTime? nextDueDate,
    double? nextDueMileage,
    DateTime? lastServiceDate,
    double? lastServiceMileage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceReminder(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      title: title ?? this.title,
      description: description ?? this.description,
      reminderType: reminderType ?? this.reminderType,
      intervalDays: intervalDays ?? this.intervalDays,
      intervalMileage: intervalMileage ?? this.intervalMileage,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      nextDueMileage: nextDueMileage ?? this.nextDueMileage,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      lastServiceMileage: lastServiceMileage ?? this.lastServiceMileage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'bike_id': bikeId,
      'title': title,
      'description': description,
      'reminder_type': reminderType.index,
      'interval_days': intervalDays,
      'interval_mileage': intervalMileage,
      'next_due_date': nextDueDate?.millisecondsSinceEpoch,
      'next_due_mileage': nextDueMileage,
      'last_service_date': lastServiceDate?.millisecondsSinceEpoch,
      'last_service_mileage': lastServiceMileage,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory MaintenanceReminder.fromMap(Map<String, dynamic> map) {
    return MaintenanceReminder(
      id: map['id'],
      bikeId: map['bike_id'],
      title: map['title'],
      description: map['description'],
      reminderType: ReminderType.values[map['reminder_type']],
      intervalDays: map['interval_days'],
      intervalMileage: map['interval_mileage'],
      nextDueDate: map['next_due_date'] != null ? 
          DateTime.fromMillisecondsSinceEpoch(map['next_due_date']) : null,
      nextDueMileage: map['next_due_mileage'],
      lastServiceDate: map['last_service_date'] != null ? 
          DateTime.fromMillisecondsSinceEpoch(map['last_service_date']) : null,
      lastServiceMileage: map['last_service_mileage'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  bool get isDueSoon {
    final now = DateTime.now();
    final sevenDaysFromNow = now.add(const Duration(days: 7));
    
    if (reminderType == ReminderType.dateInterval || reminderType == ReminderType.both) {
      if (nextDueDate != null && nextDueDate!.isBefore(sevenDaysFromNow)) {
        return true;
      }
    }
    
    return false;
  }

  bool get isOverdue {
    final now = DateTime.now();
    
    if (reminderType == ReminderType.dateInterval || reminderType == ReminderType.both) {
      if (nextDueDate != null && nextDueDate!.isBefore(now)) {
        return true;
      }
    }
    
    return false;
  }

  bool isMileageDue(double currentOdometer) {
    if (reminderType == ReminderType.mileageInterval || reminderType == ReminderType.both) {
      if (nextDueMileage != null && currentOdometer >= nextDueMileage!) {
        return true;
      }
    }
    
    return false;
  }

  bool isMileageDueSoon(double currentOdometer) {
    if (reminderType == ReminderType.mileageInterval || reminderType == ReminderType.both) {
      if (nextDueMileage != null && nextDueMileage! - currentOdometer <= 100) {
        return true;
      }
    }
    
    return false;
  }
}