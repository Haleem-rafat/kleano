import {
  IsDateString,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class PayInvoiceDto {
  @IsNotEmpty()
  @IsString()
  invoice_id: string;

  @IsNotEmpty()
  @IsDateString()
  date: string;

  @IsNotEmpty()
  @IsNumber()
  @Min(0.01)
  amount: number;

  @IsNotEmpty()
  @IsString()
  reference: string;

  @IsNotEmpty()
  @IsString()
  account_id: string;
}
