import { IsNotEmpty, IsString, Length } from 'class-validator';

export class AdminLoginDTO {
  @IsNotEmpty()
  @IsString()
  userName: string;

  @IsNotEmpty()
  @IsString()
  @Length(8, 255)
  password: string;
}
