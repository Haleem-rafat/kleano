import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, PipelineStage, Types } from 'mongoose';
import { ListAllUsers, UserStatusEnum } from './dto/list-users.dto';
import { UserModel, userModelName } from './schemas/user.schema';

@Injectable()
export class AdminUserRepository {
  constructor(
    @InjectModel(userModelName) private readonly userModel: Model<UserModel>,
  ) {}

  async listAllUsers(query: ListAllUsers, skip: number, limit: number) {
    const { search, status } = query;

    const matchStage: PipelineStage[] = [
      {
        $match: {
          ...(search && {
            $or: [
              {
                userName: { $regex: '.*' + search.trim(), $options: 'i' },
              },
              {
                phone: { $regex: '.*' + search.trim(), $options: 'i' },
              },
            ],
          }),
          ...(status &&
            status === UserStatusEnum.ACTIVE && { isSuspended: false }),
          ...(status &&
            status === UserStatusEnum.SUSPENDED && { isSuspended: true }),
          isDeleted: false,
        },
      },
    ];

    const [data, [{ count = 0 } = {}]] = await Promise.all([
      this.userModel.aggregate([
        ...matchStage,
        {
          $project: {
            _id: 1,
            serialNumber: 1,
            userName: 1,
            email: 1,
            phone: 1,
            isSuspended: 1,
          },
        },
        {
          $skip: skip,
        },
        {
          $limit: limit,
        },
      ]),
      this.userModel.aggregate([...matchStage]).count('count'),
    ]);

    return { data, count };
  }

  async getUserById(userId: string) {
    const [user] = await this.userModel.aggregate([
      {
        $match: {
          _id: new Types.ObjectId(userId),
          isDeleted: false,
        },
      },
      {
        $lookup: {
          from: 'orders',
          let: { userId: '$_id' },
          pipeline: [
            {
              $match: {
                $expr: {
                  $eq: ['$user', { $ifNull: ['$$userId', null] }],
                },
              },
            },
            // {
            //   $project: {}
            // }
          ],
          as: 'orders',
        },
      },
      {
        $project: {
          userName: 1,
          phone: 1,
          email: 1,
          rating: 1,
          location: 1,
          isSuspended: 1,
        },
      },
    ]);

    if (!user) {
      throw new NotFoundException({
        ar: 'المستخدم غير موجود',
        en: 'User not found',
      });
    }

    return user;
  }

  async suspendUser(userId: string) {
    const user = await this.userModel.findById(userId);

    if (!user) {
      throw new NotFoundException({
        ar: 'المستخدم غير موجود',
        en: 'User not found',
      });
    }

    user.set({
      isSuspended: true,
    });
    await user.save();

    return user;
  }

  async unsuspendUser(userId: string) {
    const user = await this.userModel.findById(userId);

    if (!user) {
      throw new NotFoundException({
        ar: 'المستخدم غير موجود',
        en: 'User not found',
      });
    }

    user.set({
      isSuspended: false,
    });
    await user.save();
  }

  async addBalanceToUserWallet(userId: string, amount: number) {
    const user = await this.userModel.findById(userId);

    if (!user) {
      throw new NotFoundException({
        ar: 'المستخدم غير موجود',
        en: 'User not found',
      });
    }

    if (amount <= 0) {
      throw new BadRequestException({
        ar: 'المبلغ يجب أن يكون أكبر من 0',
        en: 'Amount must be greater than 0',
      });
    }

    user.set({
      walletBalance: user.walletBalance + amount,
    });
    await user.save();

    return user;
  }
}
