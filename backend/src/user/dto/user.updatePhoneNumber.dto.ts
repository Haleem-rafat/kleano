import { IsNotEmpty, IsPhoneNumber } from 'class-validator';

export class UpdatePhoneNumberDTO {
  @IsNotEmpty()
  @IsPhoneNumber()
  phone: string;
}
