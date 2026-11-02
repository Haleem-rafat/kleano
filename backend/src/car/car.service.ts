import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Car, CarModel, carModelName } from './schemas/car.schema';
import { Model, Types } from 'mongoose';
import { prePopulatedCars } from './seeders/car.seeder';

@Injectable()
export class CarsService {
  constructor(
    @InjectModel(carModelName) private readonly carModel: Model<CarModel>,
  ) {}

  // async seedDbWithCarModels() {
  //   const data = prePopulatedCars;
  //   for (const carModel of data) {
  //     await this.carModel.create(carModel);
  //   }
  // }

  async getAllCarBrands() {
    const brands: Car[] = await this.carModel.aggregate([
      {
        $project: {
          _id: 1,
          brand: 1,
        },
      },
    ]);
    return brands;
  }

  async getAllCarModelsByBrandId(brandId: string) {
    const [models] = await this.carModel.aggregate([
      {
        $match: {
          _id: new Types.ObjectId(brandId),
        },
      },
      {
        $project: {
          _id: 1,
          models: 1,
        },
      },
    ]);

    return models;
  }
}
