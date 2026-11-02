import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import mongoose, { Model } from 'mongoose';
import { Roles } from 'src/admin/schemas/admin.schema';
import { City } from '../../city/schemas/city.schema';
import { NotFoundResponse } from '../../common/errors/NotFoundResponse';
import { servicesIconModelName } from '../../services-icons/schemas/services-icons.schema';
import { CreateAddOnsDTO } from '../dtos/createAddOns.dto';
import { AddOnsModel, addOnsModelName } from '../schemas/add-ons.schema';

@Injectable()
export class AddOnsRepository {
  populatedPaths = [
    { path: 'icon', select: 'iconPath iconLink', model: servicesIconModelName },
  ];

  constructor(
    @InjectModel(addOnsModelName)
    private readonly addOnsModel: Model<AddOnsModel>,
  ) {}

  async create(createAddOnsDTO: CreateAddOnsDTO) {
    const createdAddOns = await this.addOnsModel.create({
      name: createAddOnsDTO.name,
      price: createAddOnsDTO.price,
      stock: createAddOnsDTO.stock,
      icon: createAddOnsDTO.icon,
    });

    return createdAddOns;
  }

  async findAll(city: City) {
    const addOnsList = await this.addOnsModel.aggregate([
      {
        $match: {
          stock: { $gt: 0 },
        },
      },
      {
        $lookup: {
          from: 'add-ons-cities',
          let: { addOnsId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ['$$addOnsId', '$addOns'] },
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
            { $project: { _id: 0, addOns: 0 } },

            { $unwind: '$city' },
          ],
          as: 'cities',
        },
      },
    ]);
    await this.addOnsModel.populate(addOnsList, this.populatedPaths);

    return addOnsList;
  }

  async findAllForAdmins(role: string, cities?: City[]) {
    const addOnses = await this.addOnsModel.aggregate([
      {
        $lookup: {
          from: 'add-ons-cities',
          let: { addOnsId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ['$$addOnsId', '$addOns'] },
                ...(role === Roles.SubAdmin ? { city: { $in: cities } } : {}),
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
            { $project: { _id: 0, addons: 0 } },

            { $unwind: '$city' },
          ],
          as: 'cities',
        },
      },
    ]);
    await this.addOnsModel.populate(addOnses, this.populatedPaths);

    return addOnses;
  }

  async findByIdOr404(id: string) {
    const addOns = await this.addOnsModel.aggregate([
      {
        $match: { _id: new mongoose.Types.ObjectId(id) },
      },
      {
        $lookup: {
          from: 'add-ons-cities',
          let: { addOnsId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: { $eq: ['$$addOnsId', '$addOns'] },
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
            { $project: { _id: 0, addOns: 0 } },

            { $unwind: '$city' },
          ],
          as: 'cities',
        },
      },
    ]);
    await this.addOnsModel.populate(addOns, this.populatedPaths);

    if (!addOns[0])
      throw new NotFoundResponse({
        ar: 'لا توجد',
        en: 'Not Found',
      });

    return addOns[0];
  }

  async update(id: string, updatedFields: any) {
    const addOnsIsExist = await this.addOnsModel.findById(id);
    if (!addOnsIsExist)
      throw new NotFoundResponse({
        ar: 'لا توجد',
        en: 'Not Found',
      });

    await this.addOnsModel.findByIdAndUpdate(id, { $set: updatedFields });
  }

  async getAddOnsReport() {
    return this.addOnsModel.aggregate([
      {
        $lookup: {
          from: 'orders',
          localField: '_id',
          foreignField: 'addOns',
          as: 'orderDetails',
        },
      },
      {
        $unwind: '$orderDetails',
      },
      {
        $group: {
          _id: '$_id',
          createdAt: { $first: '$createdAt' },
          name: { $first: '$name' },
          price: { $first: '$price' },
          icon: { $first: '$icon' },
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
    return await this.addOnsModel.find({
      $or: [{ qoyodProductId: null }, { qoyodProductId: { $exists: false } }],
    });
  }
}
