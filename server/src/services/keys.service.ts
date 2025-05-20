import { KeysRepository } from "../repositories/keys.repository";
import {
  PreKeyBundleDto,
  KeyBundleResponseDto,
  UploadKeysDto,
} from "../dtos/keys.dto";

export class KeysService {
  private keysRepository: KeysRepository;

  /**
   * Initializes the KeysService with a new KeysRepository instance
   */
  constructor() {
    this.keysRepository = new KeysRepository();
  }

  /**
   * Registers a device's identity key in the database
   *
   * @param deviceId Unique identifier for the device
   * @param identityKey The public identity key for the device
   * @returns The registration record
   */
  async registerIdentity(deviceId: string, identityKey: string): Promise<any> {
    return this.keysRepository.registerIdentity(deviceId, identityKey);
  }

  /**
   * Uploads multiple types of cryptographic keys for secure communication
   *
   * @param keysData Object containing all key data to be uploaded
   * @throws Error if required fields are missing or validation fails
   */
  async uploadKeys(keysData: UploadKeysDto): Promise<void> {
    const { userId, deviceId, signedCurvePreKey, oneTimeCurvePreKeys } =
      keysData;

    // Validate keysData
    if (!userId || !deviceId) {
      throw new Error("userId and deviceId are required");
    }

    // Upload signed curve prekey if provided
    if (signedCurvePreKey) {
      await this.keysRepository.uploadSignedCurvePreKey(
        userId,
        deviceId,
        signedCurvePreKey
      );
    }

    // Upload one-time curve prekeys if provided
    if (oneTimeCurvePreKeys && oneTimeCurvePreKeys.length > 0) {
      await this.keysRepository.uploadOneTimeCurvePreKeys(
        userId,
        deviceId,
        oneTimeCurvePreKeys
      );
    }
  }

  /**
   * Fetches a complete key bundle for a user to establish secure communication
   *
   * @param userId ID of the user whose keys should be fetched
   * @returns Key bundle containing identity and various prekeys
   * @throws Error if device ID or identity key is not found
   */
  async fetchKeyBundle(userId: string): Promise<KeyBundleResponseDto> {
    // Get the device ID for the user
    const deviceId = await this.keysRepository.getDeviceIdByUserId(userId);
    if (!deviceId) {
      throw new Error("Device ID not found for user");
    }

    // Get identity key
    const identityKey = await this.keysRepository.getIdentityKeyByDeviceId(
      deviceId
    );
    if (!identityKey) {
      throw new Error("Identity key not found for device");
    }

    // Get signed curve prekey
    const preKey = await this.keysRepository.getRandomSignedCurvePreKey(
      deviceId
    );

    // Get optional curve prekey
    const optionalCurvePreKey =
      await this.keysRepository.getRandomOneTimeCurvePreKey(deviceId);

    // Construct the response
    return new KeyBundleResponseDto({
      identityKey,
      signedPreKey: preKey ? this.mapToPreKeyBundleDto(preKey) : null,
      oneTimePreKeys: optionalCurvePreKey
        ? [this.mapToPreKeyBundleDto(optionalCurvePreKey)]
        : null,
    });
  }

  /**
   * Maps database prekey record to a PreKeyBundleDto object
   *
   * @param preKeyData Raw prekey data from the database
   * @returns Formatted PreKeyBundleDto object
   */
  private mapToPreKeyBundleDto(preKeyData: any): PreKeyBundleDto {
    return {
      key: preKeyData.key,
      identifier: preKeyData.identifier,
      signature: preKeyData.signature,
      signature_key: preKeyData.signature_key,
    };
  }
}
