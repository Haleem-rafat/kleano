import { IsMongoId, IsNotEmpty } from 'class-validator';
import { Plan } from '../schemas/plans.schema';
import { City } from '../../city/schemas/city.schema';

export class UpdatePlanCitiesDTO {
  @IsNotEmpty()
  @IsMongoId()
  plan: Plan;

  @IsNotEmpty()
  @IsMongoId()
  city: City;
}
