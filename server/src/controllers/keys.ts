import { Request, Response } from "express";
import { KeysService } from "../services/keys.service";
import { UploadKeysDto } from "../dtos/keys.dto";

const keysService = new KeysService();

/**
 * Registers a client device's identity key in the database
 *
 * @param req Request object containing deviceId and identity key
 * @param res Response object used to return success or error
 * @returns Success message or 500 error if registration fails
 */
export const registerIdentity = async (
  req: Request,
  res: Response
): Promise<any> => {
  const { deviceId, key } = req.body;

  console.log(req.body);

  try {
    await keysService.registerIdentity(deviceId, key);
    res.json("success");
  } catch (e) {
    res.status(500).json({ error: "Failed to register identity" });
  }
};

// TODO verify there is only one signedCurvePreKey and LastResortPQPreKey
/**
 * Uploads various types of cryptographic keys for secure message exchange
 *
 * @param req Request containing userId, deviceId, and various prekeys
 * @param res Response object used to return success or error
 * @returns Success message or error with appropriate status code
 */
export const uploadKeys = async (req: Request, res: Response): Promise<any> => {
  const { userId, deviceId, signedCurvePreKey, oneTimeCurvePreKeys } = req.body;

  if (!userId || !deviceId) {
    return res.status(400).json({ error: "userId and deviceId are required" });
  }

  try {
    const keysData = new UploadKeysDto({
      userId,
      deviceId,
      signedCurvePreKey,
      oneTimeCurvePreKeys,
    });

    await keysService.uploadKeys(keysData);
    res.json("success");
  } catch (e) {
    console.error(e);
    const errorMessage =
      e instanceof Error ? e.message : "Failed to upload prekeys";
    res.status(500).json({ error: errorMessage });
  }
};

/**
 * Fetches a bundle of cryptographic keys necessary to establish a secure connection with a user
 *
 * @param req Request containing userId parameter
 * @param res Response object used to return the key bundle or error
 * @returns Key bundle for the specified user or error with appropriate status code
 */
export const fetchKeyBundle = async (
  req: Request,
  res: Response
): Promise<any> => {
  const { userId } = req.params;

  console.log("userId", userId);
  try {
    const result = await keysService.fetchKeyBundle(userId);
    console.log("userId", userId);

    res.json(result);
  } catch (e) {
    console.log(e);

    res.status(500).json({ error: "Failed to fetch prekey bundle" });
  }
};
