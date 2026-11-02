import { IsNotEmpty } from 'class-validator';

export class UserLogoutDTO {
  @IsNotEmpty()
  fcmToken: string;
}
