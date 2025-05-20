import 'dart:convert';
import 'dart:isolate';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:tralala_app/core/data/db.dart';
import 'package:tralala_app/core/models/identity.dart';
import 'package:tralala_app/core/models/prekey.dart';

class BackgroundKeyService {
  static const endpoint = 'http://10.0.0.8:6000';
  static const int batchSize = 5;
  static Isolate? _isolate;
  static ReceivePort? _receivePort;

  static Future<void> startKeyRegistration({int setNumber = 100}) async {
    if (_isolate != null) {
      return; // Already running
    }

    _receivePort = ReceivePort();

    // Create a SendPort for the isolate to communicate back
    final isolateSendPort = _receivePort!.sendPort;

    // Get the root isolate token
    final rootToken = RootIsolateToken.instance;

    // Create a message to pass to the isolate
    final message = {
      'sendPort': isolateSendPort,
      'setNumber': setNumber,
      'rootToken': rootToken,
    };

    _isolate = await Isolate.spawn(_keyRegistrationIsolate, message);

    _receivePort!.listen((message) {
      if (message is String) {
        print('Key registration status: $message');
      }
    });
  }

  static void _keyRegistrationIsolate(Map<String, dynamic> message) async {
    // Initialize the binary messenger for this isolate
    BackgroundIsolateBinaryMessenger.ensureInitialized(
      message['rootToken'] as RootIsolateToken,
    );

    final SendPort sendPort = message['sendPort'];
    final int setNumber = message['setNumber'];

    try {
      final storage = FlutterSecureStorage();
      final userId = await storage.read(key: "UserID");
      final deviceId = await storage.read(key: "DeviceID");
      final token = await storage.read(key: "Token");

      final identityKey = await storage.read(key: "IdentityKey");
      final identity = await Identity.fromJson(jsonDecode(identityKey!));

      sendPort.send("Generating Pre-Keys...");

      final signedKey = await SignedCurvedKeyPair.generateKeyPair();
      final oneTimeKeys = await CurvedKeyPair.generateKeyPairs(setNumber);

      // Store keys in local database
      sendPort.send("Storing keys in local database...");
      await DatabaseHelper.instance.insertPreKey(signedKey);
      await DatabaseHelper.instance.insertPreKeys(oneTimeKeys);

      final identityKeyBytes =
          (await identity.keyPair.extractPublicKey()).bytes;

      final signedKeyJson = await signedKey.getSignedBundle(identityKeyBytes);
      final oneTimeKeysJson = await Future.wait(
        oneTimeKeys.map((keyPair) => keyPair.getBundle()),
      );

      // Send initial signed keys
      final initialRequestBody = jsonEncode({
        'userId': userId,
        'deviceId': deviceId,
        'signedCurvePreKey': signedKeyJson,
      });

      sendPort.send("Sending initial signed keys...");
      await http.post(
        Uri.parse('$endpoint/keys/upload'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Length': initialRequestBody.length.toString(),
        },
        body: initialRequestBody,
      );

      // Send batches of one-time keys
      final numberOfBatches = (setNumber / batchSize).ceil();
      for (var i = 0; i < numberOfBatches; i++) {
        final start = i * batchSize;
        final end =
            (start + batchSize > setNumber) ? setNumber : start + batchSize;

        final batchRequestBody = jsonEncode({
          'userId': userId,
          'deviceId': deviceId,
          'oneTimeCurvePreKeys': oneTimeKeysJson.sublist(start, end),
        });

        sendPort.send("Sending batch ${i + 1} of $numberOfBatches...");
        final response = await http.post(
          Uri.parse('$endpoint/keys/upload'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Length': batchRequestBody.length.toString(),
          },
          body: batchRequestBody,
        );
        sendPort.send("Batch ${i + 1} response: ${response.body}");
      }

      sendPort.send("Key registration completed successfully");
    } catch (e) {
      sendPort.send("Error during key registration: $e");
    } finally {
      sendPort.send("DONE");
    }
  }

  static void stopKeyRegistration() {
    _isolate?.kill();
    _isolate = null;
    _receivePort?.close();
    _receivePort = null;
  }
}
