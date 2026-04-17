import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../core/app_config.dart';

final realtimeServiceProvider = Provider((ref) => RealtimeService());

class RealtimeService {
  WebSocketChannel? _channel;
  final _events = StreamController<Map<String, dynamic>>.broadcast();
  int _retry = 0;

  Stream<Map<String, dynamic>> get events => _events.stream;

  Future<void> connect({required List<String> rooms}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return;
    final uri = Uri.parse('${AppConfig.wsBaseUrl}/api/ws').replace(
      queryParameters: {'rooms': rooms.join(','), 'token': token},
    );
    _channel = WebSocketChannel.connect(uri);
    _channel!.stream.listen(
      (raw) => _events.add(jsonDecode(raw as String) as Map<String, dynamic>),
      onDone: () => _reconnect(rooms),
      onError: (_) => _reconnect(rooms),
    );
  }

  void sendTyping(String room) {
    _channel?.sink.add(jsonEncode({'event': 'USER_TYPING', 'room': room}));
  }

  Future<void> _reconnect(List<String> rooms) async {
    _retry = (_retry + 1).clamp(1, 6);
    await Future<void>.delayed(Duration(seconds: 1 << _retry));
    await connect(rooms: rooms);
  }

  void dispose() {
    _channel?.sink.close();
    _events.close();
  }
}
