/**
 * Interface representing a cryptographic prekey bundle
 * Used for secure communication initialization between clients
 */
export interface PreKeyBundleDto {
  key: string;
  identifier: string;
  signature?: string;
  signature_key?: string;
}

/**
 * Data Transfer Object for identity key registration
 * Contains the device ID and identity key for a device
 */
export class IdentityRegisterDto {
  deviceId: string;
  key: string;

  /**
   * Creates an IdentityRegisterDto from request data
   *
   * @param data Object containing device ID and identity key
   */
  constructor(data: { deviceId: string; key: string }) {
    this.deviceId = data.deviceId;
    this.key = data.key;
  }
}

/**
 * Data Transfer Object for uploading various types of cryptographic keys
 * Contains all the prekeys needed for secure communication
 */
export class UploadKeysDto {
  userId: string;
  deviceId: string;
  signedCurvePreKey: PreKeyBundleDto | null;
  oneTimeCurvePreKeys: PreKeyBundleDto[] | null;

  /**
   * Creates an UploadKeysDto from request data
   *
   * @param data Object containing all key data to be uploaded
   */
  constructor(data: {
    userId: string;
    deviceId: string;
    signedCurvePreKey: PreKeyBundleDto | null;
    oneTimeCurvePreKeys: PreKeyBundleDto[] | null;
  }) {
    this.userId = data.userId;
    this.deviceId = data.deviceId;
    this.signedCurvePreKey = data.signedCurvePreKey;
    this.oneTimeCurvePreKeys = data.oneTimeCurvePreKeys;
  }
}

/**
 * Data Transfer Object for key bundles returned to clients
 * Contains all keys needed for a client to initiate secure communication
 *
 * According to X3DH protocol:
 * Bob publishes a set of elliptic curve public keys to the server, containing:
 *   Bob's identity key @IKB
 *   Bob's signed prekey @SPKB
 *   Bob's prekey signature Sig(IKB, Encode(SPKB))
 *   A set of Bob's one-time prekeys (OPKB1, OPKB2, OPKB3, ...)
 */
export class KeyBundleResponseDto {
  identityKey: string;
  signedPreKey: PreKeyBundleDto | null;
  oneTimePreKeys: PreKeyBundleDto[] | null;

  /**
   * Creates a KeyBundleResponseDto from key data
   *
   * @param data Object containing identity key and various prekeys
   */
  constructor(data: {
    identityKey: string;
    signedPreKey: PreKeyBundleDto | null;
    oneTimePreKeys: PreKeyBundleDto[] | null;
  }) {
    this.identityKey = data.identityKey;
    this.signedPreKey = data.signedPreKey;
    this.oneTimePreKeys = data.oneTimePreKeys;
  }
}
