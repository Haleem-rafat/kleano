import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { City } from '../../city/schemas/city.schema';
import { User } from '../../user/schemas/user.schema';
import { locationModelName, LocationsModel } from '../schemas/location.schema';

@Injectable()
export class LocationsRepository {
  constructor(
    @InjectModel(locationModelName)
    private readonly locationsModel: Model<LocationsModel>,
  ) {}

  /**
   * Create new Location and return it
   */
  async create(
    user: User,
    city: City,
    area: Types.ObjectId,
    location: {
      latitude: number;
      longitude: number;
      streetName: string;
      subAdministrativeArea: string;
      country: string;
    },
    forSave: boolean,
  ) {
    return await this.locationsModel.create({
      latitude: location.latitude,
      longitude: location.longitude,
      streetName: location.streetName,
      subAdministrativeArea: location.subAdministrativeArea,
      city: city,
      area,
      country: location.country,
      user: user,
      ...(forSave ? { type: 'SAVED_LOCATION' } : { type: 'RECENT_LOCATION' }),
    });
  }

  async findAll(user: User, isSaved: boolean) {
    // TODO
    return await this.locationsModel
      .find({
        user: user,
        ...(isSaved
          ? { isSaved: true }
          : { isSaved: false, type: 'RECENT_LOCATION' }),
      })
      .sort({ createdAt: 'desc' });
  }

  async findById(id: any) {
    // TODO

    return await this.locationsModel.findById(id);
  }
  /**
   *
   * @param latitude
   * @param longitude
   * @param streetName
   *
   *
   */
  async findOne(user: User, latitude: number, longitude: number) {
    // TODO

    return await this.locationsModel.findOne({
      user: user,
      latitude: latitude,
      longitude: longitude,
    });
  }

  async updateLocations(user: User) {
    await this.locationsModel.updateMany(
      {
        user: user,
      },
      { $set: { isSaved: false }, $unset: { savedName: '' } },
    );
  }

  async updateOne(id: string) {
    await this.locationsModel.updateOne(
      {
        _id: id,
      },
      { $set: { isSaved: false }, $unset: { savedName: '' } },
    );
  }

  async findManyQuery(queryFilter: any) {
    return await this.locationsModel.find(queryFilter);
  }

  async markAsDefault(user: User, id: string) {
    await this.locationsModel.updateOne(
      { user: user, _id: id },
      { $set: { isDefault: true } },
    );

    await this.locationsModel.updateMany(
      { user: user, _id: { $ne: id } },
      { $set: { isDefault: false } },
    );
  }
}
