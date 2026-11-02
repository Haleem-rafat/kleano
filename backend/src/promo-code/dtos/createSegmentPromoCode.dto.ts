import {
  IsEnum,
  IsMongoId,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { Types } from 'mongoose';
import { PromoCodeUsesTypeEnum } from '../schemas/promo-code.schema';

export class CreateSegmentPromoCodeDto {
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
  @IsMongoId()
  segment: Types.ObjectId;
}
