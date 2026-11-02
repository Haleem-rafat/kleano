import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { WashingService } from '../schemas/washing-services.schema';
import { City } from '../../city/schemas/city.schema';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';
import {
  ServicesCitiesModelName,
  ServiceCity,
} from '../schemas/services-cities.schema';

@Injectable()
export class ServicesCitiesRepository {
  constructor(
    @InjectModel(ServicesCitiesModelName)
    private readonly servicesCitiesModel: Model<ServiceCity>,
  ) {}

  async insertMany(washingService: WashingService, cities: City[]) {
    for (const city of cities) {
      await this.servicesCitiesModel.create({
        washingService: washingService,
        city: city,
      });
    }
  }

  async insertOne(washingService: WashingService, city: City) {
    if (await this.findOne(washingService, city))
      throw new MethodNotAllowedResponse({
        ar: 'الخدمة مسجلة من قبل في هذه المدينة',
        en: 'Washing Service is Already Exist in this city',
      });

    await this.servicesCitiesModel.create({
      washingService: washingService,
      city: city,
    });
  }
  async deleteOne(washingService: WashingService, city: City) {
    if (!(await this.findOne(washingService, city)))
      throw new MethodNotAllowedResponse({
        ar: 'الخدمة لاتوجد في هذه المدينة',
        en: 'Washing Service is not Exist in this city',
      });

    await this.servicesCitiesModel.deleteOne({
      washingService: washingService,
      city: city,
    });
  }

  async findOne(washingService: WashingService, city: City) {
    const isExist = await this.servicesCitiesModel.findOne({
      washingService: washingService,
      city: city,
    });
    return isExist;
  }

  async findByServicesId(servicesId: string) {
    return this.servicesCitiesModel.find({ servicesId });
  }

  async suspendServicesInCities(
    servicesId: string,
    suspendedAt: Date,
  ): Promise<void> {
    await this.servicesCitiesModel.updateMany(
      { washingService: servicesId },
      { suspendedAt },
    );
  }
}
