import 'dart:convert';
import 'package:cryptography/cryptography.dart';

class Identity {
  SimpleKeyPair curveIdKey;
  static final x25519 = X25519();

  Identity({required this.curveIdKey});

  static Future<Identity> generate() async {
    return Identity(curveIdKey: await x25519.newKeyPair());
  }

  Future<String> getPublicKey() async {
    return base64.encode((await curveIdKey.extractPublicKey()).bytes);
  }

  Future<String> getPrivateKey() async {
    return base64.encode(await curveIdKey.extractPrivateKeyBytes());
  }

  get keyPair => curveIdKey;

  toJson() async {
    return {
      "public_key": await getPublicKey(),
      "private_key": await getPrivateKey(),
    };
  }

  static Future<Identity> fromJson(Map<String, dynamic> json) async {
    final publicKeyBytes = base64.decode(json["public_key"]);
    final privateKeyBytes = base64.decode(json["private_key"]);

    final keyPair = SimpleKeyPairData(
      privateKeyBytes,
      type: KeyPairType.x25519,
      publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519),
    );

    return Identity(curveIdKey: keyPair);
  }
}
