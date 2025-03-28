class Bike {
  final int? id;
  final String name;
  final String make;
  final String model;
  final int? year;
  final String? color;
  final String? vin;
  final String? licensePlate;
  final DateTime? purchaseDate;
  final double initialOdometer;
  final double currentOdometer;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Bike({
    this.id,
    required this.name,
    required this.make,
    required this.model,
    this.year,
    this.color,
    this.vin,
    this.licensePlate,
    this.purchaseDate,
    required this.initialOdometer,
    required this.currentOdometer,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get distanceTraveled => currentOdometer - initialOdometer;

  Bike copyWith({
    int? id,
    String? name,
    String? make,
    String? model,
    int? year,
    String? color,
    String? vin,
    String? licensePlate,
    DateTime? purchaseDate,
    double? initialOdometer,
    double? currentOdometer,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bike(
      id: id ?? this.id,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      vin: vin ?? this.vin,
      licensePlate: licensePlate ?? this.licensePlate,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      initialOdometer: initialOdometer ?? this.initialOdometer,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'vin': vin,
      'license_plate': licensePlate,
      'purchase_date': purchaseDate?.millisecondsSinceEpoch,
      'initial_odometer': initialOdometer,
      'current_odometer': currentOdometer,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Bike.fromMap(Map<String, dynamic> map) {
    return Bike(
      id: map['id'],
      name: map['name'],
      make: map['make'],
      model: map['model'],
      year: map['year'],
      color: map['color'],
      vin: map['vin'],
      licensePlate: map['license_plate'],
      purchaseDate: map['purchase_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['purchase_date'])
          : null,
      initialOdometer: map['initial_odometer'],
      currentOdometer: map['current_odometer'],
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}