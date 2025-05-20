import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:tralala_app/core/models/identity.dart';
import 'package:tralala_app/core/services/background_key_service.dart';

/// The service responsible for networking requests
class KeyService {
  static const endpoint = 'http://10.0.0.8:6000';
  static const int batchSize = 10;

  /// Bob publishes a set of elliptic curve public keys to the server, containing:
  ///   Bob's identity key [IKB]
  ///   Bob's signed prekey [SPKB]
  ///   Bob's prekey signature Sig(IKB, Encode(SPKB))
  ///   A set [setNumber] of Bob's one-time prekeys (OPKB1, OPKB2, OPKB3, ...)

  static Future<String> registerKeys({int setNumber = 100}) async {
    try {
      print("Starting background key registration...");
      await BackgroundKeyService.startKeyRegistration(setNumber: setNumber);
      return "Key registration started in background";
    } catch (e) {
      print(e.toString());
      return "Failed to start key registration";
    }
  }

  static Future<Map<String, dynamic>> retrieveKeys(String userId) async {
    log(userId);
    final response = await http.get(
      Uri.parse('$endpoint/keys/fetch/$userId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Parse identity key
      final identityKey = data['identityKey'];

      // Parse signed curve prekey

      final signedKeyData = data['signedPreKey'];
      final signedKey = signedKeyData['key'];
      final signedIdentifier = signedKeyData['identifier'];
      final signedSignature = signedKeyData['signature'];
      final signedSignatureKey = signedKeyData['signature_key'];

      final oneTimeKeyJson = data['oneTimePreKeys'];
      final onetimeKey = oneTimeKeyJson[0]["key"];
      final onetimeIdentifier = oneTimeKeyJson[0]["identifier"];

      return {
        'identity': identityKey,
        'signedPreKey': {
          'key': signedKey,
          'identifier': signedIdentifier,
          'signature': signedSignature,
          'signature_key': signedSignatureKey,
        },
        'oneTimePreKey': {'key': onetimeKey, 'identifier': onetimeIdentifier},
      };
    } else {
      throw Exception('Failed to retrieve keys: ${response.statusCode}');
    }
  }

  static Future<String> registerIdentity(
    Identity identity,
    String deviceId,
  ) async {
    try {
      final publicIdentityKey = await identity.getPublicKey();
      print('Public identity key: $publicIdentityKey');

      final response = await http.post(
        Uri.parse('$endpoint/keys/identity/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"deviceId": deviceId, "key": publicIdentityKey}),
      );

      return response.body;
    } catch (e) {
      print(e.toString());
      return "Failed to register identity";
    }
  }
}
