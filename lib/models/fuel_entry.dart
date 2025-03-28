import 'package:moto_tracker/utils/constants.dart';

class FuelEntry {
  final int? id;
  final int bikeId;
  final DateTime date;
  final double odometer;
  final double quantity;
  final double costPerUnit;
  final double totalCost;
  final FillType fillType;
  final String? fuelType;
  final String? station;
  final String? notes;
  final double? tripDistance;
  final double? efficiency;

  FuelEntry({
    this.id,
    required this.bikeId,
    required this.date,
    required this.odometer,
    required this.quantity,
    required this.costPerUnit,
    required this.totalCost,
    required this.fillType,
    this.fuelType,
    this.station,
    this.notes,
    this.tripDistance,
    this.efficiency,
  });

  FuelEntry copyWith({
    int? id,
    int? bikeId,
    DateTime? date,
    double? odometer,
    double? quantity,
    double? costPerUnit,
    double? totalCost,
    FillType? fillType,
    String? fuelType,
    String? station,
    String? notes,
    double? tripDistance,
    double? efficiency,
  }) {
    return FuelEntry(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      quantity: quantity ?? this.quantity,
      costPerUnit: costPerUnit ?? this.costPerUnit,
      totalCost: totalCost ?? this.totalCost,
      fillType: fillType ?? this.fillType,
      fuelType: fuelType ?? this.fuelType,
      station: station ?? this.station,
      notes: notes ?? this.notes,
      tripDistance: tripDistance ?? this.tripDistance,
      efficiency: efficiency ?? this.efficiency,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bike_id': bikeId,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'quantity': quantity,
      'cost_per_unit': costPerUnit,
      'total_cost': totalCost,
      'fill_type': fillType.index,
      'fuel_type': fuelType,
      'station': station,
      'notes': notes,
      'trip_distance': tripDistance,
      'efficiency': efficiency,
    };
  }

  factory FuelEntry.fromMap(Map<String, dynamic> map) {
    return FuelEntry(
      id: map['id'],
      bikeId: map['bike_id'],
      date: DateTime.parse(map['date']),
      odometer: map['odometer'],
      quantity: map['quantity'],
      costPerUnit: map['cost_per_unit'],
      totalCost: map['total_cost'],
      fillType: FillType.values[map['fill_type']],
      fuelType: map['fuel_type'],
      station: map['station'],
      notes: map['notes'],
      tripDistance: map['trip_distance'],
      efficiency: map['efficiency'],
    );
  }

  @override
  String toString() {
    return 'FuelEntry{id: $id, date: $date, odometer: $odometer, quantity: $quantity, totalCost: $totalCost, efficiency: $efficiency}';
  }
}
