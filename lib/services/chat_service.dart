import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'ai_service.dart';

class ChatService {
  WebSocketChannel? _channel;
  final String baseUrl = 'ws://localhost:8000'; // In production, use actual URL
  final AiService _aiService = AiService();

  void connect(String tripId) {
    _channel = WebSocketChannel.connect(Uri.parse('$baseUrl/ws/chat/$tripId'));
  }

  void sendMessage(String message) {
    if (_channel != null) {
      _channel!.sink.add(
        jsonEncode({
          'message': message,
          'sender': 'user', // In real app, get from auth
        }),
      );

      // Check for @agent mention
      if (message.contains('@agent')) {
        _handleAgentMention(message);
      }
    }
  }

  void _handleAgentMention(String message) async {
    try {
      // Extract the prompt after @agent
      final agentIndex = message.indexOf('@agent');
      final prompt = message.substring(agentIndex + 6).trim();

      if (prompt.isNotEmpty) {
        final aiResponse = await _aiService.getTripSuggestion(prompt);

        // Send AI response back through WebSocket
        if (_channel != null) {
          _channel!.sink.add(
            jsonEncode({
              'message': aiResponse,
              'sender': 'agent',
              'isAgent': true,
            }),
          );
        }
      }
    } catch (e) {
      // Send error message
      if (_channel != null) {
        _channel!.sink.add(
          jsonEncode({
            'message': 'Sorry, I couldn\'t process your request right now.',
            'sender': 'agent',
            'isAgent': true,
          }),
        );
      }
    }
  }

  Stream<dynamic> get messages {
    return _channel?.stream ?? const Stream.empty();
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
