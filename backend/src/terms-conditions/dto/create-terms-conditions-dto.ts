import { Type } from 'class-transformer';
import { IsNotEmpty, IsObject, ValidateNested } from 'class-validator';
import { LocalizedText } from '../../common/types/localized-text.type';

export class CreateTermsAndConditionsDto {
  @IsNotEmpty()
  @IsObject()
  @ValidateNested()
  @Type(() => LocalizedText)
  content: LocalizedText;
}
