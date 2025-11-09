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
    final path = join(await getDatabasesPath(), 'flappy.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS highscore (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            score INTEGER NOT NULL
          );
        ''');
        // ensure at least one row exists
        await db.insert('highscore', {'score': 0});
      },
    );

    // After opening DB, ensure migration: consolidate multiple rows into a single row (keep MAX)
    await _migrateIfNeeded(db);

    return db;
  }

  // If table contains more than 1 row (old behavior), consolidate into single row with MAX(score)
  Future<void> _migrateIfNeeded(Database db) async {
    final rows = await db.query('highscore');
    if (rows.length <= 1) return; // nothing to do

    // compute max score among all rows
    final res = await db.rawQuery('SELECT MAX(score) as maxScore FROM highscore');
    final maxScore = (res.isNotEmpty && res.first['maxScore'] != null) ? (res.first['maxScore'] as num).toInt() : 0;

    // delete all rows
    await db.delete('highscore');

    // insert single consolidated row with maxScore
    await db.insert('highscore', {'score': maxScore});
  }

  /// Lấy best score hiện tại (trả về 0 nếu bảng trống)
  Future<int> getBestScore() async {
    final db = await database;
    final res = await db.query('highscore', limit: 1);
    if (res.isNotEmpty && res.first['score'] != null) {
      return res.first['score'] as int;
    }
    return 0;
  }

  /// Cập nhật best score nếu newScore > current
  Future<void> updateBestScore(int newScore) async {
    final db = await database;
    final current = await getBestScore();
    if (newScore > current) {
      // update the existing single row
      final rows = await db.query('highscore', limit: 1);
      if (rows.isNotEmpty) {
        await db.update('highscore', {'score': newScore}, where: 'rowid = ?', whereArgs: [rows.first['rowid'] ?? 1]);
      } else {
        await db.insert('highscore', {'score': newScore});
      }
    }
  }

  /// Reset (dev only)
  Future<void> resetScore() async {
    final db = await database;
    await db.delete('highscore');
    await db.insert('highscore', {'score': 0});
  }
}
