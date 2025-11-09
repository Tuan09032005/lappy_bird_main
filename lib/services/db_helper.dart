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

        // Đảm bảo có ít nhất 1 hàng tồn tại
        await db.insert('highscore', {'score': 0});
      },
    );

    // Dọn dẹp dữ liệu cũ nếu có nhiều dòng (hợp nhất giữ lại điểm cao nhất)
    await _migrateIfNeeded(db);

    return db;
  }

  // Hợp nhất nếu có nhiều hàng — giữ lại điểm cao nhất duy nhất
  Future<void> _migrateIfNeeded(Database db) async {
    final rows = await db.query('highscore');
    if (rows.length <= 1) return; // Không cần làm gì

    // Tính điểm cao nhất
    final res = await db.rawQuery('SELECT MAX(score) as maxScore FROM highscore');
    final maxScore = (res.isNotEmpty && res.first['maxScore'] != null)
        ? (res.first['maxScore'] as num).toInt()
        : 0;

    // Xóa toàn bộ và chèn lại 1 hàng duy nhất
    await db.delete('highscore');
    await db.insert('highscore', {'score': maxScore});
  }

  /// Lấy best score hiện tại (trả về 0 nếu chưa có)
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
      final rows = await db.query('highscore', limit: 1);
      if (rows.isNotEmpty) {
        final id = rows.first['id'] as int;
        await db.update(
          'highscore',
          {'score': newScore},
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        await db.insert('highscore', {'score': newScore});
      }
    }
  }

  /// Đặt lại điểm (dành cho developer test)
  Future<void> resetScore() async {
    final db = await database;
    await db.delete('highscore');
    await db.insert('highscore', {'score': 0});
  }
}
