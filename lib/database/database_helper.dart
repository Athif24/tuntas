import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;
  static const int _dbVersion = 3;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tuntas.db');

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT NOT NULL,
        category TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    await db.insert('users', {
      'username': 'user',
      'password': 'user',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS tasks');
      await db.execute('''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          due_date TEXT NOT NULL,
          category TEXT NOT NULL,
          is_done INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
    }
    if (oldVersion < 3) {
      final result = await db.rawQuery("PRAGMA table_info('tasks')");
      final columnExists = result.any((row) => row['name'] == 'updated_at');
      if (!columnExists) {
        await db.execute('''
          ALTER TABLE tasks ADD COLUMN updated_at TEXT
        ''');
      }
    }
  }

  Future<bool> validateUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  Future<Map<String, dynamic>?> getUser() async {
    final db = await database;
    final result = await db.query('users', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updatePassword(String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<List<Map<String, dynamic>>> getTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'due_date ASC');
  }

  Future<Map<String, dynamic>?> getTask(int id) async {
    final db = await database;
    final result = await db.query('tasks', where: 'id = ?', whereArgs: [id], limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.insert('tasks', task);
  }

  Future<void> toggleTaskDone(int id, int isDone) async {
    final db = await database;
    final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await db.update(
      'tasks',
      {
        'is_done': isDone,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTaskCountDone() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE is_done = 1');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTaskCountPending() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE is_done = 0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Map<String, int>> getTasksDonePerDay() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT created_at, COUNT(*) as count
      FROM tasks
      WHERE is_done = 1
      GROUP BY created_at
    ''');
    Map<String, int> data = {};
    for (var row in result) {
      data[row['created_at'] as String] = row['count'] as int;
    }
    return data;
  }

  Future<void> deleteTask(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateTask(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('tasks', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, int>> getTasksCompletedPerDay(DateTime weekStart) async {
    final db = await database;
    final weekEnd = weekStart.add(const Duration(days: 7));
    final startStr = DateFormat('yyyy-MM-dd').format(weekStart);
    final endStr = DateFormat('yyyy-MM-dd').format(weekEnd);

    final result = await db.rawQuery('''
      SELECT COALESCE(updated_at, created_at) as completed_date,
             COUNT(*) as total
      FROM tasks
      WHERE is_done = 1
      AND COALESCE(updated_at, created_at) >= ?
      AND COALESCE(updated_at, created_at) < ?
      GROUP BY completed_date
    ''', [startStr, endStr]);

    Map<String, int> data = {};
    for (var row in result) {
      data[row['completed_date'] as String] = row['total'] as int;
    }
    return data;
  }
}
