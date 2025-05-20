import 'package:tralala_app/core/models/message.dart';

class Contact {
  String id;
  String firstName;
  String lastName;
  String profileImage;
  String phoneNumber;
  bool isBlocked;
  bool isMuted;
  bool isArchived;
  List<Message> messages;

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.profileImage,
    required this.phoneNumber,
    this.isMuted = false,
    this.isBlocked = false,
    this.isArchived = false,
    this.messages = const [],
  });

  String get name => "$firstName $lastName";

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'phone': phoneNumber,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image': profileImage,
    };
  }

  static Contact fromJson(Map<String, Object?> json) {
    print(json);
    return Contact(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone'] as String,
      profileImage: json['profile_image'] as String,
    );
  }
}
