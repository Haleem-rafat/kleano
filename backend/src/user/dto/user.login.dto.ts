import { IsNotEmpty, IsPhoneNumber, IsString } from 'class-validator';

export class UserLoginDTO {
  @IsNotEmpty()
  @IsPhoneNumber()
  phone: string;

  @IsNotEmpty()
  fcmToken: string;

  @IsNotEmpty()
  @IsString()
  otp: string;
}
