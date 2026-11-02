import { Type } from 'class-transformer';
import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { ValidWithin } from '../schemas/new-comers-promo-code.schema';
import { PromoCodeUsesTypeEnum } from '../schemas/promo-code.schema';

export class CreateNewComersPromoCodeDTO {
  @IsNotEmpty()
  @IsString()
  code: string;

  @IsOptional()
  @IsNumber()
  duration?: number;

  @IsNotEmpty()
  @IsNumber()
  @Min(1)
  numberOfUses: number;

  @IsNotEmpty()
  @IsString()
  @IsEnum(PromoCodeUsesTypeEnum)
  usesType: PromoCodeUsesTypeEnum;

  @IsNumber()
  @Min(0)
  @IsOptional()
  userLimit?: number;

  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  discountPercentage?: number;

  @IsNotEmpty()
  @IsNumber()
  @Min(0)
  @IsOptional()
  discountFixedNumber?: number;

  @IsNotEmpty()
  @IsObject()
  @ValidateNested()
  @Type(() => ValidWithin)
  validWithin: ValidWithin;
}
