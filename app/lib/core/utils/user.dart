import 'package:flutter_secure_storage/flutter_secure_storage.dart';

Future<String> getUserId() async {
  final storage = FlutterSecureStorage();
  final userId = await storage.read(key: "UserID");
  return userId ?? "";
}
