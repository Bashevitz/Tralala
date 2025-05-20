import 'package:flutter/foundation.dart';
import 'package:tralala_app/core/models/chat.dart';
import 'package:tralala_app/core/models/message.dart';

class ChatProvider with ChangeNotifier {
  List<Chat> _chats = [];
  Map<String, String?> _currentTypingNames = {};
  String _searchQuery = '';

  set chats(List<Chat> chats) => _chats = chats;
  List<Chat> get allChats => [..._chats];

  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  List<Chat> get filteredChats {
    if (_searchQuery.isEmpty) return allChats;
    return allChats.where((chat) {
      if (chat is ContactChat) {
        return chat.contact.name.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
      }
      return false;
    }).toList();
  }

  String? getCurrentTypingName(String chatId) => _currentTypingNames[chatId];

  void addChat(Chat contact) {
    _chats.insert(0, contact);
    notifyListeners();
  }

  void setCurrentTypingName(String chatId, String? name) {
    _currentTypingNames[chatId] = name;
    notifyListeners();
  }

  bool isContactTyping(String chatId) {
    return _currentTypingNames[chatId] != null;
  }

  Chat? getChat(String chatId) {
    return _chats.where((chat) => chat.id == chatId).firstOrNull;
  }

  void addMessageForChat(String chatId, Message message) {
    final chat = Chat.getChatById(_chats, chatId);

    if (chat != null) {
      chat.messages.insert(0, message);
      notifyListeners();
    }
  }
}
