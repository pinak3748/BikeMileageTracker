class MaintenanceRecord {
  final int? id;
  final int bikeId;
  final String type;
  final DateTime date;
  final double odometer;
  final double? cost;
  final String? shopName;
  final String? description;
  final bool isRecurring;
  final double? recurringInterval;
  final DateTime? nextDueDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceRecord({
    this.id,
    required this.bikeId,
    required this.type,
    required this.date,
    required this.odometer,
    this.cost,
    this.shopName,
    this.description,
    required this.isRecurring,
    this.recurringInterval,
    this.nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  MaintenanceRecord copyWith({
    int? id,
    int? bikeId,
    String? type,
    DateTime? date,
    double? odometer,
    double? cost,
    String? shopName,
    String? description,
    bool? isRecurring,
    double? recurringInterval,
    DateTime? nextDueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      type: type ?? this.type,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      cost: cost ?? this.cost,
      shopName: shopName ?? this.shopName,
      description: description ?? this.description,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'bike_id': bikeId,
      'type': type,
      'date': date.millisecondsSinceEpoch,
      'odometer': odometer,
      'cost': cost,
      'shop_name': shopName,
      'description': description,
      'is_recurring': isRecurring ? 1 : 0,
      'recurring_interval': recurringInterval,
      'next_due_date': nextDueDate?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    return MaintenanceRecord(
      id: map['id'],
      bikeId: map['bike_id'],
      type: map['type'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      odometer: map['odometer'],
      cost: map['cost'],
      shopName: map['shop_name'],
      description: map['description'],
      isRecurring: map['is_recurring'] == 1,
      recurringInterval: map['recurring_interval'],
      nextDueDate: map['next_due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['next_due_date'])
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}