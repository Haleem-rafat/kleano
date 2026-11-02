import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { City, CityModel, cityModelName } from './schemas/city.schema';
import { Model } from 'mongoose';
import { AdminService } from '../admin/admin.service';
import { Admin, Roles } from '../admin/schemas/admin.schema';
import { MethodNotAllowedResponse } from '../common/errors/MethodNotAllowedResponse';
import { prePopulatedCities } from './seeders/city.seeder';

@Injectable()
export class CitiesService {
  constructor(
    @InjectModel(cityModelName) private readonly cityModel: Model<CityModel>,
    private adminService: AdminService,
  ) {}

  async seedDbWithCities() {
    const data = prePopulatedCities;
    for (const city of data) {
      await this.cityModel.create(city);
    }
  }

  async getCities() {
    return await this.cityModel.find({ isExist: true });
  }

  async getAdminCities(role: string, adminId?: string) {
    let admin: Admin;
    if (role === Roles.SubAdmin) {
      admin = await this.adminService.getById(adminId);
    }
    return await this.cityModel.find({
      isExist: true,
      ...(role === Roles.SuperAdmin ? {} : { _id: { $in: admin.city } }),
    });
  }

  async getArchivedCities(role: string, adminId?: string) {
    const admin = await this.adminService.getById(adminId);
    return await this.cityModel.find({
      isExist: false,
      ...(role === Roles.SuperAdmin ? {} : { _id: { $in: admin.city } }),
    });
  }

  async updateCityExistence(cityId: string, isExist: boolean) {
    await this.cityModel.updateOne(
      { _id: cityId },
      { $set: { isExist: isExist } },
    );
  }

  async checkCityExistence(city: City) {
    const cityExistence = await this.cityModel.findOne({
      _id: city,
      isExist: true,
    });
    if (!cityExistence)
      throw new MethodNotAllowedResponse({
        ar: 'هذه المدينة مغلقة',
        en: 'City is Archived',
      });
  }
}
