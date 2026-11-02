import {
  IsEnum,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';
import { PromoCodeStatus } from '../schemas/promo-code.schema';

export enum IsGraphViewEnum {
  TRUE = 'true',
  FALSE = 'false',
}

export class GetPromoCodesDTO {
  @IsNotEmpty()
  @IsIn([
    PromoCodeStatus.ACTIVE,
    PromoCodeStatus.EXPIRED,
    PromoCodeStatus.DISABLED,
  ])
  @IsOptional()
  status?: string;

  @IsOptional()
  targetAudience?: string;

  @IsOptional()
  business?: string;

  @IsOptional()
  page?: string;

  @IsOptional()
  perPage?: string;

  @IsOptional()
  fromDate?: Date;

  @IsOptional()
  toDate?: Date;

  @IsOptional()
  segment?: string;

  @IsOptional()
  city?: string;

  @IsEnum(IsGraphViewEnum)
  isGraphView: IsGraphViewEnum;

  @IsString()
  @IsOptional()
  promoCodeId?: string;
}
