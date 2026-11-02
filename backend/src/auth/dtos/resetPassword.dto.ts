import { IsNotEmpty, IsPhoneNumber, IsString, Length } from 'class-validator';

export class ResetPasswordDTO {
  @IsNotEmpty()
  @IsString()
  @Length(8, 255)
  newPassword: string;

  @IsNotEmpty()
  @IsString()
  token: string;
}
