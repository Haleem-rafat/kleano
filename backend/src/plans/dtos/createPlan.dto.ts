import { Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
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
import { WashingService } from '../../washing-services/schemas/washing-services.schema';
export class CreatePlanDTO {
  @IsNotEmpty()
  @IsObject()
  @ValidateNested()
  @Type(() => LocalizedText)
  type: LocalizedText;

  @IsNotEmpty()
  @IsString()
  color: string;

  @IsNotEmpty()
  price: number;

  @IsNotEmpty()
  duration: number;

  @IsNotEmpty()
  @IsString()
  durationUnit: string;

  @IsNotEmpty()
  @IsArray()
  @IsMongoId({ each: true })
  washingServices: WashingService[];

  @IsNotEmpty()
  usageCount: number;

  @IsNotEmpty()
  @IsBoolean()
  selectAll: boolean;

  @IsOptional()
  @IsArray()
  @IsMongoId({ each: true })
  cities?: City[];

  @IsOptional()
  @IsNotEmpty()
  @IsMongoId()
  icon?: ServiceIcon;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => LocalizedText)
  description?: LocalizedText[];
}
