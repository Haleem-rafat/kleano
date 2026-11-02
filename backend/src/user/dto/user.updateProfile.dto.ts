import {
  IsEmail,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
} from 'class-validator';

export class UserUpdateProfileDTO {
  @IsOptional()
  @IsNotEmpty()
  @IsString()
  userName?: string;

  @IsOptional()
  @IsNotEmpty()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsNotEmpty()
  @IsString()
  gender?: string;

  @IsOptional()
  @IsNotEmpty()
  @IsString()
  dob?: string;

  @IsOptional()
  @IsNumber()
  qoyodCustomerId?: number;
}
