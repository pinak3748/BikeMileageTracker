import 'fill_type.dart';

class FuelEntry {
  final String? id;
  final String bikeId;
  final DateTime date;
  final double odometer;
  
  // Original properties
  final double volume;
  final double cost;
  final bool isFillup;
  final String? fuelType;
  final String? stationName;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Additional properties to match UI
  final FillType fillType;
  
  // Getters for property aliases
  double get quantity => volume;
  double get totalCost => cost;
  double get costPerUnit => pricePerLiter;
  String? get station => stationName;
  
  FuelEntry({
    this.id,
    required this.bikeId,
    required this.date,
    required this.odometer,
    double? volume,
    double? cost,
    this.isFillup = true,
    this.fuelType,
    String? stationName,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    FillType? fillType,
    
    // Alias parameters
    double? quantity,
    double? totalCost,
    double? costPerUnit,
    String? station,
  })  : volume = quantity ?? volume ?? 0,
        cost = totalCost ?? cost ?? 0,
        stationName = station ?? stationName,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        fillType = fillType ?? (isFillup ? FillType.full : FillType.partial);

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
    FillType? fillType,
    
    // Support for alias properties
    double? quantity,
    double? totalCost,
    double? costPerUnit,
    String? station,
  }) {
    return FuelEntry(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      volume: quantity ?? volume ?? this.volume,
      cost: totalCost ?? cost ?? this.cost,
      isFillup: isFillup ?? this.isFillup,
      fuelType: fuelType ?? this.fuelType,
      stationName: station ?? stationName ?? this.stationName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      fillType: fillType ?? this.fillType,
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
      'fill_type': fillType.toString().split('.').last, // Store as string
    };
  }

  factory FuelEntry.fromMap(Map<String, dynamic> map) {
    final isFillup = map['is_fillup'] == 1;
    
    // Parse fill type from the database or default based on is_fillup
    FillType fillType;
    if (map.containsKey('fill_type')) {
      final fillTypeStr = map['fill_type'];
      fillType = fillTypeStr == 'full' ? FillType.full : FillType.partial;
    } else {
      fillType = isFillup ? FillType.full : FillType.partial;
    }
    
    return FuelEntry(
      id: map['id'],
      bikeId: map['bike_id'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      odometer: map['odometer'],
      volume: map['volume'],
      cost: map['cost'],
      isFillup: isFillup,
      fuelType: map['fuel_type'],
      stationName: map['station_name'],
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
      fillType: fillType,
    );
  }
}