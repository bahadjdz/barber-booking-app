import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/appointment.dart';
import '../models/service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('barber_booking.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE appointments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_name TEXT NOT NULL,
        phone TEXT,
        service_name TEXT,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        status TEXT NOT NULL,
        price REAL NOT NULL DEFAULT 0,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE services(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL DEFAULT 0,
        icon TEXT NOT NULL DEFAULT 'scissors'
      )
    ''');

    // Insert initial default barber services
    await _insertDefaultServices(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE services ADD COLUMN icon TEXT NOT NULL DEFAULT "scissors"');
    }
  }

  Future<void> _insertDefaultServices(Database db) async {
    final defaultServices = [
      {'name': 'قص شعر', 'price': 500.0, 'icon': 'scissors'},
      {'name': 'حلاقة لحية', 'price': 300.0, 'icon': 'beard'},
      {'name': 'قص + لحية', 'price': 700.0, 'icon': 'scissors'},
      {'name': 'تنعيم الشعر', 'price': 1000.0, 'icon': 'smooth'},
      {'name': 'عناية بالبشرة', 'price': 800.0, 'icon': 'care'},
    ];

    for (final service in defaultServices) {
      await db.insert('services', service);
    }
  }

  // --- Appointments CRUD ---

  Future<int> insertAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert('appointments', appointment.toMap());
  }

  Future<List<Appointment>> getAppointmentsByDate(String date) async {
    final db = await database;
    final maps = await db.query(
      'appointments',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id ASC',
    );
    return maps.map((map) => Appointment.fromMap(map)).toList();
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    return await db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> updateAppointmentStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'appointments',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db.delete(
      'appointments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getDailyRevenue(String date) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(price) as total FROM appointments WHERE date = ? AND status = ?',
      [date, 'done'],
    );
    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    }
    return 0.0;
  }

  // --- Services CRUD ---

  Future<int> insertService(BarberService service) async {
    final db = await database;
    return await db.insert('services', service.toMap());
  }

  Future<List<BarberService>> getAllServices() async {
    final db = await database;
    final maps = await db.query('services', orderBy: 'id ASC');
    return maps.map((map) => BarberService.fromMap(map)).toList();
  }

  Future<int> updateService(BarberService service) async {
    final db = await database;
    return await db.update(
      'services',
      service.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  Future<int> deleteService(int id) async {
    final db = await database;
    return await db.delete(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
