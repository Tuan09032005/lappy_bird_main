// lib/services/score_manager.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supabase_service.dart';
import 'db_helper.dart';
import 'dart:math';

class ScoreManager {
  static const _playerIdKey = 'player_id';
  static const _playerNameKey = 'player_name';

  final SupabaseService _supabase = SupabaseService();
  final DBHelper _db = DBHelper();

  Future<bool> hasInternet() async {
    final c = await Connectivity().checkConnectivity();
    return c != ConnectivityResult.none;
  }

  Future<String> _ensurePlayerId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(_playerIdKey);
    if (id == null) {
      id = 'player_${Random().nextInt(1000000)}';
      await prefs.setString(_playerIdKey, id);
    }
    return id;
  }

  Future<String> getPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_playerNameKey) ?? 'Player';
  }

  Future<void> setPlayerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerNameKey, name);
  }

  /// Đồng bộ điểm cục bộ lên Supabase (chỉ update khi cao hơn)
  /// Trả về list top20 (fresh) sau khi sync (nếu có mạng).
  Future<List<Map<String, dynamic>>> syncAndGetTop({int limit = 20}) async {
    final online = await hasInternet();
    if (!online) {
      throw Exception('NoInternet');
    }

    final deviceId = await _ensurePlayerId();
    final localBest = await _db.getBestScore();
    final playerName = await getPlayerName();

    // Kiểm tra server
    final serverRecord = await _supabase.getPlayerByDevice(deviceId);

    if (serverRecord == null) {
      // insert
      await _supabase.insertPlayer(deviceId, playerName, localBest);
    } else {
      final serverScore = (serverRecord['score'] is int) ? serverRecord['score'] as int : int.parse(serverRecord['score'].toString());
      if (localBest > serverScore) {
        await _supabase.updatePlayer(deviceId, score: localBest, playerName: playerName);
      } else if (playerName != serverRecord['player_name']) {
        // ensure name stays up-to-date
        await _supabase.updatePlayer(deviceId, playerName: playerName);
      }
    }

    // Lấy top
    final top = await _supabase.getTopScores(limit: limit);
    return top;
  }

  /// Update player's name on server (only when in top or you allow)
  Future<void> updateNameOnServer(String newName) async {
    final deviceId = await _ensurePlayerId();
    await setPlayerName(newName);
    await _supabase.updatePlayer(deviceId, playerName: newName);
  }
}
