import { Type } from 'class-transformer';
import {
  IsArray,
  IsEnum,
  IsMongoId,
  IsNotEmpty,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { LocalizedText } from '../../common/types/localized-text.type';
import { ServiceIcon } from '../../services-icons/schemas/services-icons.schema';
import { ServiceType } from '../schemas/washing-services.schema';

export class UpdateWashingServiceDTO {
  @IsOptional()
  @IsObject()
  @ValidateNested()
  @Type(() => LocalizedText)
  name: LocalizedText;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => LocalizedText)
  description: LocalizedText[];

  @IsOptional()
  @IsNotEmpty()
  duration: number;

  @IsOptional()
  @IsNotEmpty()
  @IsString()
  durationUnit: string;

  @IsOptional()
  @IsNotEmpty()
  price: number;

  @IsOptional()
  @IsNotEmpty()
  @IsMongoId()
  icon: ServiceIcon;

  @IsOptional()
  @IsEnum(ServiceType)
  @IsNotEmpty()
  type?: ServiceType;

  @IsOptional()
  @IsNumber()
  qoyodProductId?: number;
}
