import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tracking/data/models/experience.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tracking.db'); // SQLite 파일명
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
        await _insertData(db);
      },
    );
  }

  Future<void> _insertData(Database db) async {
    await db.transaction((txn) async {
      final int? count = Sqflite.firstIntValue(
          await txn.rawQuery('SELECT COUNT(*) FROM experience'));

      if (count != null && count < 1) {
        Experience experience = Experience.createInitExperience();
        await txn.insert('experience', experience.toMap());
      }
    });
  }

  Future<void> _createTables(Database db) async {
    // experience table
    await db.execute('''
      CREATE TABLE experience (
        expId TEXT PRIMARY KEY,
        level INTEGER NOT NULL,
        exp INTEGER NOT NULL,
        distance REAL NOT NULL,
        time INTEGER NOT NULL
      )
    ''');
    // recode table
    await db.execute('''
      CREATE TABLE recode (
        recodeId TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        date TEXT NOT NULL,
        start TEXT NOT NULL,
        end TEXT NOT NULL,
        time INTEGER NOT NULL,
        distance REAL NOT NULL,
        speed REAL NOT NULL,
        exp INTEGER NOT NULL
      )
    ''');
    // recode_detail table
    await db.execute('''
      CREATE TABLE recode_detail (
        detailId TEXT PRIMARY KEY,
        recodeId TEXT NOT NULL,
        interval INTEGER NOT NULL,
        distance REAL NOT NULL,
        speed REAL NOT NULL,
        time INTEGER NOT NULL
      )
    ''');
    // recode_photo table
    await db.execute('''
      CREATE TABLE recode_photo (
        photoId TEXT PRIMARY KEY,
        recodeId TEXT NOT NULL,
        title TEXT NOT NULL
      )
    ''');
    // trophy table
    await db.execute('''
      CREATE TABLE trophy (
        trophyId TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        conditionType TEXT NOT NULL,
        conditionValue REAL NOT NULL,
        depth INTEGER NOT NULL
      )
    ''');
    // trophy_room table
    await db.execute('''
      CREATE TABLE trophy_room (
        roomId TEXT PRIMARY KEY,
        trophyId TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }
}
