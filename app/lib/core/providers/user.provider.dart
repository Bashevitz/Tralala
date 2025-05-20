import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tralala_app/core/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider extends ChangeNotifier {
  // Create the baseurl variable
  static const String _baseUrl = "http://10.0.0.8:6000";

  // Create a private user variable to store user data in this provider
  User? _user;

  // Since user variable is private, we need a getter to access it outside of this class
  User? get user => _user;

  // Create the network call to register user and prompt a success message
  Future<String?> register(
    String firstName,
    String lastName,
    String phone,
    String deviceId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'phone': phone,
          'first': firstName,
          'deviceId': deviceId,
          'last': lastName,
        }),
      );

      if (response.statusCode != 201) throw Error();
      var parsedResponse = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 201) {
        final userData = parsedResponse;
        FlutterSecureStorage storage = FlutterSecureStorage();

        print(jsonEncode(userData['user']));
        // print(userData['user']['id']);

        await storage.write(key: "UserID", value: userData["user"]["id"]);
        await storage.write(key: "DeviceID", value: deviceId);
        await storage.write(key: "Phone", value: phone);
        await storage.write(
          key: "UserData",
          value: jsonEncode(userData['user']),
        );

        _user = User.fromJson(userData['user']);
        notifyListeners();
      }

      return "success";
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _removeUserData(FlutterSecureStorage storage) async {
    await storage.delete(key: "UserID");
    await storage.delete(key: "UserData");
  }

  // This handles the logic to automatically login user when they open our application
  void tryAutoLogin(String? userData) async {
    FlutterSecureStorage storage = FlutterSecureStorage();
    try {
      print("userData: ${userData ?? "null"}");
      if (userData == null) {
        await _removeUserData(storage);
        return;
      }

      final parsedUser = jsonDecode(userData);
      if (parsedUser is Map<String, dynamic>) {
        _user = User.fromJson(parsedUser);
        notifyListeners();
      } else {
        await _removeUserData(storage);
      }
    } catch (e) {
      debugPrint('Auto login error: $e');
      await _removeUserData(storage);
    }
  }
}
