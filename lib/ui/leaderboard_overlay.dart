// lib/ui/leaderboard_overlay.dart
import 'package:flutter/material.dart';
import '../services/score_manager.dart';
import 'dialogs.dart';

class LeaderboardOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const LeaderboardOverlay({super.key, required this.onClose});

  @override
  State<LeaderboardOverlay> createState() => _LeaderboardOverlayState();
}

class _LeaderboardOverlayState extends State<LeaderboardOverlay> {
  final ScoreManager _manager = ScoreManager();
  List<Map<String, dynamic>> _rows = [];
  String? _deviceId; // not strictly needed but helps highlight
  String _myName = '';
  bool _loading = true;
  String? _error;
  int _myIndex = -1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final top = await _manager.syncAndGetTop(limit: 20);
      final name = await _manager.getPlayerName();
      // find my row by device_id field if present
      setState(() {
        _rows = top;
        _myName = name;
        _loading = false;
        // find index by device id if available
        // Note: our top items contain device_id field
        // We'll compute my index by device id saved in shared prefs
      });
      // compute my index
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('player_id');
      for (int i=0;i<_rows.length;i++){
        if (_rows[i]['device_id'] == id) {
          setState(()=>_myIndex = i);
          break;
        }
      }
    } catch (e) {
      if (e.toString().contains('NoInternet')) {
        await showNoInternetDialog(context);
        widget.onClose();
        return;
      }
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _myName);
    final newName = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Chỉnh sửa tên'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Tên của bạn')),
        actions: [
          TextButton(onPressed: ()=>Navigator.of(c).pop(), child: const Text('Huỷ')),
          TextButton(onPressed: ()=>Navigator.of(c).pop(controller.text.trim()), child: const Text('Lưu')),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await _manager.updateNameOnServer(newName);
      setState(() => _myName = newName);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.98),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  const Text('🏆 Leaderboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
                  TextButton.icon(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Quay lại'),
                  ),
                ],
              ),
            ),
            if (_loading) const Expanded(child: Center(child: CircularProgressIndicator())),
            if (!_loading && _error != null) Expanded(child: Center(child: Text('Lỗi: $_error'))),
            if (!_loading && _error == null)
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _rows.length,
                  separatorBuilder: (_, __)=> const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final row = _rows[index];
                    final isMe = index == _myIndex;
                    return Container(
                      color: isMe ? Colors.yellow.withOpacity(0.15) : null,
                      child: ListTile(
                        leading: Text('#${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        title: Text(row['player_name'] ?? 'Player', style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal)),
                        trailing: Text((row['score'] ?? 0).toString(), style: const TextStyle(fontSize: 16)),
                        subtitle: isMe ? Text('Bạn') : null,
                        onTap: isMe ? _editName : null,
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text('Hiển thị Top ${_rows.length}', style: const TextStyle(color: Colors.black54))),
                  ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text('Quay lại'),
                  )
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
