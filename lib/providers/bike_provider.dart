import 'package:flutter/foundation.dart';
import '../models/bike.dart';
import '../utils/database_helper.dart';
import 'package:uuid/uuid.dart';

class BikeProvider with ChangeNotifier {
  List<Bike> _bikes = [];
  Bike? _currentBike;
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = Uuid();

  List<Bike> get bikes => [..._bikes];
  Bike? get currentBike => _currentBike;
  bool get hasBikes => _bikes.isNotEmpty;

  Future<void> loadBikes() async {
    final data = await _dbHelper.getRecords(
      table: 'bikes',
      orderBy: 'created_at DESC',
    );
    
    _bikes = data.map((item) => Bike.fromMap(item)).toList();
    
    if (_bikes.isNotEmpty && _currentBike == null) {
      _currentBike = _bikes[0];
    }
    
    notifyListeners();
  }

  Future<void> addBike(Bike bike) async {
    final newBike = Bike(
      id: _uuid.v4(),
      name: bike.name,
      make: bike.make,
      model: bike.model,
      year: bike.year,
      color: bike.color,
      vin: bike.vin,
      licensePlate: bike.licensePlate,
      purchaseDate: bike.purchaseDate,
      initialOdometer: bike.initialOdometer,
      currentOdometer: bike.currentOdometer,
      notes: bike.notes,
    );

    await _dbHelper.insertRecord(
      table: 'bikes',
      data: newBike.toMap(),
    );

    _bikes.add(newBike);
    
    if (_bikes.length == 1) {
      _currentBike = newBike;
    }
    
    notifyListeners();
  }

  Future<void> updateBike(Bike bike) async {
    await _dbHelper.updateRecord(
      table: 'bikes',
      id: bike.id!,
      data: bike.toMap(),
    );

    final index = _bikes.indexWhere((b) => b.id == bike.id);
    if (index >= 0) {
      _bikes[index] = bike;
      
      if (_currentBike?.id == bike.id) {
        _currentBike = bike;
      }
      
      notifyListeners();
    }
  }

  Future<void> deleteBike(String id) async {
    await _dbHelper.deleteRecord(
      table: 'bikes',
      id: id,
    );

    _bikes.removeWhere((bike) => bike.id == id);
    
    if (_currentBike?.id == id) {
      _currentBike = _bikes.isNotEmpty ? _bikes[0] : null;
    }
    
    notifyListeners();
  }

  void setCurrentBike(String id) {
    final bike = _bikes.firstWhere((bike) => bike.id == id);
    _currentBike = bike;
    notifyListeners();
  }

  Future<void> updateOdometer(String id, double value) async {
    final index = _bikes.indexWhere((bike) => bike.id == id);
    if (index >= 0) {
      final updatedBike = _bikes[index].copyWith(currentOdometer: value);
      
      await _dbHelper.updateRecord(
        table: 'bikes',
        id: id,
        data: {'current_odometer': value, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      );
      
      _bikes[index] = updatedBike;
      
      if (_currentBike?.id == id) {
        _currentBike = updatedBike;
      }
      
      notifyListeners();
    }
  }
}