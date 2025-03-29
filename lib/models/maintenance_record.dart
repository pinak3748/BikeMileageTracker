class MaintenanceRecord {
  final String? id;
  final String bikeId;
  final String title;
  final String category;
  final DateTime date;
  final double? odometer;
  final double cost;
  final String? notes;
  final String? serviceProvider;
  final String? partNumbers;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaintenanceRecord({
    this.id,
    required this.bikeId,
    required this.title,
    required this.category,
    required this.date,
    this.odometer,
    this.cost = 0.0,
    this.notes,
    this.serviceProvider,
    this.partNumbers,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  MaintenanceRecord copyWith({
    String? id,
    String? bikeId,
    String? title,
    String? category,
    DateTime? date,
    double? odometer,
    double? cost,
    String? notes,
    String? serviceProvider,
    String? partNumbers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      cost: cost ?? this.cost,
      notes: notes ?? this.notes,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      partNumbers: partNumbers ?? this.partNumbers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'bike_id': bikeId,
      'title': title,
      'category': category,
      'date': date.millisecondsSinceEpoch,
      'odometer': odometer,
      'cost': cost,
      'notes': notes,
      'service_provider': serviceProvider,
      'part_numbers': partNumbers,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    return MaintenanceRecord(
      id: map['id'],
      bikeId: map['bike_id'],
      title: map['title'],
      category: map['category'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      odometer: map['odometer'],
      cost: map['cost'] ?? 0.0,
      notes: map['notes'],
      serviceProvider: map['service_provider'],
      partNumbers: map['part_numbers'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}