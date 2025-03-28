import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
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
    final path = join(await getDatabasesPath(), AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.bikeTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        make TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER,
        color TEXT,
        vin TEXT,
        license_plate TEXT,
        purchase_date TEXT,
        initial_odometer REAL NOT NULL,
        current_odometer REAL NOT NULL,
        notes TEXT,
        image_url TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.fuelTable} (
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        date TEXT NOT NULL,
        odometer REAL NOT NULL,
        fuel_amount REAL NOT NULL,
        price_per_unit REAL NOT NULL,
        total_cost REAL NOT NULL,
        fuel_type TEXT NOT NULL,
        fill_type TEXT NOT NULL,
        station TEXT,
        notes TEXT,
        FOREIGN KEY (bike_id) REFERENCES ${AppConstants.bikeTable} (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.maintenanceTable} (
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        title TEXT NOT NULL,
        maintenance_type TEXT NOT NULL,
        date TEXT NOT NULL,
        odometer REAL NOT NULL,
        cost REAL NOT NULL,
        status TEXT NOT NULL,
        notes TEXT,
        is_diy INTEGER NOT NULL,
        shop_name TEXT,
        documents TEXT,
        FOREIGN KEY (bike_id) REFERENCES ${AppConstants.bikeTable} (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.reminderTable} (
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        title TEXT NOT NULL,
        maintenance_type TEXT NOT NULL,
        reminder_type TEXT NOT NULL,
        due_date TEXT,
        due_distance REAL,
        recurrence_interval INTEGER,
        is_active INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY (bike_id) REFERENCES ${AppConstants.bikeTable} (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.expenseTable} (
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        amount REAL NOT NULL,
        notes TEXT,
        receipt_image TEXT,
        FOREIGN KEY (bike_id) REFERENCES ${AppConstants.bikeTable} (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${AppConstants.documentTable} (
        id TEXT PRIMARY KEY,
        bike_id TEXT NOT NULL,
        title TEXT NOT NULL,
        document_type TEXT NOT NULL,
        date TEXT NOT NULL,
        file_path TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (bike_id) REFERENCES ${AppConstants.bikeTable} (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    // Will be implemented when version updates are needed
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool distinct = false,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(
      table,
      data,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(
      table,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }
}