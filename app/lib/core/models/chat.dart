import 'dart:convert';

import 'package:tralala_app/core/models/contact.dart';
import 'package:tralala_app/core/models/message.dart';
import 'package:uuid/v4.dart';

abstract class Chat {
  String id;
  String name;
  String profileImage;
  List<Message> messages;

  Chat({
    String? id,
    required this.name,
    required this.profileImage,
    List<Message>? messages,
  }) : id = id ?? UuidV4().generate(),
       messages = messages ?? [];

  DateTime? lastMessageTime() {
    return messages.isNotEmpty ? messages.first.createdAt : null;
  }

  int countUnread(String userId) {
    int count = 0;
    for (Message message in messages) {
      if (message.author != userId && !message.isRead) {
        count++;
      } else {
        return count;
      }
    }
    return count;
  }

  static Chat? getChatById(List<Chat> chats, String id) {
    try {
      return chats.firstWhere((chat) => chat.id == id);
    } catch (e) {
      return null;
    }
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    // Create a Contact from the chat data
    final membersId = jsonDecode(json['members_id'] as String);
    if (membersId.isEmpty) {
      throw Exception('Chat must have at least one member');
    }

    // Create and return a ContactChat
    return ContactChat(
      id: json['id'] as String,
      name: json['name'] as String,
      profileImage: json['profile_image'] as String,
      contact: Contact(
        id: membersId[0] as String,
        firstName:
            json['name']
                as String, // Using name as firstName since we don't have separate fields
        lastName: '', // Empty since we don't have this field
        profileImage: json['profile_image'] as String,
        phoneNumber: '', // Empty since we don't have this field
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'members_id': '[]',
    };
  }
}

class ContactChat extends Chat {
  final Contact contact;

  ContactChat({
    required this.contact,
    required super.name,
    required super.profileImage,
    String? id,
  }) : super(id: id ?? UuidV4().generate());

  factory ContactChat.fromContact(Contact contact, String? chatId) {
    return ContactChat(
      contact: contact,
      name: '${contact.firstName} ${contact.lastName}',
      profileImage: contact.profileImage,
      id: chatId,
    );
  }

  @override
  factory ContactChat.fromJson(Map<String, dynamic> json) {
    print(json);
    return ContactChat(
      name: '${json["first_name"]} ${json["last_name"]}',
      profileImage: json['profile_image'],
      contact: Contact(
        id: json["id"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        profileImage: json["profile_image"],
        phoneNumber: json["phone"],
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': '${contact.firstName} ${contact.lastName}',
      'profile_image': contact.profileImage,
      'members_id': '["${contact.id}"]',
    };
  }
}
