import { City } from '../../city/schemas/city.schema';
import {
  IsArray,
  IsMongoId,
  IsNotEmpty,
  IsPhoneNumber,
  IsString,
} from 'class-validator';

export class UpdateAdminDTO {
  @IsNotEmpty()
  @IsPhoneNumber()
  phone: string;

  @IsNotEmpty()
  @IsString()
  nationalId: string;

  @IsNotEmpty()
  @IsArray()
  @IsMongoId({ each: true })
  city: City[];
}
