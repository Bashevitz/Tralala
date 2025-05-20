import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tralala_app/core/models/contact.dart';

class ContactService {
  static const String _baseUrl = "http://10.0.0.8:6000";

  static Future<Contact> findContact(String phone) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/contacts/phone/$phone'),
    );
    print(response.body);
    return Contact.fromJson(jsonDecode(response.body)["user"]);
  }

  static Future<Contact> fetchContact(String userId) async {
    try {
      print('Fetching contact: $_baseUrl/contacts/id/$userId');
      final response = await http.get(
        Uri.parse('$_baseUrl/contacts/id/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch contact: ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      return Contact.fromJson(data["user"]);
    } catch (e) {
      print('Error fetching contact: $e');
      rethrow;
    }
  }
}
