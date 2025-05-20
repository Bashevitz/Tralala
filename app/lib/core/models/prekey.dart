import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:tralala_app/core/data/db.dart';
import 'package:tralala_app/core/utils/crypto.dart';

/// Enum representing different types of cryptographic key pairs
enum PreKeyType { ellipticCurve }

/// Abstract base class for all cryptographic key pairs
abstract class KeyPair {
  /// Returns the [$publicKey] in base64 encoded string
  Future<String> getPublicKey();

  /// Returns the [$privateKey] in base64 encoded string
  Future<String> getPrivateKey();

  /// Returns a unique identifier for the key pair (hashed [$publicKey])
  Future<Uint8List> getIdentifier();

  /// Converts the key pair to a JSON representation
  Future<Map<String, dynamic>> toJson();

  /// Returns the type of the key pair
  PreKeyType get type;

  /// Returns the key size in bits
  int get keySize;

  /// Returns the algorithm name used for this key pair
  String get algorithm;

  /// Returns the creation timestamp of the key pair
  DateTime get createdAt;

  /// Returns the expiration timestamp of the key pair (if applicable)
  DateTime? get expiresAt;

  static Future<KeyPair> fromJson(Map<String, Object?> map) {
    throw UnimplementedError();
  }
}

/// Implementation of X25519 elliptic curve key pair
class CurvedKeyPair implements KeyPair {
  final SimpleKeyPair curveKey;
  static final x25519 = X25519();

  CurvedKeyPair({required this.curveKey});

  static Future<CurvedKeyPair> generateKeyPair() async {
    return CurvedKeyPair(curveKey: await x25519.newKeyPair());
  }

  static Future<List<CurvedKeyPair>> generateKeyPairs(int count) async {
    final futures = List.generate(count, (_) => generateKeyPair());
    return Future.wait(futures);
  }

  @override
  Future<Uint8List> getIdentifier() async {
    return CryptoUtils.hash(
      Uint8List.fromList((await curveKey.extractPublicKey()).bytes),
    );
  }

  @override
  Future<String> getPublicKey() async {
    return base64Encode((await curveKey.extractPublicKey()).bytes);
  }

  Future<Map<String, dynamic>> getBundle() async {
    return {
      "key": await getPublicKey(),
      "identifier": base64Encode(await getIdentifier()),
    };
  }

  @override
  Future<String> getPrivateKey() async {
    return base64Encode(await curveKey.extractPrivateKeyBytes());
  }

  @override
  Future<Map<String, dynamic>> toJson() async {
    return {
      "identifier": base64Encode(await getIdentifier()),
      "public_key": await getPublicKey(),
      "private_key": await getPrivateKey(),
    };
  }

  static Future<CurvedKeyPair> fromJson(Map<String, dynamic> json) async {
    final publicKeyBytes = base64.decode(json["public_key"]);
    final privateKeyBytes = base64.decode(json["private_key"]);

    final keyPair = SimpleKeyPairData(
      privateKeyBytes,
      type: KeyPairType.x25519,
      publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519),
    );

    return CurvedKeyPair(curveKey: keyPair);
  }

  @override
  PreKeyType get type => PreKeyType.ellipticCurve;

  @override
  int get keySize => 256;

  @override
  String get algorithm => "X25519";

  @override
  DateTime get createdAt => DateTime.now();

  @override
  DateTime? get expiresAt => null;
}

abstract class Signed {
  Future<String> getSignature(Uint8List identityKey);
}

class SignedCurvedKeyPair extends CurvedKeyPair implements Signed {
  late SignatureKeyPair signature;

  SignedCurvedKeyPair({required super.curveKey});

  generateSignature() async {
    signature = await SignatureKeyPair.generate();
  }

  /// Returns the signature of the key pair
  ///
  /// [identityKey] - The identity key of the key pair
  ///
  /// Get the public key bytes ([SPKB] - Bob's signed prekey)
  /// and creates a combined data array containing both identity key and prekey.
  /// This follows the formula: Sig([IKB], Encode([SPKB]))
  @override
  Future<String> getSignature(Uint8List identityKey) async {
    final publicKeyBytes = Uint8List.fromList(
      (await curveKey.extractPublicKey()).bytes,
    );

    final dataToSign = Uint8List(identityKey.length + publicKeyBytes.length);
    dataToSign.setRange(0, identityKey.length, identityKey);
    dataToSign.setRange(identityKey.length, dataToSign.length, publicKeyBytes);

    final signatureResult = await signature.sign(dataToSign);

    return base64Encode(signatureResult.bytes);
  }

  Future<Map<String, dynamic>> getSignedBundle(Uint8List identityKey) async {
    return {
      "key": await getPublicKey(),
      "signature": await getSignature(identityKey),
      "signature_key": await signature.getPublicKey(),
      "identifier": base64Encode(await getIdentifier()),
    };
  }

  static Future<SignedCurvedKeyPair> fromJson(Map<String, Object?> map) async {
    final keyPair = await CurvedKeyPair.fromJson(map);
    final signedKeyPair = SignedCurvedKeyPair(curveKey: keyPair.curveKey);
    await signedKeyPair.generateSignature();
    return signedKeyPair;
  }

  static Future<SignedCurvedKeyPair> generateKeyPair() async {
    final keyPair = await CurvedKeyPair.generateKeyPair();
    final signedKeyPair = SignedCurvedKeyPair(curveKey: keyPair.curveKey);
    await signedKeyPair.generateSignature();
    await DatabaseHelper.instance.insertPreKey(signedKeyPair);
    return signedKeyPair;
  }

  static Future<List<SignedCurvedKeyPair>> generateKeyPairs(int count) async {
    final futures = List.generate(count, (_) => generateKeyPair());
    final signedKeyPairs = await Future.wait(futures);
    await DatabaseHelper.instance.insertPreKeys(signedKeyPairs);
    return signedKeyPairs;
  }

  @override
  PreKeyType get type => PreKeyType.ellipticCurve;

  @override
  int get keySize => 256;

  @override
  String get algorithm => "X25519";

  @override
  DateTime get createdAt => DateTime.now();

  @override
  DateTime? get expiresAt => null;
}

/// Implementation of Ed25519 signature scheme
class SignatureKeyPair {
  static final ed25519 = Ed25519();
  late final SimpleKeyPair keyPair;
  late final SimplePublicKey publicKey;

  SignatureKeyPair({required this.keyPair, required this.publicKey});

  static Future<SignatureKeyPair> generate() async {
    final keyPair = await ed25519.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();

    return SignatureKeyPair(keyPair: keyPair, publicKey: publicKey);
  }

  Future<String> getPublicKey() async {
    return base64Encode(publicKey.bytes);
  }

  Future<String> getPrivateKey() async {
    return base64Encode(await keyPair.extractPrivateKeyBytes());
  }

  Future<Signature> sign(Uint8List message) async {
    return await ed25519.sign(message, keyPair: keyPair);
  }

  Future<bool> verify(Uint8List message, Signature signature) async {
    return await ed25519.verify(message, signature: signature);
  }
}
