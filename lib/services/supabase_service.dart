// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  /// Lấy top N scores (order by score desc)
  Future<List<Map<String, dynamic>>> getTopScores({int limit = 20}) async {
    final res = await _client
        .from('scores')
        .select('id,device_id,player_name,score,updated_at')
        .order('score', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(res);
  }

  /// Lấy record player theo device_id
  Future<Map<String, dynamic>?> getPlayerByDevice(String deviceId) async {
    final res = await _client
        .from('scores')
        .select('id,device_id,player_name,score,updated_at')
        .eq('device_id', deviceId)
        .maybeSingle();
    if (res == null) return null;
    return Map<String, dynamic>.from(res);
  }

  /// Tạo mới record (insert)
  Future<void> insertPlayer(String deviceId, String playerName, int score) async {
    await _client.from('scores').insert({
      'device_id': deviceId,
      'player_name': playerName,
      'score': score,
    });
  }

  /// Cập nhật score/name bằng device_id
  Future<void> updatePlayer(String deviceId, {String? playerName, int? score}) async {
    final Map<String, dynamic> payload = {};
    if (playerName != null) payload['player_name'] = playerName;
    if (score != null) payload['score'] = score;
    payload['updated_at'] = DateTime.now().toUtc().toIso8601String();

    if (payload.isEmpty) return;

    await _client.from('scores').update(payload).eq('device_id', deviceId);
  }
}
