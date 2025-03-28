class Bike {
  final String? id;
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
  final String? imageUrl;

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
    this.imageUrl,
  });

  Bike copyWith({
    String? id,
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
    String? imageUrl,
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
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'vin': vin,
      'license_plate': licensePlate,
      'purchase_date': purchaseDate?.toIso8601String(),
      'initial_odometer': initialOdometer,
      'current_odometer': currentOdometer,
      'notes': notes,
      'image_url': imageUrl,
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
          ? DateTime.parse(map['purchase_date'])
          : null,
      initialOdometer: map['initial_odometer'],
      currentOdometer: map['current_odometer'],
      notes: map['notes'],
      imageUrl: map['image_url'],
    );
  }

  String get fullName => '$year $make $model';
  
  double get distanceTraveled => currentOdometer - initialOdometer;
}