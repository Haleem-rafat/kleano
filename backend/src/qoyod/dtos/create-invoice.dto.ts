import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsDateString,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';

export class LineItemDto {
  @IsOptional()
  @IsNumber()
  product_id?: number;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  quantity: number;

  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  unit_price: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  discount?: number;

  @IsOptional()
  @IsEnum(['percentage', 'amount'])
  discount_type?: 'percentage' | 'amount';

  @IsOptional()
  @IsNumber()
  @Min(0)
  tax_percent?: number;

  @IsOptional()
  @IsBoolean()
  is_inclusive?: boolean = true;
}

export class CreateInvoiceDto {
  @IsNotEmpty()
  @IsNumber()
  contact_id: number;

  @IsOptional()
  @IsString()
  reference?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsNotEmpty()
  @IsDateString()
  issue_date: string;

  @IsOptional()
  @IsDateString()
  due_date?: string;

  @IsOptional()
  @IsEnum(['Draft', 'Approved'])
  status?: 'Draft' | 'Approved';

  @IsNotEmpty()
  @IsNumber()
  inventory_id: number;

  @IsNotEmpty()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => LineItemDto)
  line_items: LineItemDto[];

  @IsOptional()
  @IsString()
  notes?: string;
}
