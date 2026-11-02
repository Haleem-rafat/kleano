import { IsMongoId, IsNotEmpty } from 'class-validator';
import { City } from '../../city/schemas/city.schema';
import { AddOns } from '../schemas/add-ons.schema';

export class AddToNewCityDTO {
  @IsNotEmpty()
  @IsMongoId()
  addOns: AddOns;

  @IsNotEmpty()
  @IsMongoId()
  city: City;
}
