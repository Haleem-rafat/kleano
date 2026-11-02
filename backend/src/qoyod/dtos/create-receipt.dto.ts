import {
  IsDateString,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class CreateReceiptDto {
  @IsNotEmpty()
  @IsNumber()
  contact: number;

  @IsOptional()
  @IsString()
  reference?: string;

  @IsNotEmpty()
  @IsEnum(['received', 'paid'])
  kind: 'received' | 'paid';

  @IsNotEmpty()
  @IsNumber()
  account_id: number;

  @IsNotEmpty()
  @IsNumber()
  @Min(0.01)
  amount: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNotEmpty()
  @IsDateString()
  date: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
