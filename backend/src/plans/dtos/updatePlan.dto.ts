import { Type } from 'class-transformer';
import {
  IsArray,
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
import { WashingService } from '../../washing-services/schemas/washing-services.schema';
export class UpdatePlanDTO {
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

  @IsOptional()
  @IsNotEmpty()
  @IsMongoId()
  icon?: ServiceIcon;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => LocalizedText)
  description?: LocalizedText[];

  @IsOptional()
  @IsNumber()
  qoyodProductId?: number;
}
