import { Request, Response } from "express";
import { UserService } from "../services/user.service";

const userService = new UserService();

/**
 * Finds a user by their phone number
 *
 * @param req Request object containing phone number parameter
 * @param res Response object used to return the user data or error message
 * @returns User data with 200 status code if found, appropriate error codes for validation or server errors
 */
export const findContactByPhone = async (
  req: Request,
  res: Response
): Promise<any> => {
  const { phone } = req.params;

  if (!phone) {
    return res.status(400).json({ error: "Phone number is required" });
  }

  console.log(phone);

  try {
    const user = await userService.findUserByPhone(phone);

    if (!user) {
      return res
        .status(404)
        .json({ error: "No user found for this phone number" });
    }

    return res.status(200).json({
      user: {
        id: user.id,
        first_name: user.first,
        last_name: user.last,
        phone: user.phone,
        profile_image: user.profileImage,
      },
    });
  } catch (error) {
    console.error("Error searching for contact: ", error);

    if (
      error instanceof Error &&
      error.message.includes("Invalid phone number format")
    ) {
      return res.status(400).json({ error: error.message });
    }

    return res.status(500).json({ error: "Failed to search for contact" });
  }
};

/**
 * Finds a user by their ID
 *
 * @param req Request object containing user ID parameter
 * @param res Response object used to return the user data or error message
 * @returns User data with 200 status code if found, 404 if not found, or 500 for server errors
 */
export const findContactById = async (
  req: Request,
  res: Response
): Promise<any> => {
  const { id } = req.params;

  if (!id) {
    return res.status(400).json({ error: "ID is required" });
  }

  try {
    const user = await userService.findUserById(id);

    if (!user) {
      return res.status(404).json({ error: "No user found for this id" });
    }

    return res.status(200).json({
      user: {
        id: user.id,
        first_name: user.first,
        last_name: user.last,
        phone: user.phone,
        profile_image: user.profileImage,
      },
    });
  } catch (error) {
    console.error("Error searching for contact: ", error);
    return res.status(500).json({ error: "Failed to search for contact" });
  }
};
