import { IsNotEmpty, IsNumber, Min } from 'class-validator';

export class WalletTopUpDto {
  @IsNotEmpty()
  @IsNumber()
  @Min(1, { message: 'Amount must be at least 1 SAR' })
  amount: number;
}
