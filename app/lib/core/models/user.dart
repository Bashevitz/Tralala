class User {
  // please note that we get all these data from the API we are using
  final String id;
  final String deviceId;
  final String first;
  final String last;
  final String phone;
  final String profilePicture;

  User.fromJson(Map<String, dynamic> user)
    : id = user['id'],
      deviceId = user['deviceId'],
      first = user['first'],
      last = user['last'],
      phone = user['phone'],
      profilePicture = user['profileImage'];

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "deviceId": deviceId,
      "first": first,
      "last": last,
      "phone": phone,
      "profileImage": profilePicture,
    };
  }
}
