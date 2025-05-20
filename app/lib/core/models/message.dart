import 'package:uuid/v4.dart';

class Message {
  final String id;
  final String chatId;
  final String author;
  final String content;
  final DateTime createdAt;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  Message({
    String? id,
    required this.chatId,
    required this.author,
    required this.content,
    DateTime? createdAt,
    this.deliveredAt,
    this.readAt,
  }) : id = id ?? UuidV4().generate(),
       createdAt = createdAt ?? DateTime.now();

  bool get isRead => readAt != null;
  bool get isDelivered => deliveredAt != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'author': author,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      author: json['author'] as String,
      content: json['content'] as String,
      chatId: json['chat_id'] as String,
      createdAt: DateTime.parse(json['created_at']),
      deliveredAt:
          json['delivered_at'] != null
              ? DateTime.parse(json['delivered_at'])
              : null,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }
}
