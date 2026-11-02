import { IsOptional, Matches } from 'class-validator';

export class GetSubscriptionByLocationDTO {
  @Matches(/(-\d+\.\d\d\d\d\d+|\d+.\d\d\d\d\d+)/i, {
    message: 'Latitude must be in the format X.dddddd+',
  })
  latitude: string;

  @Matches(/(-\d+\.\d\d\d\d\d+|\d+.\d\d\d\d\d+)/i, {
    message: 'Longitude must be in the format X.dddddd+',
  })
  longitude: string;

  @IsOptional()
  country: string;
}
