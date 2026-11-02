import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { City } from '../city/schemas/city.schema';
import { UpdateUserLocation } from './dto';
import { UserModel, userModelName } from './schemas/user.schema';

@Injectable()
export class UserQueriesHelper {
  constructor(
    @InjectModel(userModelName) private readonly userModel: Model<UserModel>,
  ) {}

  async updateUserLocation(
    id: string,
    updateUserLocation: UpdateUserLocation,
    nearestCity: City,
  ) {
    await this.userModel.findByIdAndUpdate(id, {
      'location.latitude': Number(updateUserLocation.latitude),
      'location.longitude': Number(updateUserLocation.longitude),
      'location.streetName': updateUserLocation.streetName,
      'location.subAdministrativeArea':
        updateUserLocation.subAdministrativeArea,
      'location.country': updateUserLocation.country,
      'location.city': nearestCity,
    });
  }
}
