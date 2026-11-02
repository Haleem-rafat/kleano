import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { NotFoundResponse } from 'src/common/errors';
import { Plan, plansModelName } from '../../plans/schemas/plans.schema';
import { User } from '../../user/schemas/user.schema';
import { WashingServicesModelName } from '../../washing-services/schemas/washing-services.schema';
import {
  Subscription,
  SubscriptionsModel,
  subscriptionsModelName,
  SubscriptionsStatus,
} from '../schemas/subscriptions.schema';

@Injectable()
export class SubscriptionsRepository {
  // Attributes
  populatedPaths = [
    {
      path: 'plan',
      select: 'type color',
      model: plansModelName,
    },
  ];
  constructor(
    @InjectModel(subscriptionsModelName)
    private readonly subscriptionsModel: Model<SubscriptionsModel>,
  ) {}

  async create(user: User, plan: Plan, expiryDate: Date, paymentType: string) {
    const createdSubscription = new this.subscriptionsModel({
      user: user,
      plan: plan,
      remainingWashes: plan.usageCount,
      washesCount: plan.usageCount,
      expiryDate: expiryDate,
      paymentType: paymentType,
    });

    await createdSubscription.save(); // This ensures the full document is returned

    return createdSubscription;
  }

  async findOne(user: User) {
    return await this.subscriptionsModel.findOne({
      user: user,
      status: SubscriptionsStatus.ACTIVE,
    });
  }

  async findOnePopulated(user: User) {
    const userSubscription = await this.subscriptionsModel
      .findOne({
        user: user,
        status: {
          $in: [SubscriptionsStatus.ACTIVE],
        },
      })
      .populate(this.populatedPaths);
    return userSubscription;
  }

  async findOnePopulatedWithStatusFilter(user: User, status?: string) {
    const validStatuses = [
      SubscriptionsStatus.ACTIVE,
      SubscriptionsStatus.PENDING,
    ];

    const statusFilter = !status
      ? [SubscriptionsStatus.ACTIVE]
      : validStatuses.includes(status as SubscriptionsStatus)
      ? [status]
      : validStatuses;

    const userSubscription = await this.subscriptionsModel
      .findOne({
        user: user,
        status: { $in: statusFilter },
      })
      .populate(this.populatedPaths);
    return userSubscription;
  }

  async findOneWithPlan(user: User) {
    return await this.subscriptionsModel
      .findOne({ user: user, status: SubscriptionsStatus.ACTIVE })
      .populate({
        path: 'plan',
        populate: {
          path: 'washingServices',
          select: 'name',
          model: WashingServicesModelName,
        },
        model: plansModelName,
      });
  }

  async findAll(filter: any) {
    return await this.subscriptionsModel.find({ ...filter });
  }

  async findById(id: string) {
    return await this.subscriptionsModel.findById(id);
  }

  async update(filter: any, updatedData: any) {
    await this.subscriptionsModel.updateMany(
      {
        ...filter,
      },
      { $set: updatedData },
    );
  }

  async decrementUserRemaingWashes(id: Subscription) {
    await this.subscriptionsModel.updateOne(
      {
        _id: id,
      },
      { $inc: { remainingWashes: -1 } },
    );

    const updatedSubscription = await this.subscriptionsModel.findById(id);

    if (updatedSubscription.remainingWashes === 0) {
      await this.subscriptionsModel.updateOne(
        {
          _id: id,
        },
        {
          status: SubscriptionsStatus.CANCELLED,
          expiryDate: new Date(),
        },
      );
    }
  }

  async incrementUserRemaingWashes(id: Subscription) {
    await this.subscriptionsModel.updateOne(
      {
        _id: id,
      },
      { $inc: { remainingWashes: 1 } },
    );
  }

  async cancel(userId: string, planId: string) {
    const sub = await this.subscriptionsModel.updateOne(
      {
        user: userId,
        plan: planId,
        status: SubscriptionsStatus.ACTIVE,
      },
      { status: SubscriptionsStatus.CANCELLED },
    );

    if (!sub) {
      throw new NotFoundException({
        ar: 'الاشتراك غير موجود',
        en: 'Subscription not found',
      });
    }
  }

  async findSubscriptionByIdOr404(id: string) {
    const subscription = await this.subscriptionsModel.findById(id);
    if (!subscription)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا الطلب',
        en: 'Subscription Not Found',
      });

    return subscription;
  }

  async findSubscriptionByIdPopulatedOr404(id: string) {
    const subscription = await this.subscriptionsModel
      .findById(id)
      .populate('plan');
    if (!subscription)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا الطلب',
        en: 'Order Not Found',
      });

    return subscription;
  }
}
