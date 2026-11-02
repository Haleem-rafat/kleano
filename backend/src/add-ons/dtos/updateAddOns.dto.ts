import { Type } from 'class-transformer';
import {
  IsMongoId,
  IsNotEmpty,
  IsNumber,
  IsObject,
  IsOptional,
  Min,
  ValidateNested,
} from 'class-validator';
import { LocalizedText } from '../../common/types/localized-text.type';
import { ServiceIcon } from '../../services-icons/schemas/services-icons.schema';

export class UpdateAddOnsDTO {
  @IsNotEmpty()
  @IsObject()
  @ValidateNested()
  @Type(() => LocalizedText)
  name: LocalizedText;

  @IsNotEmpty()
  price: number;

  @IsNotEmpty()
  @IsMongoId()
  icon: ServiceIcon;

  @IsOptional()
  @IsNumber()
  @Min(0)
  stock?: number;

  @IsOptional()
  @IsNumber()
  qoyodProductId?: number;
}
