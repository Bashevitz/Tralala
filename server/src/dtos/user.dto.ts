/**
 * Data Transfer Object for representing user information
 * Used for passing user data between layers of the application
 */
export class UserDto {
  id: string;
  first: string;
  last: string;
  phone: string;
  deviceId: string;
  profileImage: string;

  /**
   * Creates a UserDto from database result
   *
   * @param data Raw user data from database query
   */
  constructor(data: any) {
    this.id = data.id;
    this.first = data.first;
    this.last = data.last;
    this.phone = data.phone;
    this.deviceId = data.device_id;
    this.profileImage = data.profile_image;
  }
}

/**
 * Data Transfer Object for user creation requests
 * Contains all fields needed to register a new user
 */
export class CreateUserDto {
  first: string;
  last: string;
  phone: string;
  deviceId: string;

  /**
   * Creates a CreateUserDto from request data
   *
   * @param data Object containing user registration information
   */
  constructor(data: {
    first: string;
    last: string;
    phone: string;
    deviceId: string;
  }) {
    this.first = data.first;
    this.last = data.last;
    this.phone = data.phone;
    this.deviceId = data.deviceId;
  }
}

/**
 * Data Transfer Object for user login requests
 * Contains fields needed to authenticate a user
 */
export class LoginUserDto {
  phone: string;
  deviceId: string;

  /**
   * Creates a LoginUserDto from request data
   *
   * @param data Object containing login credentials
   */
  constructor(data: { phone: string; deviceId: string }) {
    this.phone = data.phone;
    this.deviceId = data.deviceId;
  }
}
