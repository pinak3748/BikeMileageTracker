import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bike.dart';
import '../services/database_helper.dart';

class BikeProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  List<Bike> _bikes = [];
  Bike? _currentBike;
  static const String _currentBikeIdKey = 'current_bike_id';

  List<Bike> get bikes => [..._bikes];
  Bike? get currentBike => _currentBike;
  bool get hasBikes => _bikes.isNotEmpty;

  BikeProvider() {
    loadBikes();
  }

  Future<void> loadBikes() async {
    try {
      final bikesData = await _dbHelper.getBikes();
      _bikes = bikesData.map((item) => Bike.fromMap(item)).toList();
      
      if (_bikes.isNotEmpty) {
        // Get the last selected bike id from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final currentBikeId = prefs.getString(_currentBikeIdKey);
        
        if (currentBikeId != null) {
          _currentBike = _bikes.firstWhere(
            (bike) => bike.id == currentBikeId,
            orElse: () => _bikes.first,
          );
        } else {
          _currentBike = _bikes.first;
          await prefs.setString(_currentBikeIdKey, _currentBike!.id!);
        }
      } else {
        _currentBike = null;
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bikes: $e');
      // Reset to empty state on error
      _bikes = [];
      _currentBike = null;
      notifyListeners();
    }
  }

  Future<void> addBike(Bike bike) async {
    try {
      final bikeWithId = bike.copyWith(id: _uuid.v4());
      final bikeMap = bikeWithId.toMap();
      
      await _dbHelper.insertBike(bikeMap);
      
      // Reload bikes to get the updated list
      await loadBikes();
      
      // If this is the first bike, set it as current
      if (_bikes.length == 1) {
        _currentBike = _bikes.first;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_currentBikeIdKey, _currentBike!.id!);
      }
      
      notifyListeners();
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
      
      final index = _bikes.indexWhere((b) => b.id == bike.id);
      if (index != -1) {
        _bikes[index] = bike;
        
        // Update current bike reference if needed
        if (_currentBike?.id == bike.id) {
          _currentBike = bike;
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating bike: $e');
      rethrow;
    }
  }

  Future<void> deleteBike(String bikeId) async {
    try {
      await _dbHelper.deleteBike(bikeId);
      
      _bikes.removeWhere((bike) => bike.id == bikeId);
      
      // If we deleted the current bike, select another one
      if (_currentBike?.id == bikeId) {
        if (_bikes.isNotEmpty) {
          _currentBike = _bikes.first;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_currentBikeIdKey, _currentBike!.id!);
        } else {
          _currentBike = null;
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_currentBikeIdKey);
        }
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting bike: $e');
      rethrow;
    }
  }

  Future<void> selectBike(String bikeId) async {
    final bike = _bikes.firstWhere((b) => b.id == bikeId);
    if (bike.id != _currentBike?.id) {
      _currentBike = bike;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentBikeIdKey, bikeId);
      notifyListeners();
    }
  }
  
  // Add setCurrentBike method to fix the error in custom_app_bar.dart
  Future<void> setCurrentBike(String bikeId) async {
    return selectBike(bikeId);
  }

  Future<void> updateOdometer(String bikeId, double newOdometer) async {
    try {
      final index = _bikes.indexWhere((b) => b.id == bikeId);
      if (index != -1) {
        final updatedBike = _bikes[index].copyWith(currentOdometer: newOdometer);
        
        await _dbHelper.updateBike({
          'id': bikeId,
          'current_odometer': newOdometer,
          'updated_at': DateTime.now().millisecondsSinceEpoch
        });
        
        _bikes[index] = updatedBike;
        
        // Update current bike reference if needed
        if (_currentBike?.id == bikeId) {
          _currentBike = updatedBike;
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating odometer: $e');
      rethrow;
    }
  }
}