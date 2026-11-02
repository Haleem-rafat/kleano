import { Transform } from 'class-transformer';
import { IsNotEmpty, IsString, Min } from 'class-validator';

export class GetTotalAfterCodeDTO {
  @IsNotEmpty()
  @IsString()
  promoCode: string;

  @IsNotEmpty()
  @Min(0)
  @Transform(({ value }) => Number(value), { toClassOnly: true })
  totalPrice: number;
}
