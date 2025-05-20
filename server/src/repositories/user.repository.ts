import pool from "../models/db";
import { UserDto, CreateUserDto } from "../dtos/user.dto";

export class UserRepository {
  /**
   * Creates a new user in the database
   *
   * @param userData Object containing user details (first, last, phone, deviceId)
   * @param profileImage URL of the user's profile image
   * @returns Newly created user as a UserDto
   */
  async create(
    userData: CreateUserDto,
    profileImage: string
  ): Promise<UserDto> {
    const { first, last, phone, deviceId } = userData;

    const result = await pool.query(
      "INSERT INTO users (first, last, phone, device_id, profile_image) VALUES ($1, $2, $3, $4, $5) RETURNING *",
      [first, last, phone, deviceId, profileImage]
    );

    return new UserDto(result.rows[0]);
  }

  /**
   * Finds a user by their phone number
   *
   * @param phone Phone number to search for
   * @returns UserDto if found, null otherwise
   */
  async findByPhone(phone: string): Promise<UserDto | null> {
    const result = await pool.query("SELECT * FROM users WHERE phone = $1", [
      phone,
    ]);

    if (result.rows.length === 0) {
      return null;
    }

    return new UserDto(result.rows[0]);
  }

  /**
   * Finds a user by their unique ID
   *
   * @param id User's unique identifier
   * @returns UserDto if found, null otherwise
   */
  async findById(id: string): Promise<UserDto | null> {
    const result = await pool.query("SELECT * FROM users WHERE id = $1", [id]);

    if (result.rows.length === 0) {
      return null;
    }

    return new UserDto(result.rows[0]);
  }

  /**
   * Updates a user's device ID
   *
   * @param userId ID of the user to update
   * @param deviceId New device ID value
   */
  async updateDeviceId(userId: string, deviceId: string): Promise<void> {
    await pool.query("UPDATE users SET device_id = $1 WHERE id = $2", [
      deviceId,
      userId,
    ]);
  }
}
