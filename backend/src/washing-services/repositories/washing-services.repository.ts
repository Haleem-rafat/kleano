import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import mongoose, { Model } from 'mongoose';
import { Roles } from 'src/admin/schemas/admin.schema';
import { City } from '../../city/schemas/city.schema';
import { NotFoundResponse } from '../../common/errors/NotFoundResponse';
import { servicesIconModelName } from '../../services-icons/schemas/services-icons.schema';
import { UpdateWashingServiceDTO } from '../dtos';
import { CreateWashingServiceDTO } from '../dtos/createWashingService.dto';
import {
  ServiceType,
  WashingServicesModel,
  WashingServicesModelName,
} from '../schemas/washing-services.schema';

@Injectable()
export class WashingServicesRepository {
  populatedPaths = [
    { path: 'icon', select: 'iconPath iconLink', model: servicesIconModelName },
  ];

  constructor(
    @InjectModel(WashingServicesModelName)
    private readonly washingServicesModel: Model<WashingServicesModel>,
  ) {}

  async create(createWashingServiceDTO: CreateWashingServiceDTO) {
    // CreateService
    const createdWashingService = await this.washingServicesModel.create({
      name: createWashingServiceDTO.name,
      description: createWashingServiceDTO.description,
      duration: createWashingServiceDTO.duration,
      durationUnit: createWashingServiceDTO.durationUnit,
      price: createWashingServiceDTO.price,
      icon: createWashingServiceDTO.icon,
      type: createWashingServiceDTO.type,
    });

    return createdWashingService;
  }

  async findAll(city: City, type: string) {
    const washingServices = await this.washingServicesModel.aggregate([
      {
        $match: {
          ...(type && type === ServiceType.MAIN && { type: ServiceType.MAIN }),
          ...(type &&
            type === ServiceType.EXTRA && { type: ServiceType.EXTRA }),
        },
      },
      {
        $lookup: {
          from: 'services-cities',
          let: { washingServiceId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ['$$washingServiceId', '$washingService'] },
                isArchived: false,
                suspendedAt: null,
                city: city,
              },
            },
            {
              $lookup: {
                from: 'cities',
                let: { cityId: '$city' },
                pipeline: [
                  {
                    $match: {
                      $expr: { $eq: ['$$cityId', '$_id'] },
                    },
                  },
                ],
                as: 'city',
              },
            },
            { $project: { _id: 0, washingService: 0 } },

            { $unwind: '$city' },
          ],
          as: 'cities',
        },
      },
    ]);
    await this.washingServicesModel.populate(
      washingServices,
      this.populatedPaths,
    );

    return washingServices;
  }

  async findAllForAdmins(role: string, city?: City[]) {
    const washingServices = await this.washingServicesModel.aggregate([
      {
        $lookup: {
          from: 'services-cities',
          let: { washingServiceId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ['$$washingServiceId', '$washingService'] },
                ...(role === Roles.SubAdmin ? { city: { $in: city } } : {}),
              },
            },
            {
              $lookup: {
                from: 'cities',
                let: { cityId: '$city' },
                pipeline: [
                  {
                    $match: {
                      $expr: { $eq: ['$$cityId', '$_id'] },
                    },
                  },
                ],
                as: 'city',
              },
            },
            { $project: { _id: 0, washingService: 0 } },

            { $unwind: '$city' },
          ],
          as: 'cities',
        },
      },
    ]);
    await this.washingServicesModel.populate(
      washingServices,
      this.populatedPaths,
    );

    return washingServices;
  }

  async findOneByIdOr404(id: string) {
    const washingService = await this.washingServicesModel.aggregate([
      {
        $match: { _id: new mongoose.Types.ObjectId(id) },
      },
      {
        $lookup: {
          from: 'services-cities',
          let: { washingServiceId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ['$$washingServiceId', '$washingService'] },
              },
            },
            {
              $lookup: {
                from: 'cities',
                let: { cityId: '$city' },
                pipeline: [
                  {
                    $match: {
                      $expr: { $eq: ['$$cityId', '$_id'] },
                    },
                  },
                ],
                as: 'city',
              },
            },
            { $project: { _id: 0, washingService: 0 } },

            { $unwind: '$city' },
          ],
          as: 'cities',
        },
      },
    ]);
    await this.washingServicesModel.populate(
      washingService,
      this.populatedPaths,
    );

    return washingService[0];
  }

  async update(
    id: string,
    updateWashingServiceDTO: UpdateWashingServiceDTO | any,
  ) {
    // TODO:
    await this.washingServicesModel.findByIdAndUpdate(id, {
      $set: updateWashingServiceDTO,
    });

    return this.findOneOr404(id);
  }

  async findOneOr404(id: string) {
    const washingService = await this.washingServicesModel.findById(id);
    if (!washingService)
      throw new NotFoundResponse({
        ar: 'لاتوجد هذه الخدمة',
        en: 'Washing Service Not Found',
      });

    return washingService;
  }
  async findOrderWashingServices(washingServices: any[]) {
    return await this.washingServicesModel.find({
      _id: { $in: washingServices },
    });
  }

  async getServicesReport() {
    return this.washingServicesModel.aggregate([
      {
        $lookup: {
          from: 'orders',
          localField: '_id',
          foreignField: 'washingServices',
          as: 'orderDetails',
        },
      },
      {
        $unwind: '$orderDetails',
      },
      {
        $group: {
          _id: '$_id',
          name: { $first: '$name' },
          description: { $first: '$description' },
          duration: { $first: '$duration' },
          durationUnit: { $first: '$durationUnit' },
          price: { $first: '$price' },
          icon: { $first: '$icon' },
          createdAt: { $first: '$createdAt' },
          updatedAt: { $first: '$updatedAt' },
          totalBooked: { $sum: 1 },
          totalRevenue: { $sum: '$price' },
        },
      },
      {
        $sort: { totalBooked: -1 },
      },
      {
        $project: {
          _id: 1,
          name: 1,
          description: 1,
          duration: 1,
          durationUnit: 1,
          price: 1,
          icon: 1,
          totalBooked: 1,
          totalRevenue: 1,
          createdAt: 1,
          updatedAt: 1,
        },
      },
    ]);
  }

  async findAllWithoutQoyodProduct() {
    return await this.washingServicesModel.find({
      $or: [{ qoyodProductId: null }, { qoyodProductId: { $exists: false } }],
    });
  }
}
