import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import {
  ExpressionLeftSideEnum,
  OperatorEnum,
} from '../schemas/aggregator-promo-code.schema';
import { PromoCodeUsesTypeEnum } from '../schemas/promo-code.schema';

export class CreateAggregatorPromoCodeDTO {
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
  @IsString()
  @IsEnum(ExpressionLeftSideEnum)
  expressionLeftSide: ExpressionLeftSideEnum;

  @IsNotEmpty()
  @IsString()
  @IsEnum(OperatorEnum)
  operator: OperatorEnum;

  @IsNotEmpty()
  @IsNumber()
  @Min(1)
  expressionRightSide: number;
}
