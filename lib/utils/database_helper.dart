import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'moto_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Bikes table
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

    // Fuel entries table
    await db.execute('''
      CREATE TABLE fuel_entries(
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        date INTEGER NOT NULL,
        odometer REAL NOT NULL,
        volume REAL NOT NULL,
        price_per_unit REAL NOT NULL,
        total_cost REAL NOT NULL,
        is_full_tank INTEGER NOT NULL,
        fuel_type TEXT,
        station TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (bike_id) REFERENCES bikes (id) ON DELETE CASCADE
      )
    ''');

    // Maintenance records table
    await db.execute('''
      CREATE TABLE maintenance_records(
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        date INTEGER NOT NULL,
        odometer REAL,
        cost REAL NOT NULL,
        notes TEXT,
        service_provider TEXT,
        part_numbers TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (bike_id) REFERENCES bikes (id) ON DELETE CASCADE
      )
    ''');

    // Maintenance reminders table
    await db.execute('''
      CREATE TABLE maintenance_reminders(
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        reminder_type INTEGER NOT NULL,
        interval_days INTEGER,
        interval_mileage REAL,
        next_due_date INTEGER,
        next_due_mileage REAL,
        last_service_date INTEGER,
        last_service_mileage REAL,
        is_active INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (bike_id) REFERENCES bikes (id) ON DELETE CASCADE
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE expenses(
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        odometer REAL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (bike_id) REFERENCES bikes (id) ON DELETE CASCADE
      )
    ''');

    // Documents table
    await db.execute('''
      CREATE TABLE documents(
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        file_path TEXT NOT NULL,
        date INTEGER NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (bike_id) REFERENCES bikes (id) ON DELETE CASCADE
      )
    ''');
  }

  // Generic CRUD operations
  Future<int> insertRecord({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> getRecords({
    required String table,
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<Map<String, dynamic>?> getRecordById({
    required String table,
    required String id,
  }) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    
    if (results.isNotEmpty) {
      return results.first;
    }
    
    return null;
  }

  Future<int> updateRecord({
    required String table,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteRecord({
    required String table,
    required String id,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Custom queries
  Future<List<Map<String, dynamic>>> executeRawQuery(
    String sql, 
    List<dynamic> arguments,
  ) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
}