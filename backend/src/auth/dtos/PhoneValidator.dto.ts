import { IsNotEmpty, IsPhoneNumber } from 'class-validator';

export class PhoneNumberDTO {
  @IsNotEmpty()
  @IsPhoneNumber()
  phone: string;
}
