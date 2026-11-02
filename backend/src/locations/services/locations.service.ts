import { Injectable } from '@nestjs/common';
import { NearestAreaCalculator } from 'src/area/nearestAreaCalculator.service';
import { Area } from 'src/area/schemas/area.schema';
import { NearestCityCalculator } from '../../city/nearestCityCalculator.service';
import { City } from '../../city/schemas/city.schema';
import { User } from '../../user/schemas/user.schema';
import { LocationsRepository } from '../repositories/locations.repository';

@Injectable()
export class LocationsService {
  constructor(
    private locationsRepository: LocationsRepository,
    private nearestCityCalculator: NearestCityCalculator,
    private nearestAreaCalculator: NearestAreaCalculator,
  ) {}

  async createOrderLocationOrGetIt(
    user: User,
    location: {
      latitude: number;
      longitude: number;
      streetName: string;
      subAdministrativeArea: string;
      country: string;
    },
  ) {
    const isLocationExists = await this.locationsRepository.findOne(
      user,
      location.latitude,
      location.longitude,
    );

    if (isLocationExists) return isLocationExists;

    // Get The City Of location
    const city = await this.nearestCityCalculator.findNearestCity(
      location.latitude,
      location.longitude,
    );

    // Get The area Of location
    const area = await this.nearestAreaCalculator.findNearestArea(
      location.latitude,
      location.longitude,
    );

    return await this.locationsRepository.create(
      user,
      city['city']._id,
      area.area._id,
      location,
      false,
    );
  }

  async getSavedLocations(user: User) {
    return await this.locationsRepository.findAll(user, true);
  }

  async getRecentLocations(user: User) {
    return await this.locationsRepository.findAll(user, false);
  }

  async getLocationById(id: any) {
    return await this.locationsRepository.findById(id);
  }

  async saveCurrentLocation(id: string, savedName: string) {
    const currentLocation = await this.locationsRepository.findById(id);
    currentLocation.isSaved = true;
    currentLocation.savedName = savedName;

    await currentLocation.save();

    return currentLocation;
  }

  async unSaveAllLocations(user: User) {
    await this.locationsRepository.updateLocations(user);
  }

  async unSaveLocation(id: string) {
    await this.locationsRepository.updateOne(id);
  }

  async saveNewLocation(
    user: User,
    location: {
      latitude: number;
      longitude: number;
      streetName: string;
      subAdministrativeArea: string;
      country: string;
    },
    savedName: string,
  ) {
    // const isNewLocationExists = await this.locationsRepository.findOne(
    //   user,
    //   location.latitude,
    //   location.longitude,
    // );

    // if (isNewLocationExists) {
    //   isNewLocationExists.isSaved = true;
    //   isNewLocationExists.savedName = savedName;

    //   await isNewLocationExists.save();

    //   return isNewLocationExists;
    // }

    // Get The City Of location
    const city = await this.nearestCityCalculator.findNearestCity(
      location.latitude,
      location.longitude,
    );

    // Get The area Of location
    const area = await this.nearestAreaCalculator.findAreaByPoint(
      location.latitude,
      location.longitude,
    );

    const newLocation = await this.locationsRepository.create(
      user,
      city['city']._id,
      area._id,
      location,
      true,
    );

    const userHasLocations = await this.locationsRepository.findAll(user, true);

    newLocation.isDefault = userHasLocations.length === 0 ? true : false;
    newLocation.isSaved = true;
    newLocation.savedName = savedName;
    await newLocation.save();

    return newLocation;
  }

  async getAllLocationsInCity(city: City) {
    return await this.locationsRepository.findManyQuery({
      city: city,
    });
  }

  async getAllLocationsInBikerAreas(areas: Area[]) {
    return await this.locationsRepository.findManyQuery({
      area: { $in: areas },
    });
  }

  async markAsDefault(user: User, id: string) {
    await this.locationsRepository.markAsDefault(user, id);
  }
}
