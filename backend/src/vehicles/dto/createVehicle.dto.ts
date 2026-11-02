import { IsIn, IsNotEmpty, IsString } from 'class-validator';

export class CreateVehicleDTO {
  // @IsNotEmpty()
  // @IsIn(['Sedan', 'Hatchback', 'SUV', 'Van', 'Sport Car'])
  // type: string;

  @IsNotEmpty()
  @IsString()
  brand: string;

  @IsNotEmpty()
  @IsString()
  model: string;

  @IsNotEmpty()
  @IsString()
  plateNumber: string;

  @IsNotEmpty()
  @IsString()
  color: string;
}
