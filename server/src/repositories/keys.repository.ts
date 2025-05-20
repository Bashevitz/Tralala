import pool from "../models/db";
import { PreKeyBundleDto } from "../dtos/keys.dto";

export class KeysRepository {
  /**
   * Registers or updates a device's identity key
   *
   * @param deviceId Unique identifier for the device
   * @param identityKey Public identity key for the device
   * @returns The registration record with device_id, identity_key, and created_at fields
   */
  async registerIdentity(deviceId: string, identityKey: string): Promise<any> {
    const result = await pool.query(
      `
      INSERT INTO identities (device_id, identity_key)
      VALUES ($1, $2)
      ON CONFLICT (device_id)
      DO UPDATE SET 
        identity_key = EXCLUDED.identity_key,
        created_at = CASE 
          WHEN identities.created_at IS NULL THEN NOW()
          ELSE identities.created_at
        END
      RETURNING device_id, identity_key, created_at;
      `,
      [deviceId, identityKey]
    );
    return result.rows[0];
  }

  /**
   * Saves a signed curve prekey to the database
   *
   * @param userId ID of the user the prekey belongs to
   * @param deviceId Device ID associated with the prekey
   * @param preKeyBundle Object containing the prekey data
   */
  async uploadSignedCurvePreKey(
    userId: string,
    deviceId: string,
    preKeyBundle: PreKeyBundleDto
  ): Promise<void> {
    await pool.query(
      `
      INSERT INTO prekeys (user_id, device_id, prekey_type, key, identifier, signature, signature_key)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      RETURNING *;
      `,
      [
        userId,
        deviceId,
        "signed_curve",
        preKeyBundle.key,
        preKeyBundle.identifier,
        preKeyBundle.signature,
        preKeyBundle.signature_key,
      ]
    );
  }

  /**
   * Saves a batch of one-time curve prekeys to the database
   *
   * @param userId ID of the user the prekeys belong to
   * @param deviceId Device ID associated with the prekeys
   * @param preKeyBundles Array of prekey data objects
   */
  async uploadOneTimeCurvePreKeys(
    userId: string,
    deviceId: string,
    preKeyBundles: PreKeyBundleDto[]
  ): Promise<void> {
    for (const preKeyBundle of preKeyBundles) {
      await pool.query(
        `
        INSERT INTO prekeys (user_id, device_id, prekey_type, key, identifier, signature, signature_key)
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING *;
        `,
        [
          userId,
          deviceId,
          "onetime_curve",
          preKeyBundle.key,
          preKeyBundle.identifier,
          null,
          null,
        ]
      );
    }
  }

  /**
   * Gets a device ID for a given user ID
   *
   * @param userId ID of the user to look up
   * @returns Device ID if found, null otherwise
   */
  async getDeviceIdByUserId(userId: string): Promise<string | null> {
    const result = await pool.query(
      `
      SELECT device_id 
      FROM users 
      WHERE id = $1;
      `,
      [userId]
    );

    return result.rows[0]?.device_id || null;
  }

  /**
   * Gets an identity key for a given device ID
   *
   * @param deviceId Device ID to look up
   * @returns Identity key if found, null otherwise
   */
  async getIdentityKeyByDeviceId(deviceId: string): Promise<string | null> {
    const result = await pool.query(
      `
      SELECT * FROM identities WHERE device_id = $1;
      `,
      [deviceId]
    );

    return result.rows[0]?.identity_key || null;
  }

  /**
   * Gets a random signed curve prekey for a device
   *
   * @param deviceId Device ID to get a prekey for
   * @returns A random signed curve prekey if available, null otherwise
   */
  async getRandomSignedCurvePreKey(deviceId: string): Promise<any | null> {
    const result = await pool.query(
      `
      SELECT *
      FROM prekeys
      WHERE device_id = $1
      AND prekey_type = 'signed_curve'
      AND is_active = FALSE
      AND expiration_date > NOW()
      ORDER BY RANDOM()
      LIMIT 1;
      `,
      [deviceId]
    );

    return result.rows[0] || null;
  }

  /**
   * Gets a random one-time curve prekey for a device
   *
   * @param deviceId Device ID to get a prekey for
   * @returns A random one-time curve prekey if available, null otherwise
   */
  async getRandomOneTimeCurvePreKey(deviceId: string): Promise<any | null> {
    const result = await pool.query(
      `
      SELECT *
      FROM prekeys
      WHERE device_id = $1
      AND prekey_type = 'onetime_curve'
      AND is_active = FALSE
      AND expiration_date > NOW()
      ORDER BY RANDOM()
      LIMIT 1;
      `,
      [deviceId]
    );

    return result.rows[0] || null;
  }
}
