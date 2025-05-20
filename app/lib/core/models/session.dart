class Session {
  final String chatId;
  final String sharedSecret;
  final DateTime createdAt;

  Session(this.createdAt, {required this.chatId, required this.sharedSecret});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      DateTime.parse(json['created_at']),
      chatId: json['chat_id'],
      sharedSecret: json['shared_secret'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt.toIso8601String(),
      'chat_id': chatId,
      'shared_secret': sharedSecret,
    };
  }
}
