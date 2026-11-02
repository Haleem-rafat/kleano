import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsEmail,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  ValidateNested,
} from 'class-validator';
import { LocalizedText } from '../../common/types/localized-text.type';

export enum TamaraSupportedCurrency {
  SAR = 'SAR',
}

export class AmountDto {
  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  amount: number;

  @IsNotEmpty()
  @IsEnum(TamaraSupportedCurrency)
  currency: TamaraSupportedCurrency;
}

export class DiscountDto {
  @IsNotEmpty()
  @IsString()
  name: string;

  @IsNotEmpty()
  @ValidateNested()
  @Type(() => AmountDto)
  amount: AmountDto;
}

export class ConsumerDto {
  @IsOptional()
  @IsEmail()
  email?: string;

  @IsNotEmpty()
  @IsString()
  first_name: string;

  @IsNotEmpty()
  @IsString()
  last_name: string;

  @IsNotEmpty()
  @IsString()
  phone_number: string;
}

export class ItemDto {
  @IsNotEmpty()
  @IsObject()
  @ValidateNested()
  @Type(() => LocalizedText)
  name: LocalizedText;

  @IsNotEmpty()
  @IsNumber()
  @Min(1)
  quantity: number;

  @IsNotEmpty()
  @IsString()
  reference_id: string;

  @IsNotEmpty()
  @IsEnum(['Digital', 'Physical'])
  type: 'Digital' | 'Physical';

  @IsNotEmpty()
  @IsString()
  sku: string;

  @IsOptional()
  @IsNotEmpty()
  @ValidateNested()
  @Type(() => AmountDto)
  unit_price?: AmountDto;

  @IsOptional()
  @IsNotEmpty()
  @ValidateNested()
  @Type(() => AmountDto)
  tax_amount?: AmountDto;

  @IsOptional()
  @IsNotEmpty()
  @ValidateNested()
  @Type(() => AmountDto)
  discount_amount?: AmountDto;

  @IsNotEmpty()
  @ValidateNested()
  @Type(() => AmountDto)
  total_amount: AmountDto;
}

export class MerchantUrlDto {
  @IsNotEmpty()
  @IsString()
  cancel: string;

  @IsNotEmpty()
  @IsString()
  failure: string;

  @IsNotEmpty()
  @IsString()
  success: string;
}

export class ShippingAddressDto {
  @IsNotEmpty()
  @IsString()
  city: string;

  @IsNotEmpty()
  @IsString()
  @IsEnum(['SA'])
  country_code: 'SA';

  @IsNotEmpty()
  @IsString()
  first_name: string;

  @IsNotEmpty()
  @IsString()
  last_name: string;

  @IsNotEmpty()
  @IsString()
  line1: string;
}

export class CreateCheckoutSessionDto {
  @IsNotEmpty()
  @ValidateNested()
  @Type(() => AmountDto)
  total_amount: AmountDto;

  @IsNotEmpty()
  @ValidateNested()
  @Type(() => AmountDto)
  shipping_amount: AmountDto;

  @IsNotEmpty()
  @ValidateNested()
  @Type(() => AmountDto)
  tax_amount: AmountDto;

  @IsNotEmpty()
  @IsString()
  order_reference_id: string;

  @IsOptional()
  @IsNotEmpty()
  @ValidateNested()
  @Type(() => DiscountDto)
  discount?: DiscountDto;

  @IsNotEmpty()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ItemDto)
  items: ItemDto[];

  @IsNotEmpty()
  @ValidateNested()
  @Type(() => ConsumerDto)
  consumer: ConsumerDto;

  @IsNotEmpty()
  @IsString()
  @IsEnum(['SA'])
  country_code: 'SA';

  @IsNotEmpty()
  @IsString()
  @MaxLength(100)
  description: string;

  @IsNotEmpty()
  @ValidateNested()
  @Type(() => MerchantUrlDto)
  merchant_url: MerchantUrlDto;

  @IsNotEmpty()
  @ValidateNested()
  @Type(() => ShippingAddressDto)
  shipping_address: ShippingAddressDto;

  @IsNotEmpty()
  @IsBoolean()
  is_mobile: boolean;
}
