import { IsNotEmpty, IsString } from 'class-validator';

export class BikerLogoutDTO {
  @IsNotEmpty()
  @IsString()
  fcmToken: string;
}
