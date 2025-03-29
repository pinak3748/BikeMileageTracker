import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/bike.dart';
import '../services/database_helper.dart';

class BikesProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  List<Bike> _bikes = [];
  Bike? _selectedBike;

  List<Bike> get bikes => [..._bikes];
  Bike? get selectedBike => _selectedBike;

  Future<void> loadBikes() async {
    try {
      final bikesData = await _dbHelper.getBikes();
      _bikes = bikesData.map((item) => Bike.fromMap(item)).toList();
      
      if (_bikes.isNotEmpty && _selectedBike == null) {
        _selectedBike = _bikes.first;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bikes: $e');
      _bikes = [];
      notifyListeners();
    }
  }

  Future<void> addBike(Bike bike) async {
    try {
      final bikeWithId = bike.copyWith(id: _uuid.v4());
      final bikeMap = bikeWithId.toMap();
      
      await _dbHelper.insertBike(bikeMap);
      
      await loadBikes();
      
      // Set as selected if it's the first bike
      if (_bikes.length == 1) {
        _selectedBike = _bikes.first;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding bike: $e');
      rethrow;
    }
  }

  Future<void> updateBike(Bike bike) async {
    try {
      if (bike.id == null) {
        throw Exception('Cannot update bike without id');
      }
      
      final bikeMap = bike.toMap();
      
      await _dbHelper.updateBike(bikeMap);
      
      await loadBikes();
      
      // Update selected bike if this was the selected one
      if (_selectedBike != null && _selectedBike!.id == bike.id) {
        _selectedBike = bike;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating bike: $e');
      rethrow;
    }
  }

  Future<void> deleteBike(String bikeId) async {
    try {
      await _dbHelper.deleteBike(bikeId);
      
      await loadBikes();
      
      // If the deleted bike was selected, select the first available bike
      if (_selectedBike != null && _selectedBike!.id == bikeId) {
        _selectedBike = _bikes.isNotEmpty ? _bikes.first : null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleting bike: $e');
      rethrow;
    }
  }

  void selectBike(String bikeId) {
    final bike = _bikes.firstWhere((b) => b.id == bikeId, orElse: () => throw Exception('Bike not found'));
    _selectedBike = bike;
    notifyListeners();
  }

  Future<Bike> getBike(String bikeId) async {
    try {
      final bikeData = await _dbHelper.getBike(bikeId);
      
      if (bikeData == null) {
        throw Exception('Bike not found');
      }
      
      return Bike.fromMap(bikeData);
    } catch (e) {
      debugPrint('Error getting bike: $e');
      rethrow;
    }
  }

  Future<void> updateBikeOdometer(String bikeId, double newOdometer) async {
    try {
      // Get the current bike data
      final bike = await getBike(bikeId);
      
      // Create updated bike with new odometer
      final updatedBike = bike.copyWith(currentOdometer: newOdometer);
      
      // Update in database
      await updateBike(updatedBike);
    } catch (e) {
      debugPrint('Error updating bike odometer: $e');
      rethrow;
    }
  }
}