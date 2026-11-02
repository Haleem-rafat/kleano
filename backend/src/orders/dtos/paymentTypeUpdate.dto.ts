import { IsMongoId, IsNotEmpty } from 'class-validator';
export class PaymentTypeUpdateDTO {
  @IsNotEmpty()
  @IsMongoId()
  order: string;

  @IsNotEmpty()
  paymentType: string;
}
