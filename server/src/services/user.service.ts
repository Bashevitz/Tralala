import { UserRepository } from "../repositories/user.repository";
import { UserDto, CreateUserDto } from "../dtos/user.dto";

const randomImages = [
  "https://images.unsplash.com/photo-1533738363-b7f9aef128ce?q=80&w=1935&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1574158622682-e40e69881006?q=80&w=2080&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1561948955-570b270e7c36?q=80&w=2101&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
  "https://images.unsplash.com/photo-1606214174585-fe31582dc6ee?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
];

export class UserService {
  private userRepository: UserRepository;

  /**
   * Initializes the UserService with a new UserRepository instance
   */
  constructor() {
    this.userRepository = new UserRepository();
  }

  /**
   * Registers a new user with the provided information and a random profile image
   *
   * @param userData Object containing first name, last name, phone number, and device ID
   * @returns Newly created user data
   */
  async registerUser(userData: CreateUserDto): Promise<UserDto> {
    const randomImage: string =
      randomImages[Math.floor(Math.random() * randomImages.length)];

    return this.userRepository.create(userData, randomImage);
  }

  /**
   * Authenticates a user by phone number and updates their device ID
   *
   * @param phone User's phone number
   * @param deviceId User's current device ID
   * @returns Updated user data if found, null otherwise
   */
  async loginUser(phone: string, deviceId: string): Promise<UserDto | null> {
    const user = await this.userRepository.findByPhone(phone);

    if (!user) {
      return null;
    }

    await this.userRepository.updateDeviceId(user.id, deviceId);

    // Update the device ID in the user object
    user.deviceId = deviceId;

    return user;
  }

  /**
   * Finds a user by their phone number, with validation for Israeli phone format
   *
   * @param phone Phone number to search for (must be in Israeli format)
   * @returns User data if found, null otherwise
   * @throws Error if phone number format is invalid
   */
  async findUserByPhone(phone: string): Promise<UserDto | null> {
    // Israeli phone number validation
    const phoneRegex = /^05[0-9]{8}$/;
    if (!phoneRegex.test(phone)) {
      throw new Error(
        "Invalid phone number format. Please use format: 05XXXXXXXX"
      );
    }

    return this.userRepository.findByPhone(phone);
  }

  /**
   * Finds a user by their unique ID
   *
   * @param id User's unique identifier
   * @returns User data if found, null otherwise
   */
  async findUserById(id: string): Promise<UserDto | null> {
    return this.userRepository.findById(id);
  }
}
