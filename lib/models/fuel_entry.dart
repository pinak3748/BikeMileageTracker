class FuelEntry {
  final String? id;
  final String bikeId;
  final DateTime date;
  final double odometer;
  final double volume;
  final double cost;
  final bool isFillup;
  final String? fuelType;
  final String? stationName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FuelEntry({
    this.id,
    required this.bikeId,
    required this.date,
    required this.odometer,
    required this.volume,
    required this.cost,
    required this.isFillup,
    this.fuelType,
    this.stationName,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get pricePerLiter => volume > 0 ? cost / volume : 0;

  FuelEntry copyWith({
    String? id,
    String? bikeId,
    DateTime? date,
    double? odometer,
    double? volume,
    double? cost,
    bool? isFillup,
    String? fuelType,
    String? stationName,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FuelEntry(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      volume: volume ?? this.volume,
      cost: cost ?? this.cost,
      isFillup: isFillup ?? this.isFillup,
      fuelType: fuelType ?? this.fuelType,
      stationName: stationName ?? this.stationName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'bike_id': bikeId,
      'date': date.millisecondsSinceEpoch,
      'odometer': odometer,
      'volume': volume,
      'cost': cost,
      'is_fillup': isFillup ? 1 : 0,
      'fuel_type': fuelType,
      'station_name': stationName,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory FuelEntry.fromMap(Map<String, dynamic> map) {
    return FuelEntry(
      id: map['id'],
      bikeId: map['bike_id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      odometer: map['odometer'],
      volume: map['volume'],
      cost: map['cost'],
      isFillup: map['is_fillup'] == 1,
      fuelType: map['fuel_type'],
      stationName: map['station_name'],
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }
}