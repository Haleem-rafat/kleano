import { City } from '../../city/schemas/city.schema';
import {
  IsArray,
  IsMongoId,
  IsNotEmpty,
  IsPhoneNumber,
  IsString,
  Length,
} from 'class-validator';

export class CreateSubAdminDTO {
  @IsNotEmpty()
  @IsString()
  userName: string;

  @IsNotEmpty()
  @IsPhoneNumber()
  phone: string;

  @IsNotEmpty()
  @IsString()
  @Length(8, 255)
  password: string;

  @IsNotEmpty()
  @IsString()
  nationalId: string;

  @IsNotEmpty()
  @IsArray()
  @IsMongoId({ each: true })
  city: City[];
}
