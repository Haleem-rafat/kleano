import { IsNotEmpty, IsOptional, IsString, Matches } from 'class-validator';

export class UpdateUserLocation {
  @Matches(/(-\d+\.\d\d\d\d\d+|\d+.\d\d\d\d\d+)/i, {
    message: 'Latitude must be in the format X.dddddd+',
  })
  latitude: string;

  @Matches(/(-\d+\.\d\d\d\d\d+|\d+.\d\d\d\d\d+)/i, {
    message: 'Longitude must be in the format X.dddddd+',
  })
  longitude: string;

  @IsNotEmpty()
  @IsString()
  streetName: string;

  @IsOptional()
  @IsString()
  subAdministrativeArea: string;

  @IsNotEmpty()
  @IsString()
  country: string;
}
