import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsMongoId,
  IsNotEmpty,
  IsNumber,
  IsObject,
  IsOptional,
  Min,
  ValidateNested,
} from 'class-validator';
import { City } from '../../city/schemas/city.schema';
import { LocalizedText } from '../../common/types/localized-text.type';
import { ServiceIcon } from '../../services-icons/schemas/services-icons.schema';

export class CreateAddOnsDTO {
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

  @IsNotEmpty()
  @IsBoolean()
  selectAll: boolean;

  @IsOptional()
  @IsArray()
  @IsMongoId({ each: true })
  cities?: City[];

  @IsNumber()
  @Min(0)
  stock: number;
}
