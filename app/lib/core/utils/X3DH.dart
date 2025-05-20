import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tralala_app/core/data/db.dart';
import 'package:tralala_app/core/models/identity.dart';
import 'package:tralala_app/core/models/prekey.dart';
import 'package:tralala_app/core/utils/crypto.dart';

class X3DH {
  static final X25519 x25519 = X25519();

  /// To perform an X3DH key agreement with Bob, Alice contacts the server and fetches a "prekey bundle" containing the following values:
  ///
  /// - Bob's identity key IKB
  /// - Bob's signed prekey SPKB
  /// - Bob's prekey signature Sig(IKB, Encode(SPKB))
  /// - (Optionally) Bob's one-time prekey OPKB
  ///
  /// The prekey bundle is then used to encrypt a message to Bob.
  /// The server should provide one of Bob's one-time prekeys if one exists, and then delete it. If all of Bob's one-time prekeys on the server have been deleted, the bundle will not contain a one-time prekey.
  ///
  /// Alice verifies the prekey signature and aborts the protocol if verification fails. Alice then generates an ephemeral key pair with public key EKA.
  ///
  /// If the bundle does not contain a one-time prekey, she calculates:
  ///
  ///   - DH1 = DH(IKA, SPKB)
  ///   - DH2 = DH(EKA, IKB)
  ///   - DH3 = DH(EKA, SPKB)
  ///   - SK = KDF(DH1 || DH2 || DH3)
  ///
  /// If the bundle does contain a one-time prekey, the calculation is modified to include an additional DH:
  ///
  ///   - DH4 = DH(EKA, OPKB)
  ///   - SK = KDF(DH1 || DH2 || DH3 || DH4)
  ///
  /// The shared secret is then used to encrypt the message.
  ///
  /// The encrypted message is then sent to the server.
  ///
  /// The server then decrypts the message using the shared secret.
  static Future<Map<String, dynamic>> encryptMessage(
    Map<String, dynamic> recipientBundle,
    String message,
  ) async {
    final ephemeral = await CurvedKeyPair.generateKeyPair();

    final storage = FlutterSecureStorage();
    final identityKeyJson = await storage.read(key: "IdentityKey");
    final identityKey = await Identity.fromJson(jsonDecode(identityKeyJson!));

    final dh1 = await CryptoUtils.deriveSharedSecret(
      await identityKey.getPrivateKey(),
      recipientBundle['signedPreKey']['key'],
    );
    final dh2 = await CryptoUtils.deriveSharedSecret(
      await ephemeral.getPrivateKey(),
      recipientBundle['identity'],
    );
    final dh3 = await CryptoUtils.deriveSharedSecret(
      await ephemeral.getPrivateKey(),
      recipientBundle['signedPreKey']['key'],
    );

    late String? dh4;
    if (recipientBundle['oneTimePreKey'] != null) {
      dh4 = await CryptoUtils.deriveSharedSecret(
        await ephemeral.getPrivateKey(),
        recipientBundle['oneTimePreKey']['key'],
      );
    }

    final sharedSecret = await CryptoUtils.combineSharedSecrets([
      dh1,
      dh2,
      dh3,
      if (dh4 != null) dh4,
    ]);
    final encrypted = await CryptoUtils.encrypt(message, sharedSecret);

    return {
      'encryptedMessage': encrypted,
      'ephemeralKey': await ephemeral.getPublicKey(),
      'sharedSecret': sharedSecret,
    };
  }

  static Future<String> decryptMessage(
    Map<String, dynamic> senderBundle,
    String encryptedMessage,
    String ephemeralKey,
  ) async {
    try {
      final storage = FlutterSecureStorage();
      final identityKeyJson = await storage.read(key: "IdentityKey");
      final identityKey = await Identity.fromJson(jsonDecode(identityKeyJson!));

      // Get the signed pre-key
      final signedPreKeyData = await DatabaseHelper.instance
          .getPreKeyDataByIdentifier(
            senderBundle['identifiers']['signedPreKey'],
          );

      if (signedPreKeyData == null) {
        throw Exception("Signed pre-key not found");
      }

      final signedPreKey = await CurvedKeyPair.fromJson(signedPreKeyData);

      // Get the one-time pre-key if it was used
      final oneTimePreKeyData = await DatabaseHelper.instance
          .getPreKeyDataByIdentifier(
            senderBundle['identifiers']['oneTimePreKey'],
          );

      if (oneTimePreKeyData == null) {
        throw Exception("One-time pre-key not found");
      }

      final oneTimePreKey = await CurvedKeyPair.fromJson(oneTimePreKeyData);

      final dh1 = await CryptoUtils.deriveSharedSecret(
        await signedPreKey.getPrivateKey(),
        senderBundle['identifiers']['identity'],
      );
      final dh2 = await CryptoUtils.deriveSharedSecret(
        await identityKey.getPrivateKey(),
        ephemeralKey,
      );
      final dh3 = await CryptoUtils.deriveSharedSecret(
        await signedPreKey.getPrivateKey(),
        ephemeralKey,
      );

      final secretComponents = [dh1, dh2, dh3];

      // Add DH4 if a one-time pre-key was used
      final dh4 = await CryptoUtils.deriveSharedSecret(
        await oneTimePreKey.getPrivateKey(),
        ephemeralKey,
      );
      secretComponents.add(dh4);

      final sharedSecret = await CryptoUtils.combineSharedSecrets(
        secretComponents,
      );
      return sharedSecret;
    } catch (e) {
      print('Error: $e');
      return "Aborted";
    }
  }
}
