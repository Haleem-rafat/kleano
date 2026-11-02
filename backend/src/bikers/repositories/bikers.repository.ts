import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { areaModelName } from 'src/area/schemas/area.schema';
import { OrderStatus } from 'src/orders/schemas/orders.schema';
import { adminModelName } from '../../admin/schemas/admin.schema';
import { City, cityModelName } from '../../city/schemas/city.schema';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';
import { NotFoundResponse } from '../../common/errors/NotFoundResponse';
import { FirebaseService } from '../../common/services/firebase/firebase.service';
import { CreateBikerDTO, UpdateBikerDTO } from '../dto';
import { GetBikerTotalOrdersDTO } from '../dto/getBikerTotalOrders.dto';
import {
  Biker,
  BikerModel,
  BikerStatus,
  bikerModelName,
} from '../schemas/bikers.schema';
import { BikerCrudValidator } from '../services/bikersCrud.validator';

@Injectable()
export class BikersRepository {
  populatedPaths = [
    { path: 'createdBy', select: 'userName', model: adminModelName },
    { path: 'areas', select: 'name', model: areaModelName },
    { path: 'city', select: 'name', model: cityModelName },
  ];
  constructor(
    @InjectModel(bikerModelName) private readonly bikerModel: Model<BikerModel>,
    private bikerCrudValidator: BikerCrudValidator,
    private firebaseService: FirebaseService,
  ) {}

  async create(
    adminId: string,
    createBikerDTO: CreateBikerDTO,
    image: Express.Multer.File,
    hashedPassword: string,
  ) {
    if (!image)
      throw new MethodNotAllowedResponse({
        ar: 'قم برفع الصورة الشخصية',
        en: 'Upload personal image',
      });

    // Validate Input data Existence
    await this.bikerCrudValidator.createValidator(
      createBikerDTO.phone,
      createBikerDTO.nationalId,
      createBikerDTO.userName,
    );

    const createdBiker = await this.bikerModel.create({
      userName: createBikerDTO.userName,
      password: hashedPassword,
      phone: createBikerDTO.phone,
      nationalId: createBikerDTO.nationalId,
      createdBy: adminId,
      commissionType: createBikerDTO.commissionType,
      commission: createBikerDTO.commission,
      ordersBeforeCommission: createBikerDTO.ordersBeforeCommission,
      minimumCommission: createBikerDTO.minimumCommission,
      weekendCommission: createBikerDTO.weekendCommission,
    });

    // Upload Image for user
    const { fileLink, filePath } = await this.firebaseService.uploadImage(
      image,
    );

    createdBiker.imageLink = fileLink;
    createdBiker.imagePath = filePath;
    await createdBiker.save();
  }

  async findAll(role: string, cities: City[], search?: string) {
    const conditions: any = {
      isDeleted: false,
    };

    if (search) {
      conditions.$or = [
        { userName: { $regex: '.*' + search.trim() + '.*', $options: 'i' } },
        { phone: { $regex: '.*' + search.trim() + '.*', $options: 'i' } },
      ];
    }

    return await this.bikerModel
      .find(conditions)
      .sort({ createdAt: -1 })
      .populate(this.populatedPaths);
  }

  async findAllWithStatus(status: BikerStatus, area: any) {
    return await this.bikerModel.find({
      isDeleted: false,
      status: status,
      areas: { $all: [new Types.ObjectId(area._id)] },
    });
  }

  async findAllByArea(areaId: string) {
    return await this.bikerModel.aggregate([
      {
        $lookup: {
          from: 'biker-schedules',
          localField: '_id',
          foreignField: 'biker',
          pipeline: [
            {
              $unwind: '$shifts',
            },
            {
              $match: {
                'shifts.area': new Types.ObjectId(areaId),
              },
            },
          ],
          as: 'bikerSchedules',
        },
      },
      {
        $match: {
          isDeleted: false,
          status: { $ne: BikerStatus.SUSPENDED },
          'bikerSchedules.0': { $exists: true },
        },
      },
      {
        $project: {
          _id: 1,
          userName: 1,
          phone: 1,
        },
      },
    ]);
  }

  async findByIdOr404(id: string) {
    const biker = await this.bikerModel
      .findOne({ _id: id, isDeleted: false })
      .select('+fcmTokens')
      .populate(this.populatedPaths);
    if (!biker)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا السائق',
        en: 'Biker not found',
      });

    return biker;
  }

  async findByIdWithPasswordOr404(id: string) {
    const biker = await this.bikerModel
      .findOne({ _id: id, isDeleted: false })
      .select('+password');
    if (!biker)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا السائق',
        en: 'Biker not found',
      });

    return biker;
  }

  async findByPhoneNumber(phone: string) {
    return await this.bikerModel.findOne({ phone: phone, isDeleted: false });
  }

  async findByUserNameOr404(userName: string) {
    const biker = await this.bikerModel
      .findOne({ userName: userName, isDeleted: false })
      .select('+password +fcmTokens');
    if (!biker)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا السائق',
        en: 'Biker not found',
      });

    return biker;
  }

  async findBiker(id: string) {
    return await this.bikerModel.findById(id).select('+fcmTokens');
  }

  async delete(id: string) {
    // TODO: CHECK HIS WALLET BEFORE DELETION
    const biker = await this.bikerModel
      .findOne({ _id: id, isDeleted: false })
      .select('+fcmTokens');
    biker.isDeleted = true;
    biker.userName = '-d ' + biker.userName;
    biker.phone = '-d ' + biker.phone;
    biker.fcmTokens = [];
    biker.nationalId = '-d ' + biker.nationalId;

    await biker.save();
  }

  async updateBikerPassword(bikerId: string, hashedPassword: string) {
    await this.bikerModel.updateOne(
      { _id: bikerId },
      { $set: { password: hashedPassword } },
    );
  }

  async updateBikerPublicInfo(
    bikerId: string,
    userName: string,
    image: Express.Multer.File,
  ) {
    const biker = await this.findById(bikerId);
    if (!biker)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا السائق',
        en: 'Biker not found',
      });

    if (await this.isUserNameExistForAnotherBiker(bikerId, userName))
      throw new MethodNotAllowedResponse({
        ar: 'رقم البطاقة القومي مسجل من قبل',
        en: 'National Id is already exist',
      });
    const updatedBiker = await this.bikerModel.findByIdAndUpdate(
      bikerId,
      {
        $set: {
          userName: userName,
        },
      },
      { new: true },
    );
    if (image) {
      if (updatedBiker.imagePath)
        await this.firebaseService.deleteFileFromStorage(
          updatedBiker.imagePath,
        );

      const { fileLink, filePath } = await this.firebaseService.uploadImage(
        image,
      );

      updatedBiker.imageLink = fileLink;
      updatedBiker.imagePath = filePath;
      await updatedBiker.save();
    }
  }

  async isUserNameExistForAnotherBiker(id: string, userName: string) {
    return await this.bikerModel.findOne({
      _id: { $ne: id },
      userName: userName,
      isDeleted: false,
    });
  }

  async update(
    id: string,
    updateBikerDTO: UpdateBikerDTO,
    image: Express.Multer.File,
    adminId: string,
  ) {
    const biker = await this.findById(id);
    if (!biker)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا السائق',
        en: 'Biker not found',
      });

    await this.bikerCrudValidator.updateBikerValidator(id, updateBikerDTO);

    const updatedBiker = await this.bikerModel.findByIdAndUpdate(
      id,
      {
        $set: {
          userName: updateBikerDTO.userName,
          phone: updateBikerDTO.phone,
          nationalId: updateBikerDTO.nationalId,
          commissionType: updateBikerDTO.commissionType,
          commission: updateBikerDTO.commission,
          ordersBeforeCommission: updateBikerDTO.ordersBeforeCommission,
          minimumCommission: updateBikerDTO.minimumCommission,
          weekendCommission: updateBikerDTO.weekendCommission,
          updatedBy: adminId,
        },
      },
      { new: true },
    );
    if (image) {
      if (updatedBiker.imagePath)
        await this.firebaseService.deleteFileFromStorage(
          updatedBiker.imagePath,
        );

      const { fileLink, filePath } = await this.firebaseService.uploadImage(
        image,
      );

      updatedBiker.imageLink = fileLink;
      updatedBiker.imagePath = filePath;
      await updatedBiker.save();
    }

    return updatedBiker;
  }

  async findById(id: string | Biker) {
    return await this.bikerModel.findOne({ _id: id, isDeleted: false });
  }

  async updateLocation(
    bikerId: string,
    location: {
      latitude: number;
      longitude: number;
      streetName: string;
      subAdministrativeArea: string;
    },
  ) {
    return await this.bikerModel.findByIdAndUpdate(
      bikerId,
      {
        $set: {
          latitude: location.latitude,
          longitude: location.longitude,
          streetName: location.streetName,
          subAdministrativeArea: location.subAdministrativeArea,
        },
      },
      { new: true },
    );
  }

  async getBikersPerformanceReport({
    bikerId,
    fromDate,
    toDate,
    search,
  }: GetBikerTotalOrdersDTO) {
    const matchCriteria: any = {
      ...(bikerId && { _id: new Types.ObjectId(bikerId) }),
    };

    if (search) {
      matchCriteria.$or = [
        { userName: { $regex: '.*' + search.trim(), $options: 'i' } },
        { phone: { $regex: '.*' + search.trim(), $options: 'i' } },
      ];
    }

    const data = await this.bikerModel.aggregate([
      {
        $match: {
          ...matchCriteria,
        },
      },
      {
        $lookup: {
          from: 'admins',
          localField: 'createdBy',
          foreignField: '_id',
          as: 'createdBy',
          pipeline: [{ $project: { userName: 1 } }],
        },
      },
      {
        $unwind: {
          path: '$createdBy',
          preserveNullAndEmptyArrays: true,
        },
      },
      {
        $lookup: {
          from: 'orders',
          localField: '_id',
          foreignField: 'biker',
          as: 'orders',
        },
      },
      {
        $addFields: {
          filteredOrders: {
            $filter: {
              input: '$orders',
              as: 'order',
              cond: {
                $and: [
                  { $eq: ['$$order.status', OrderStatus.COMPLETED] },
                  ...(fromDate && toDate
                    ? [
                        { $gte: ['$$order.createdAt', new Date(fromDate)] },
                        { $lte: ['$$order.createdAt', new Date(toDate)] },
                      ]
                    : []),
                ],
              },
            },
          },
        },
      },
      {
        $addFields: {
          totalDeliveries: { $size: '$filteredOrders' },
          totalTimeWorked: {
            $sum: {
              $map: {
                input: '$filteredOrders',
                as: 'order',
                in: {
                  $divide: [
                    {
                      $subtract: [
                        { $toDate: '$$order.endTime' },
                        { $toDate: '$$order.onWashingAt' },
                      ],
                    },
                    60000,
                  ],
                },
              },
            },
          },
        },
      },
      {
        $addFields: {
          averageTimePerDelivery: {
            $cond: {
              if: { $gt: ['$totalDeliveries', 0] },
              then: { $divide: ['$totalTimeWorked', '$totalDeliveries'] },
              else: 0,
            },
          },
        },
      },
      {
        $project: {
          _id: 1,
          userName: 1,
          rating: 1,
          imageLink: 1,
          phone: 1,
          status: 1,
          nationalId: 1,
          createdBy: 1,
          streetName: 1,
          subAdminstrativeArea: 1,
          totalDeliveries: 1,
          totalTimeWorked: { $round: ['$totalTimeWorked', 0] },
          averageTimePerDelivery: { $round: ['$averageTimePerDelivery', 0] },
          createdAt: 1,
          commission: 1,
          commissionType: 1,
          ordersBeforeCommission: 1,
          minimumCommission: 1,
        },
      },
      {
        $addFields: {
          totalDeliveries: { $ifNull: ['$totalDeliveries', 0] },
          totalTimeWorked: { $ifNull: ['$totalTimeWorked', 0] },
          averageTimePerDelivery: { $ifNull: ['$averageTimePerDelivery', 0] },
        },
      },
    ]);

    return data;
  }

  async updatePassword(bikerId: string, hashedPassword: string): Promise<void> {
    const biker = await this.bikerModel.findById(bikerId);
    if (!biker) {
      throw new NotFoundException('Biker not found');
    }

    biker.password = hashedPassword;
    await biker.save();
  }
}
