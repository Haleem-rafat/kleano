import { IsNotEmpty, IsString, Length } from 'class-validator';

export class BikerLoginDTO {
  @IsNotEmpty()
  @IsString()
  userName: string;

  @IsNotEmpty()
  @IsString()
  @Length(8, 255)
  password: string;

  @IsNotEmpty()
  @IsString()
  fcmToken: string;
}
