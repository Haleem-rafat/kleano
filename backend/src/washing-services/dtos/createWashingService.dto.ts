import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsEnum,
  IsMongoId,
  IsNotEmpty,
  IsObject,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { City } from '../../city/schemas/city.schema';
import { LocalizedText } from '../../common/types/localized-text.type';
import { ServiceIcon } from '../../services-icons/schemas/services-icons.schema';
import { ServiceType } from '../schemas/washing-services.schema';

export class CreateWashingServiceDTO {
  @IsNotEmpty()
  @IsObject()
  @ValidateNested()
  @Type(() => LocalizedText)
  name: LocalizedText;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => LocalizedText)
  description: LocalizedText[];

  @IsNotEmpty()
  duration: number;

  @IsNotEmpty()
  @IsString()
  durationUnit: string;

  @IsNotEmpty()
  price: number;

  @IsNotEmpty()
  @IsMongoId()
  icon: ServiceIcon;

  @IsString()
  @IsNotEmpty()
  @IsEnum(ServiceType)
  type: ServiceType;

  @IsNotEmpty()
  @IsBoolean()
  selectAll: boolean;

  @IsOptional()
  @IsArray()
  @IsMongoId({ each: true })
  cities?: City[];
}
