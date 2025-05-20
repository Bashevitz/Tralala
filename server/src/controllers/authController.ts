import { Request, Response } from "express";
import { UserService } from "../services/user.service";
import { CreateUserDto } from "../dtos/user.dto";

const userService = new UserService();

/**
 * Registers a new user in the system
 *
 * @param req Request object containing user registration data (first, last, phone, deviceId)
 * @param res Response object used to return the created user or error
 * @returns Created user data with 201 status code, or error with 500 status code
 */
export const register = async (req: Request, res: Response) => {
  const { first, last, phone, deviceId } = req.body;
  try {
    console.log(first, last, phone);

    const userData = new CreateUserDto({
      first,
      last,
      phone,
      deviceId,
    });

    const user = await userService.registerUser(userData);
    res.status(201).json({ user });
  } catch (error) {
    console.log(error);
    res.status(500).json({ error: "Failed to register user" });
  }
};

/**
 * Authenticates a user by phone number and updates their device ID
 *
 * @param req Request object containing phone and deviceId
 * @param res Response object used to return the user data or error message
 * @returns User data with 200 status code if found, 404 if not found, or 500 for server errors
 */
export const login = async (req: Request, res: Response): Promise<any> => {
  const { phone, deviceId } = req.body;
  try {
    const user = await userService.loginUser(phone, deviceId);

    if (!user) {
      return res.status(404).json({ error: "User not found" });
    }

    const finalResult = {
      id: user.id,
      first: user.first,
      last: user.last,
      phone: user.phone,
      device_id: user.deviceId,
      profile_image: user.profileImage,
    };

    res.json({ user: finalResult });
  } catch (error) {
    res.status(500).json({ error: "Failed to log in" });
  }
};
