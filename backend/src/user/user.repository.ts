import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { MethodNotAllowedResponse } from '../common/errors/MethodNotAllowedResponse';
import { NotFoundResponse } from '../common/errors/NotFoundResponse';
import { FirebaseService } from '../common/services/firebase/firebase.service';
import { OperatorEnum } from '../promo-code/schemas/aggregator-promo-code.schema';
import { UserRegisterDTO, UserUpdateProfileDTO } from './dto';
import { User, UserModel, userModelName } from './schemas/user.schema';

type AggregatedUser = User & { _id: Types.ObjectId };
@Injectable()
export class UserRepository {
  constructor(
    @InjectModel(userModelName) private readonly userModel: Model<UserModel>,
    private firebaseService: FirebaseService,
  ) {}

  async create(userRegsiterDTO: UserRegisterDTO) {
    // Check Existence
    if (await this.checkPhoneExistence(userRegsiterDTO.phone))
      throw new MethodNotAllowedResponse({
        ar: 'الرقم مسجل من قبل',
        en: 'Phone is already exist',
      });

    // Check EmailExistence
    if (userRegsiterDTO.email) {
      if (await this.checkEmailIsAlreadyExist(userRegsiterDTO.email))
        throw new MethodNotAllowedResponse({
          ar: 'البريد الإلكتروني مسجل من قبل',
          en: 'Email is already exist',
        });
    }

    // Get next serial number
    const serialNumber = await this.getNextSerialNumber();

    // Create User
    const createdUser = await this.userModel.create({
      userName: userRegsiterDTO.userName,
      email: userRegsiterDTO.email,
      phone: userRegsiterDTO.phone,
      fcmTokens: [userRegsiterDTO.fcmToken],
      serialNumber: serialNumber,
    });

    return createdUser;
  }

  async update(
    userId: string,
    userUpdateProfileDTO: UserUpdateProfileDTO,
    image: Express.Multer.File,
  ) {
    const userProfile = await this.findUserById(userId);

    if (
      await this.checkEmailExistenceForAnotherUser(
        userId,
        userUpdateProfileDTO.email,
      )
    )
      throw new MethodNotAllowedResponse({
        ar: 'هذا البريد الإلكتروني مسجل من قبل',
        en: 'Email is already exist',
      });

    userProfile.userName = userUpdateProfileDTO.userName;
    userProfile.email = userUpdateProfileDTO.email;
    userProfile.gender = userUpdateProfileDTO.gender;
    userProfile.dob = userUpdateProfileDTO.dob;
    // Only overwrite when sent, otherwise saving undefined unsets the Qoyod link
    if (userUpdateProfileDTO.qoyodCustomerId !== undefined)
      userProfile.qoyodCustomerId = userUpdateProfileDTO.qoyodCustomerId;
    await userProfile.save();

    if (image) {
      if (userProfile.imagePath)
        await this.firebaseService.deleteFileFromStorage(userProfile.imagePath);

      const { fileLink, filePath } = await this.firebaseService.uploadImage(
        image,
      );

      userProfile.imageLink = fileLink;
      userProfile.imagePath = filePath;
      await userProfile.save();
    }

    return userProfile;
  }

  async delete(userId: string) {
    const userProfile = await this.findUserByIdOr404(userId);
    userProfile.isDeleted = true;
    userProfile.phone = '-d' + userProfile.phone;
    userProfile.email = '-d' + userProfile.email;
    userProfile.fcmTokens = [];
    await userProfile.save();
  }

  async findAll(): Promise<User[]> {
    return await this.userModel.find({ isDeleted: false });
  }

  async getAllForAdmin(): Promise<User[]> {
    return await this.userModel.find(
      { isDeleted: false },
      { _id: 1, userName: 1, email: 1, phone: 1 },
    );
  }

  async findAllNewUsers(): Promise<AggregatedUser[]> {
    return await this.userModel.aggregate([
      {
        $match: {
          isDeleted: false,

          createdAt: {
            $gte: new Date(new Date().setDate(new Date().getDate() - 30)),
          },
        },
      },
    ]);
  }

  async findUserByIdOr404(id: string) {
    const userDocument = await this.userModel.findOne({
      _id: id,
      isDeleted: false,
    });
    if (!userDocument)
      throw new NotFoundResponse({
        ar: 'هذا المستخدم غير مسجل',
        en: 'User Not Found',
      });

    return userDocument;
  }

  async findUserById(id: string) {
    const userDocument = await this.userModel.findOne({
      _id: id,
      isDeleted: false,
    });
    return userDocument;
  }

  async findUser(userId: string) {
    return await this.userModel
      .findOne({ _id: userId, isDeleted: false })
      .select('+fcmTokens');
  }

  async checkPhoneExistence(phone: string) {
    const userDocument = await this.userModel.findOne({
      phone: phone,
      isDeleted: false,
    });
    return userDocument ? true : false;
  }

  async checkPhoneExistenceForAnotherUser(userId: string, phone: string) {
    const userDocument = await this.userModel.findOne({
      phone: phone,
      isDeleted: false,
      _id: { $ne: userId },
    });
    return userDocument ? true : false;
  }

  async checkEmailIsAlreadyExist(email: string) {
    const userDocument = await this.userModel.findOne({
      email: email,
      isDeleted: false,
    });
    return userDocument ? true : false;
  }

  async checkEmailExistenceForAnotherUser(userId: string, email: string) {
    const userDocument = await this.userModel.findOne({
      email: email,
      isDeleted: false,
      _id: { $ne: userId },
    });
    return userDocument ? true : false;
  }

  async findUserByPhoneOr404(phone: string) {
    const userDocument = await this.userModel
      .findOne({
        phone: phone,
        isDeleted: false,
      })
      .select('+fcmTokens');
    if (!userDocument)
      throw new NotFoundResponse({
        ar: 'هذا الرقم غير مسجل',
        en: 'phone does not exist',
      });

    return userDocument;
  }

  async getUsersToExcel() {
    return await this.userModel.aggregate([
      {
        $match: { isDeleted: false },
      },
      {
        $lookup: {
          from: 'vehicles',
          localField: '_id',
          foreignField: 'user',
          as: 'vehicles',
        },
      },
      {
        $lookup: {
          from: 'orders',
          localField: '_id',
          foreignField: 'user',
          as: 'orders',
          pipeline: [
            {
              $project: {
                _id: 1,
                totalPay: 1,
                totalPrice: 1,
                addOns: 1,
              },
            },
          ],
        },
      },
      {
        $addFields: {
          ordersCount: { $size: { $ifNull: ['$orders', []] } },
          totalOrdersPrice: {
            $sum: {
              $map: {
                input: { $ifNull: ['$orders', []] },
                as: 'order',
                in: {
                  $ifNull: [
                    '$$order.totalPay',
                    { $ifNull: ['$$order.totalPrice', 0] },
                  ],
                },
              },
            },
          },
          addOnsCount: {
            $sum: {
              $map: {
                input: { $ifNull: ['$orders', []] },
                as: 'order',
                in: { $size: { $ifNull: ['$$order.addOns', []] } },
              },
            },
          },
          totalAddOnsPrice: {
            $sum: {
              $map: {
                input: { $ifNull: ['$orders', []] },
                as: 'order',
                in: {
                  $sum: {
                    $map: {
                      input: { $ifNull: ['$$order.addOns', []] },
                      as: 'addOn',
                      in: { $ifNull: ['$$addOn.price', 0] },
                    },
                  },
                },
              },
            },
          },
        },
      },
      {
        $project: {
          serialNumber: 1,
          userName: 1,
          email: 1,
          phone: 1,
          createdAt: 1,
          vehicles: 1,
          gender: 1,
          ordersCount: 1,
          totalOrdersPrice: 1,
          addOnsCount: 1,
          totalAddOnsPrice: 1,
        },
      },
    ]);
  }

  async getUserDetails(userId: string) {
    return await this.userModel.aggregate([
      {
        $match: {
          _id: new Types.ObjectId(userId),
        },
      },
      {
        $lookup: {
          from: 'vehicles',
          localField: '_id',
          foreignField: 'user',
          as: 'vehicles',
          pipeline: [
            {
              $project: {
                _id: 1,
                brand: 1,
                model: 1,
                plateNumber: 1,
                color: 1,
                imageLink: 1,
              },
            },
          ],
        },
      },
      {
        $lookup: {
          from: 'orders',
          localField: '_id',
          foreignField: 'user',
          as: 'orders',
          pipeline: [
            {
              $lookup: {
                from: 'washing-services',
                localField: 'washingServices',
                foreignField: '_id',
                as: 'washingServices',
                pipeline: [
                  {
                    $project: {
                      _id: 1,
                      name: 1,
                      duration: 1,
                      price: 1,
                      icon: 1,
                    },
                  },
                ],
              },
            },
            {
              $lookup: {
                from: 'add-ons',
                localField: 'addOns',
                foreignField: '_id',
                as: 'addOns',
                pipeline: [
                  {
                    $project: {
                      _id: 1,
                      name: 1,
                      price: 1,
                      icon: 1,
                    },
                  },
                ],
              },
            },
            {
              $lookup: {
                from: 'vehicles',
                localField: 'vehicle',
                foreignField: '_id',
                as: 'vehicle',
                pipeline: [
                  {
                    $project: {
                      _id: 1,
                      brand: 1,
                      model: 1,
                      plateNumber: 1,
                      color: 1,
                      imageLink: 1,
                    },
                  },
                ],
              },
            },
            {
              $unwind: { path: '$vehicle' },
            },
            {
              $lookup: {
                from: 'locations',
                localField: 'location',
                foreignField: '_id',
                as: 'location',
                pipeline: [
                  {
                    $project: {
                      _id: 1,
                      latitude: 1,
                      longitude: 1,
                      subAdminstrativeArea: 1,
                      streetName: 1,
                      city: 1,
                    },
                  },
                ],
              },
            },
            {
              $unwind: { path: '$location' },
            },
          ],
        },
      },
      {
        $addFields: {
          ordersCount: { $size: { $ifNull: ['$orders', []] } },
          totalOrdersPrice: {
            $sum: {
              $map: {
                input: { $ifNull: ['$orders', []] },
                as: 'order',
                in: {
                  $ifNull: [
                    '$$order.totalPay',
                    { $ifNull: ['$$order.totalPrice', 0] },
                  ],
                },
              },
            },
          },
          addOnsCount: {
            $sum: {
              $map: {
                input: { $ifNull: ['$orders', []] },
                as: 'order',
                in: { $size: { $ifNull: ['$$order.addOns', []] } },
              },
            },
          },
          totalAddOnsPrice: {
            $sum: {
              $map: {
                input: { $ifNull: ['$orders', []] },
                as: 'order',
                in: {
                  $sum: {
                    $map: {
                      input: { $ifNull: ['$$order.addOns', []] },
                      as: 'addOn',
                      in: { $ifNull: ['$$addOn.price', 0] },
                    },
                  },
                },
              },
            },
          },
        },
      },
      {
        $lookup: {
          from: 'subscriptions',
          localField: '_id',
          foreignField: 'user',
          as: 'plans',
          pipeline: [
            {
              $project: {
                plan: 1,
              },
            },
            {
              $lookup: {
                from: 'plans',
                localField: 'plan',
                foreignField: '_id',
                as: 'plan',
              },
            },
            {
              $unwind: '$plan',
            },
          ],
        },
      },
      {
        $addFields: {
          plansCount: { $size: { $ifNull: ['$plans', []] } },
          totalPlansPrice: {
            $sum: {
              $map: {
                input: { $ifNull: ['$plans', []] },
                as: 'p',
                in: { $ifNull: ['$$p.plan.price', 0] },
              },
            },
          },
        },
      },
    ]);
  }

  /**
   * Get the next available serial number for a new user
   * This method finds the highest existing serial number and returns the next one
   */
  async getNextSerialNumber(): Promise<number> {
    const lastUser = await this.userModel
      .findOne({ serialNumber: { $exists: true } })
      .sort({ serialNumber: -1 })
      .select('serialNumber');

    if (!lastUser || !lastUser.serialNumber) {
      return 1;
    }

    return lastUser.serialNumber + 1;
  }

  /**
   * Assign serial numbers to existing users who don't have one
   * This method should be run as a migration script
   */
  async assignSerialNumbersToExistingUsers(): Promise<void> {
    const usersWithoutSerialNumber = await this.userModel
      .find({
        serialNumber: { $exists: false },
        isDeleted: false,
      })
      .sort({ createdAt: 1 }); // Sort by creation date to maintain chronological order

    let nextSerialNumber = await this.getNextSerialNumber();

    for (const user of usersWithoutSerialNumber) {
      user.serialNumber = nextSerialNumber;
      await user.save();
      nextSerialNumber++;
    }
  }

  /**
   * Get user count for migration purposes
   */
  async getUserCount(): Promise<number> {
    return await this.userModel.countDocuments({ isDeleted: false });
  }

  async findUsersWithoutOrders() {
    return await this.userModel.aggregate([
      {
        $match: {
          isDeleted: false,
        },
      },
      {
        $lookup: {
          from: 'orders',
          localField: '_id',
          foreignField: 'user',
          as: 'orders',
        },
      },
      {
        $match: {
          orders: { $size: 0 },
        },
      },
      {
        $project: {
          _id: 1,
          userName: 1,
          email: 1,
          phone: 1,
          fcmTokens: 1,
          createdAt: 1,
        },
      },
    ]);
  }

  async findUsersBySegment(segmentId: string) {
    return await this.userModel.aggregate([
      {
        $match: {
          isDeleted: false,
        },
      },
      {
        $lookup: {
          from: 'segments',
          localField: 'segment',
          foreignField: '_id',
          as: 'segmentDetails',
        },
      },
      {
        $match: {
          'segmentDetails._id': new Types.ObjectId(segmentId),
        },
      },
      {
        $project: {
          _id: 1,
          userName: 1,
          email: 1,
          phone: 1,
          fcmTokens: 1,
          createdAt: 1,
        },
      },
    ]);
  }

  async findUsersByAggregatorCriteria(
    expressionLeftSide: string,
    operator: string,
    expressionRightSide: number,
  ) {
    const matchQuery = [
      {
        $match: {
          ...(operator === OperatorEnum.EQUALS && {
            orderCount: { $eq: expressionRightSide },
          }),
          ...(operator === OperatorEnum.GREATER_THAN && {
            orderCount: { $gt: expressionRightSide },
          }),
          ...(operator === OperatorEnum.LESS_THAN && {
            orderCount: { $lt: expressionRightSide },
          }),
        },
      },
    ];

    return await this.userModel.aggregate([
      {
        $lookup: {
          from: 'orders',
          localField: '_id',
          foreignField: 'user',
          as: 'orders',
        },
      },
      {
        $addFields: {
          orderCount: { $size: '$orders' },
        },
      },
      {
        $match: {
          isDeleted: false,
        },
      },
      ...matchQuery,
      {
        $project: {
          _id: 1,
          userName: 1,
          email: 1,
          phone: 1,
          fcmTokens: 1,
          createdAt: 1,
        },
      },
    ]);
  }

  async findAllWithoutQoyodCustomer() {
    return await this.userModel
      .find({
        $or: [
          { qoyodCustomerId: null },
          { qoyodCustomerId: { $exists: false } },
        ],
        isDeleted: false,
        isSuspended: false,
      })
      .select('_id userName phone email');
  }

  async updateQoyodCustomerId(userId: string, qoyodCustomerId: number) {
    return await this.userModel.findByIdAndUpdate(userId, {
      qoyodCustomerId,
    });
  }

  async incrementWalletBalance(userId: string, amount: number) {
    return await this.userModel.findByIdAndUpdate(
      userId,
      { $inc: { walletBalance: amount } },
      { new: true },
    );
  }
}
