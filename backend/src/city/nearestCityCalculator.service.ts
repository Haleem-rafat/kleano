import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CityModel, cityModelName } from './schemas/city.schema';

@Injectable()
export class NearestCityCalculator {
  constructor(
    @InjectModel(cityModelName) private readonly cityModel: Model<CityModel>,
  ) {}

  async findNearestCity(latitude: number, longitude: number) {
    const cities = await this.cityModel.find();
    const distances = [];
    for (const city of cities) {
      distances.push({
        city: city,
        distance: this.calculateDistanceFromTo(
          latitude,
          longitude,
          city.latitude,
          city.longitude,
        ),
      });
    }

    const closest = distances.reduce((acc, loc) =>
      acc.distance < loc.distance ? acc : loc,
    );

    return closest;
  }

  calculateDistanceFromTo(
    fromLatitude: number,
    fromLongitude: number,
    toLatitude: number,
    toLongitude: number,
  ) {
    const R = 6371; // km
    const dLat = this.toRad(toLatitude - fromLatitude);
    const dLon = this.toRad(toLongitude - fromLongitude);
    const lat1 = this.toRad(fromLatitude);
    const lat2 = this.toRad(toLatitude);

    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.sin(dLon / 2) * Math.sin(dLon / 2) * Math.cos(lat1) * Math.cos(lat2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const d = R * c;
    return d ? Number(d.toFixed(1)) : 0;
  }

  toRad(value: number) {
    return (value * Math.PI) / 180;
  }

  // isWithinKSA(latitude: number, longitude: number): boolean {
  //   return (
  //     latitude >= 16.0 &&
  //     latitude <= 32.0 &&
  //     longitude >= 34.0 &&
  //     longitude <= 55.0
  //   );
  // }
}
