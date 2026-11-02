import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { NearestAreaType } from './interfaces/nearest-area-type';
import { AreaModel, areaModelName } from './schemas/area.schema';
@Injectable()
export class NearestAreaCalculator {
  constructor(
    @InjectModel(areaModelName) private readonly areaModel: Model<AreaModel>,
  ) {}

  async findAreaByPoint(latitude: number, longitude: number) {
    return await this.areaModel
      .findOne({
        boundary: {
          $geoIntersects: {
            $geometry: { type: 'Point', coordinates: [longitude, latitude] },
          },
        },
      })
      .select('-boundary')
      .populate('city')
      .lean();
  }

  async findNearestArea(latitude: number, longitude: number) {
    const areas = await this.areaModel.find();
    const distances: NearestAreaType[] = [];
    for (const area of areas) {
      distances.push({
        area: area,
        distance: this.calculateDistanceFromTo(
          latitude,
          longitude,
          area.latitude,
          area.longitude,
        ),
      });
    }

    const closestArea = distances.reduce((acc, loc) =>
      acc.distance < loc.distance ? acc : loc,
    );

    return closestArea;
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
}
