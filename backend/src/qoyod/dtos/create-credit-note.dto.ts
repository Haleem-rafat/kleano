import { Type } from 'class-transformer';
import {
  IsArray,
  IsDateString,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';

/** Matches Qoyod credit_notes line_items (POST /credit_notes). */
export class CreditNoteLineItemDto {
  @IsNotEmpty()
  @IsNumber()
  product_id: number;

  @IsOptional()
  @IsString()
  description?: string;

  /** Line unit price before line discount (numbers accepted; serialized for API where needed). */
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  unit_price: number;

  @IsNotEmpty()
  @IsNumber()
  @Min(0.0001)
  quantity: number;

  /** When set with discount_type `amount`, pass line discount in SAR here */
  @IsOptional()
  @IsNumber()
  @Min(0)
  discount?: number;

  /** Defaults to percentage in API; use `amount` when passing `discount`. */
  @IsOptional()
  @IsEnum(['percentage', 'amount'])
  discount_type?: 'percentage' | 'amount';

  @IsOptional()
  @IsNumber()
  @Min(0)
  discount_percent?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  tax_percent?: number;

  @IsOptional()
  @IsNumber()
  unit_type?: number;

  /** Custom fields config in Qoyod UI */
  @IsOptional()
  custom_fields?: Array<Record<string, unknown>>;
}

/**
 * POST /credit_notes — contact_id is the customer in Qoyod (maps to User.qoyodCustomerId).
 * @see https://apidoc.qoyod.com/ — Credit Notes
 */
export class CreateCreditNoteDto {
  /** Qoyod customer id (same as `qoyodCustomerId` on User). Required. */
  @IsNotEmpty()
  @IsNumber()
  contact_id: number;

  @IsOptional()
  @IsString()
  reference?: string;

  @IsNotEmpty()
  @IsDateString()
  issue_date: string;

  @IsOptional()
  @IsEnum(['Draft', 'Approved'])
  status?: 'Draft' | 'Approved';

  @IsNotEmpty()
  @IsNumber()
  inventory_id: number;

  @IsNotEmpty()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreditNoteLineItemDto)
  line_items: CreditNoteLineItemDto[];

  @IsOptional()
  @IsString()
  terms_conditions?: string;

  @IsOptional()
  @IsString()
  notes?: string;
}
