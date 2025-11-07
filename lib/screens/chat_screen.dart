import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../services/chat_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

class ChatMessage {
  final String message;
  final String sender;
  final bool isAgent;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.sender,
    this.isAgent = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'] ?? '',
      sender: json['sender'] ?? 'unknown',
      isAgent: json['isAgent'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String tripId;

  const ChatScreen({super.key, required this.tripId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  SyncService? _syncService;

  @override
  void initState() {
    super.initState();
    _syncService = Provider.of<SyncService>(context, listen: false);
    _loadCachedMessages();
    _chatService.connect(widget.tripId);
    _chatService.messages.listen((message) {
      try {
        final data = jsonDecode(message.toString());
        final chatMessage = ChatMessage.fromJson(data);
        setState(() {
          _messages.add(chatMessage);
        });
        // Cache the message
        _cacheMessage(data);
      } catch (e) {
        // Handle non-JSON messages or errors
        setState(() {
          _messages.add(
            ChatMessage(message: message.toString(), sender: 'system'),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _chatService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final message = _messageController.text;
      _chatService.sendMessage(message);

      // Add user message to local list
      setState(() {
        _messages.add(ChatMessage(message: message, sender: 'user'));
      });
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Chat'),
        actions: [
          // Connectivity indicator
          Consumer<ConnectivityService>(
            builder: (context, connectivity, child) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Icon(
                  connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: connectivity.isOnline ? Colors.green : Colors.red,
                  size: 20,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser = message.sender == 'user';

                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  alignment: isCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isAgent
                          ? Colors.blue.shade100
                          : isCurrentUser
                          ? Colors.blue.shade500
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.isAgent)
                          Row(
                            children: [
                              Icon(
                                Icons.smart_toy,
                                size: 16,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Trip Agent',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        Text(
                          message.message,
                          style: TextStyle(
                            color: message.isAgent || isCurrentUser
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message or @agent for help...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadCachedMessages() async {
    if (_syncService != null) {
      final cachedMessages = await _syncService!
          .getChatMessagesWithOfflineFallback(widget.tripId);
      setState(() {
        _messages.clear();
        _messages.addAll(
          cachedMessages.map((msg) => ChatMessage.fromJson(msg)).toList(),
        );
      });
    }
  }

  Future<void> _cacheMessage(Map<String, dynamic> messageData) async {
    if (_syncService != null) {
      await _syncService!.addOfflineOperation('send_chat_message', messageData);
    }
  }
}
