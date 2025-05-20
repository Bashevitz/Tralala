import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'dart:math';

const appInfo = 'Tralala';

class CryptoUtils {
  static final x25519 = X25519();
  static final sha512 = Sha512();
  static final algorithm = AesGcm.with256bits();
  static final sha256 = Sha256();

  /// Generates a random seed of the specified length
  static Uint8List randomSeed(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  /// Hashes the input data using SHA-256
  static Future<Uint8List> hash(Uint8List data) async {
    final hash = await sha256.hash(data);
    return Uint8List.fromList(hash.bytes);
  }

  static Future<Map<String, String>> generateKeyPair() async {
    final keyPair = await x25519.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    return {
      'privateKey': base64Encode(await keyPair.extractPrivateKeyBytes()),
      'publicKey': base64Encode(publicKey.bytes),
    };
  }

  static Future<Map<String, String>> generateSignedPreKey(
    String identityPrivateKey,
  ) async {
    final pair = await generateKeyPair();
    final signature = await sign(identityPrivateKey, pair['publicKey']!);
    return {...pair, 'signature': signature};
  }

  static Future<String> sign(String privateKeyBase64, String dataBase64) async {
    final privateKey = base64Decode(privateKeyBase64);
    final data = base64Decode(dataBase64);
    final combined = Uint8List.fromList(privateKey + data);
    final hash = await sha512.hash(combined);
    return base64Encode(hash.bytes);
  }

  /// Derives a shared secret from a private key and a public key
  static Future<String> deriveSharedSecret(
    String privateKeyBase64,
    String publicKeyBase64,
  ) async {
    final privateKeyBytes = base64Decode(privateKeyBase64);
    final publicKeyBytes = base64Decode(publicKeyBase64);

    final publicKey = SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519);

    final privateKey = SimpleKeyPairData(
      privateKeyBytes,
      type: KeyPairType.x25519,
      publicKey: publicKey,
    );

    final sharedSecret = await x25519.sharedSecretKey(
      keyPair: privateKey,
      remotePublicKey: publicKey,
    );

    final sharedSecretBytes = await sharedSecret.extractBytes();
    return base64Encode(sharedSecretBytes);
  }

  /// Combines multiple shared secrets into a single secret
  static Future<String> combineSharedSecrets(List<String> sharedSecrets) async {
    final combinedBytes = <int>[];

    for (final secret in sharedSecrets) {
      combinedBytes.addAll(base64Decode(secret));
    }

    final hash = await sha256.hash(combinedBytes);
    return base64Encode(hash.bytes);
  }

  /// Encrypts a message using a shared secret
  static Future<String> encrypt(
    String message,
    String sharedSecretBase64,
  ) async {
    final secretKey = SecretKey(base64Decode(sharedSecretBase64));
    final nonce = randomSeed(12);

    final encrypted = await algorithm.encrypt(
      utf8.encode(message),
      secretKey: secretKey,
      nonce: nonce,
    );

    final combinedData = Uint8List(
      nonce.length + encrypted.cipherText.length + encrypted.mac.bytes.length,
    );
    combinedData.setRange(0, nonce.length, nonce);
    combinedData.setRange(
      nonce.length,
      nonce.length + encrypted.cipherText.length,
      encrypted.cipherText,
    );
    combinedData.setRange(
      nonce.length + encrypted.cipherText.length,
      combinedData.length,
      encrypted.mac.bytes,
    );

    return base64Encode(combinedData);
  }

  /// Decrypts a message using a shared secret
  static Future<String> decrypt(
    String encryptedBase64,
    String sharedSecretBase64,
  ) async {
    final secretKey = SecretKey(base64Decode(sharedSecretBase64));
    final encryptedData = base64Decode(encryptedBase64);

    final nonce = encryptedData.sublist(0, 12);
    final cipherText = encryptedData.sublist(12, encryptedData.length - 16);
    final mac = Mac(encryptedData.sublist(encryptedData.length - 16));

    final decrypted = await algorithm.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: secretKey,
    );

    return utf8.decode(decrypted);
  }

  static Future<String> generateSafetyNumber(String key1, String key2) async {
    final ordered = [key1, key2]..sort();
    final bytes = base64Decode(ordered[0]) + base64Decode(ordered[1]);
    final hash = await sha512.hash(Uint8List.fromList(bytes));
    return base64Encode(hash.bytes).substring(0, 12);
  }
}
