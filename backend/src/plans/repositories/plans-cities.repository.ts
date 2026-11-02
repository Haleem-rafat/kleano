import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { City } from '../../city/schemas/city.schema';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';
import { plansCitiesModelName, PlanCity } from '../schemas/plans-cities.schema';
import { Plan } from '../schemas/plans.schema';

@Injectable()
export class PlansCitiesRepository {
  constructor(
    @InjectModel(plansCitiesModelName)
    private readonly plansCitiesModel: Model<PlanCity>,
  ) {}

  async insertMany(plan: Plan, cities: City[]) {
    for (const city of cities) {
      await this.plansCitiesModel.create({
        plan: plan,
        city: city,
      });
    }
  }

  async insertOne(plan: Plan, city: City) {
    if (await this.findOne(plan, city))
      throw new MethodNotAllowedResponse({
        ar: 'الباقة مسجلة من قبل في هذه المدينة',
        en: 'Plan is Already Exist in this city',
      });

    await this.plansCitiesModel.create({
      plan: plan,
      city: city,
    });
  }
  async deleteOne(plan: Plan, city: City) {
    if (!(await this.findOne(plan, city)))
      throw new MethodNotAllowedResponse({
        ar: 'الباقة لاتوجد في هذه المدينة',
        en: 'Plan is not Exist in this city',
      });

    await this.plansCitiesModel.deleteOne({
      plan: plan,
      city: city,
    });
  }

  async findOne(plan: Plan, city: City) {
    const isExist = await this.plansCitiesModel.findOne({
      plan: plan,
      city: city,
    });
    return isExist;
  }
}
