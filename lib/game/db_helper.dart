import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'flappy.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE highscore(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            score INTEGER
          )
        ''');
      },
    );
  }

  Future<int> insertScore(int score) async {
    final db = await database;
    return await db.insert('highscore', {'score': score});
  }

  Future<int> getBestScore() async {
    final db = await database;
    final res = await db.rawQuery('SELECT MAX(score) as maxScore FROM highscore');
    if (res.isNotEmpty && res.first['maxScore'] != null) {
      return res.first['maxScore'] as int;
    }
    return 0;
  }
}
