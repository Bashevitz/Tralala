import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketHelper {
  static IO.Socket? _socket;
  static final SocketHelper instance = SocketHelper._internal();
  SocketHelper._internal();

  Future<IO.Socket> get socket async {
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: "UserID");
    if (userId == null) throw Exception("User ID not found");

    if (_socket != null) return _socket!;

    _socket = await _initSocket();
    return _socket!;
  }

  static Future<void> _verifySocket() async {
    _socket ??= await _initSocket();
  }

  static IO.Socket _initSocket() {
    if (_socket != null) return _socket!;

    _socket = IO.io(
      'http://10.0.0.8:6000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build(),
    );

    _socket!.onConnect((_) async {
      final storage = FlutterSecureStorage();
      final userId = await storage.read(key: "UserID");
      if (userId == null) throw Exception("User ID not found");

      _socket!.emit("user:authenticate", {"userId": userId});
    });

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
    });

    _socket!.onError((error) {
      print('Socket error: $error');
    });

    _socket!.connect();

    return _socket!;
  }

  void subscribe(
    String channel,
    Function(Map<String, dynamic>) onGetData,
  ) async {
    await _verifySocket();
    _socket!.on(channel, (data) {
      print(data);
      if (data is String) {
        data = jsonDecode(data);
      }
      onGetData(data as Map<String, dynamic>);
    });
  }

  Future<void> newChat(String id, String contactId) async {
    await _verifySocket();
    final storage = FlutterSecureStorage();
    final userId = await storage.read(key: "UserID");
    if (userId == null) throw Exception("User ID not found");

    _socket!.emit('chat:new', {
      "id": id,
      "type": "contact",
      "contacts": [userId, contactId],
    });
  }

  Future<void> sendMessage(
    Map<String, dynamic> message,
    String chatId,
    String? recipientId,
  ) async {
    await _verifySocket();
    try {
      _socket!.emit('message:send', message);
      print('Message sent: ${jsonEncode(message)}');
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> joinChat(String contactId) async {
    await _verifySocket();
    try {
      _socket!.emit('chat:join', contactId);
      print('Joined chat with: $contactId');
    } catch (e) {
      print('Error joining chat: $e');
      rethrow;
    }
  }

  void dispose() {
    _socket?.disconnect();
    _socket = null;
  }
}
