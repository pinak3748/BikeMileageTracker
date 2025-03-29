import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';
import '../utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), AppConfig.dbName);
    return await openDatabase(
      path, 
      version: 2, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add fill_type column to fuel_entries table in version 2
      await db.execute('ALTER TABLE fuel_entries ADD COLUMN fill_type TEXT');
      
      // Update existing records to set fill_type based on is_fillup
      await db.execute('''
        UPDATE fuel_entries 
        SET fill_type = CASE WHEN is_fillup = 1 THEN 'full' ELSE 'partial' END
      ''');
    }
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Create bikes table
    await db.execute('''
      CREATE TABLE bikes(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER,
        color TEXT,
        vin TEXT,
        license_plate TEXT,
        purchase_date INTEGER,
        initial_odometer REAL NOT NULL,
        current_odometer REAL NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create fuel entries table
    await db.execute('''
      CREATE TABLE fuel_entries(
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        date INTEGER NOT NULL,
        odometer REAL NOT NULL,
        volume REAL NOT NULL,
        cost REAL NOT NULL,
        is_fillup INTEGER NOT NULL,
        fuel_type TEXT,
        station_name TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        fill_type TEXT,
        FOREIGN KEY (bike_id) REFERENCES bikes (id) ON DELETE CASCADE
      )
    ''');

    // Create maintenance records table
    await db.execute('''
      CREATE TABLE maintenance_records(
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        type TEXT NOT NULL,
        date INTEGER NOT NULL,
        odometer REAL NOT NULL,
        cost REAL,
        shop_name TEXT,
        description TEXT,
        is_recurring INTEGER NOT NULL,
        recurring_interval REAL,
        next_due_date INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (bike_id) REFERENCES bikes (id) ON DELETE CASCADE
      )
    ''');

    // Create expenses table
    await db.execute('''
      CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        date INTEGER NOT NULL,
        amount REAL NOT NULL,
        odometer REAL,
        vendor TEXT,
        description TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (bike_id) REFERENCES bikes (id) ON DELETE CASCADE
      )
    ''');
    
    // Create documents table
    await db.execute('''
      CREATE TABLE documents(
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        title TEXT NOT NULL,
        document_type TEXT NOT NULL,
        date TEXT NOT NULL,
        expiry_date TEXT,
        file_path TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (bike_id) REFERENCES bikes (id) ON DELETE CASCADE
      )
    ''');
  }

  // === Bikes ===
  Future<String> insertBike(Map<String, dynamic> bike) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    bike['id'] = id;
    await db.insert('bikes', bike);
    return id;
  }

  Future<int> updateBike(Map<String, dynamic> bike) async {
    final db = await database;
    return await db.update(
      'bikes',
      bike,
      where: 'id = ?',
      whereArgs: [bike['id']],
    );
  }

  Future<int> deleteBike(String id) async {
    final db = await database;
    return await db.delete(
      'bikes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getBikes() async {
    final db = await database;
    return await db.query('bikes', orderBy: 'name');
  }

  Future<Map<String, dynamic>?> getBike(String id) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'bikes',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (result.isNotEmpty) {
      return result.first;
    }
    
    return null;
  }

  // === Fuel Entries ===
  Future<String> insertFuelEntry(Map<String, dynamic> fuelEntry) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    fuelEntry['id'] = id;
    await db.insert('fuel_entries', fuelEntry);
    return id;
  }

  Future<int> updateFuelEntry(Map<String, dynamic> fuelEntry) async {
    final db = await database;
    return await db.update(
      'fuel_entries',
      fuelEntry,
      where: 'id = ?',
      whereArgs: [fuelEntry['id']],
    );
  }

  Future<int> deleteFuelEntry(String id) async {
    final db = await database;
    return await db.delete(
      'fuel_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getFuelEntries(String bikeId) async {
    final db = await database;
    return await db.query(
      'fuel_entries',
      where: 'bike_id = ?',
      whereArgs: [bikeId],
      orderBy: 'date DESC',
    );
  }

  // === Maintenance Records ===
  Future<String> insertMaintenanceRecord(Map<String, dynamic> record) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    record['id'] = id;
    await db.insert('maintenance_records', record);
    return id;
  }

  Future<int> updateMaintenanceRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.update(
      'maintenance_records',
      record,
      where: 'id = ?',
      whereArgs: [record['id']],
    );
  }

  Future<int> deleteMaintenanceRecord(String id) async {
    final db = await database;
    return await db.delete(
      'maintenance_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getMaintenanceRecords(String bikeId) async {
    final db = await database;
    return await db.query(
      'maintenance_records',
      where: 'bike_id = ?',
      whereArgs: [bikeId],
      orderBy: 'date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUpcomingMaintenanceRecords(String bikeId) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    return await db.query(
      'maintenance_records',
      where: 'bike_id = ? AND next_due_date >= ?',
      whereArgs: [bikeId, now],
      orderBy: 'next_due_date ASC',
    );
  }

  // === Expenses ===
  Future<String> insertExpense(Map<String, dynamic> expense) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    expense['id'] = id;
    await db.insert('expenses', expense);
    return id;
  }

  Future<int> updateExpense(Map<String, dynamic> expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense,
      where: 'id = ?',
      whereArgs: [expense['id']],
    );
  }

  Future<int> deleteExpense(String id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getExpenses(String bikeId) async {
    final db = await database;
    return await db.query(
      'expenses',
      where: 'bike_id = ?',
      whereArgs: [bikeId],
      orderBy: 'date DESC',
    );
  }

  // === Stats and Summaries ===
  Future<double> getTotalFuelCost(String bikeId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(cost) as total FROM fuel_entries WHERE bike_id = ?',
      [bikeId],
    );
    
    return result.first['total'] == null ? 0.0 : result.first['total'] as double;
  }

  Future<double> getTotalFuelVolume(String bikeId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(volume) as total FROM fuel_entries WHERE bike_id = ?',
      [bikeId],
    );
    
    return result.first['total'] == null ? 0.0 : result.first['total'] as double;
  }

  Future<double> getTotalMaintenanceCost(String bikeId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(cost) as total FROM maintenance_records WHERE bike_id = ?',
      [bikeId],
    );
    
    return result.first['total'] == null ? 0.0 : result.first['total'] as double;
  }

  Future<double> getTotalExpenses(String bikeId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE bike_id = ?',
      [bikeId],
    );
    
    return result.first['total'] == null ? 0.0 : result.first['total'] as double;
  }
  
  // === Documents ===
  Future<String> insertDocument(Map<String, dynamic> document) async {
    final db = await database;
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    document['id'] = id;
    await db.insert('documents', document);
    return id;
  }

  Future<int> updateDocument(Map<String, dynamic> document) async {
    final db = await database;
    return await db.update(
      'documents',
      document,
      where: 'id = ?',
      whereArgs: [document['id']],
    );
  }

  Future<int> deleteDocument(String id) async {
    final db = await database;
    return await db.delete(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getDocuments(String bikeId) async {
    final db = await database;
    return await db.query(
      'documents',
      where: 'bike_id = ?',
      whereArgs: [bikeId],
      orderBy: 'date DESC',
    );
  }
  
  Future<List<Map<String, dynamic>>> getExpiringDocuments(String bikeId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final thirtyDaysLater = DateTime.now().add(Duration(days: 30)).toIso8601String();
    
    return await db.query(
      'documents',
      where: 'bike_id = ? AND expiry_date >= ? AND expiry_date <= ?',
      whereArgs: [bikeId, now, thirtyDaysLater],
      orderBy: 'expiry_date ASC',
    );
  }
}