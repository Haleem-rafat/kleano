import { City } from '../../city/schemas/city.schema';
import {
  IsArray,
  IsMongoId,
  IsNotEmpty,
  IsPhoneNumber,
  IsString,
  Length,
} from 'class-validator';

export class UpdatePassword {
  @IsNotEmpty()
  @IsString()
  @Length(8, 255)
  password: string;
}
