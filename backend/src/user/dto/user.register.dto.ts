import {
  IsNotEmpty,
  IsString,
  IsEmail,
  IsPhoneNumber,
  IsOptional,
} from 'class-validator';

export class UserRegisterDTO {
  @IsNotEmpty()
  @IsString()
  userName: string;

  @IsOptional()
  @IsNotEmpty()
  @IsEmail()
  email?: string;

  @IsNotEmpty()
  @IsPhoneNumber()
  phone: string;

  @IsNotEmpty()
  fcmToken: string;
}
