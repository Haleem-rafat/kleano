import {
  Injectable,
  NotFoundException,
  UnprocessableEntityException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Roles } from 'src/admin/schemas/admin.schema';
import { plansModelName } from 'src/plans/schemas/plans.schema';
import { OperatorEnum } from 'src/promo-code/schemas/aggregator-promo-code.schema';
import { subscriptionsModelName } from 'src/subscriptions/schemas/subscriptions.schema';
import { addOnsModelName } from '../../add-ons/schemas/add-ons.schema';
import { Biker, bikerModelName } from '../../bikers/schemas/bikers.schema';
import { City, cityModelName } from '../../city/schemas/city.schema';
import { NotFoundResponse } from '../../common/errors/NotFoundResponse';
import {
  Location,
  locationModelName,
} from '../../locations/schemas/location.schema';
import { promoCodeModelName } from '../../promo-code/schemas/promo-code.schema';
import { servicesIconModelName } from '../../services-icons/schemas/services-icons.schema';
import { User, userModelName } from '../../user/schemas/user.schema';
import { vehicleModelName } from '../../vehicles/schemas/vehicles.schema';
import {
  WashingService,
  WashingServicesModelName,
} from '../../washing-services/schemas/washing-services.schema';
import {
  MoyasarPaymentStatus,
  Payment,
  PaymentsModel,
  paymentsModelName,
} from '../schemas/payments.schema';
import { ordersModelName } from 'src/orders/schemas/orders.schema';

@Injectable()
export class PaymentsRepository {
  populatedPaths = [
    {
      path: 'order',
      model: ordersModelName,
    },
    {
      path: 'subscription',
      model: subscriptionsModelName,
    },
  ];

  populatedPathsForAdminView = [
    {
      path: 'order',
      model: ordersModelName,
    },
    {
      path: 'subscription',
      model: subscriptionsModelName,
    },
  ];

  constructor(
    @InjectModel('payments')
    private readonly paymentsModel: Model<PaymentsModel>,
  ) {}

  // Find a payment by order ID
  async findOne(filter: { order: Types.ObjectId }) {
    try {
      const paymentDoc = await this.paymentsModel.findOne(filter).exec();
      return paymentDoc; // Returns the document or null if not found
    } catch (error) {
      throw new NotFoundException({
        ar: 'خطأ في العثور على مستند الدفع',
        en: 'Error finding payment document',
      });
    }
  }

  async findOneBySubscription(filter: { subscription: Types.ObjectId }) {
    try {
      const paymentDoc = await this.paymentsModel.findOne(filter).exec();
      return paymentDoc; // Returns the document or null if not found
    } catch (error) {
      throw new NotFoundException({
        ar: 'خطأ في العثور على مستند الدفع',
        en: 'Error finding payment document',
      });
    }
  }

  async create(paymentData: any): Promise<Payment> {
    try {
      console.log(
        'Creating Payment with Data:',
        JSON.stringify(paymentData, null, 2),
      );

      const paymentDoc = new this.paymentsModel(paymentData);
      await paymentDoc.save();

      console.log(
        'Payment Created Successfully:',
        JSON.stringify(paymentDoc, null, 2),
      );

      return paymentDoc;
    } catch (error) {
      console.error('Error creating payment document:', error);
      throw new UnprocessableEntityException({
        ar: 'خطأ في إنشاء مستند الدفع',
        en: 'Error creating payment document',
      });
    }
  }

  async findAllByAdmin(
    skip: number,
    limit: number,
    role: string,
    paymentStatus?: MoyasarPaymentStatus[],
    cities?: City[],
    search?: string,
  ) {
    const matchConditions: any = {
      ...(paymentStatus?.length
        ? { paymentStatus: { $in: paymentStatus } }
        : {}),
    };

    const payments = await this.paymentsModel.aggregate([
      {
        $match: matchConditions,
      },
      {
        $sort: { createdAt: -1 },
      },
      {
        $lookup: {
          from: 'orders',
          let: { orderId: '$order' },
          pipeline: [
            {
              $match: {
                $expr: {
                  $eq: ['$_id', '$$orderId'],
                },
              },
            },
          ],
          as: 'related_order',
        },
      },
      {
        $unwind: {
          path: '$related_order',
          preserveNullAndEmptyArrays: true,
        },
      },
      {
        $lookup: {
          from: 'users',
          let: { userId: '$related_order.user' },
          pipeline: [
            {
              $match: {
                $expr: {
                  $eq: ['$_id', '$$userId'],
                },
                ...(search
                  ? {
                      $or: [
                        { userName: { $regex: new RegExp(search, 'i') } },
                        { phone: { $regex: new RegExp(search, 'i') } },
                      ],
                    }
                  : {}),
              },
            },
          ],
          as: 'payment_user',
        },
      },
      {
        $unwind: {
          path: '$payment_user',
          preserveNullAndEmptyArrays: false,
        },
      },
      {
        $facet: {
          metadata: [{ $count: 'count' }],
          data: [{ $skip: skip }, { $limit: limit }],
        },
      },
    ]);

    await this.paymentsModel.populate(payments[0]['data'], [
      { path: 'order', model: ordersModelName, populate: { path: 'user' } },
    ]);

    // Remove temporary fields after population
    payments[0]['data']?.forEach((payment: any) => {
      delete payment['related_order'];
      delete payment['payment_user'];
    });

    return {
      payments: payments[0]['data'],
      count: payments[0]['metadata']?.length
        ? payments[0]['metadata'][0]['count']
        : 0,
    };
  }

  async findPaymentWithCityByIdPopulatedOr404(id: string) {
    const payment = await this.paymentsModel
      .findById(id)
      .populate(this.populatedPathsForAdminView)
      .populate({
        path: 'subscription',
        model: subscriptionsModelName,
        select: 'plan',
        populate: {
          path: 'plan',
          model: plansModelName,
          select: 'type color',
        },
      })

      .populate({
        path: 'order',
        model: ordersModelName,
        populate: [
          {
            path: 'user',
            model: userModelName,
          },
          {
            path: 'location',
            model: locationModelName,
          },
        ],
      })
      .lean();
    if (!payment)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا الطلب',
        en: 'Payment Not Found',
      });

    const lat = payment.order.location.latitude;
    const long = payment.order.location.longitude;

    return {
      ...payment,
      googleMapsLink: `https://www.google.com/maps?q=${lat},${long}`,
    };
  }

  async findAllUsersWithPaymentsAggregator(
    expressionLeftSide: string,
    operator: string,
    expressionRightSide: number,
  ) {
    const matchQuery = [
      {
        $match: {
          ...(operator === OperatorEnum.EQUALS && {
            paymentCount: { $eq: expressionRightSide },
          }),
          ...(operator === OperatorEnum.GREATER_THAN && {
            paymentCount: { $gt: expressionRightSide },
          }),
          ...(operator === OperatorEnum.LESS_THAN && {
            paymentCount: { $lt: expressionRightSide },
          }),
        },
      },
    ];

    return await this.paymentsModel.aggregate([
      {
        $group: {
          _id: '$user',
          paymentCount: { $sum: 1 },
        },
      },
      ...matchQuery,
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: '_id',
          as: 'userData',
        },
      },
      {
        $unwind: {
          path: '$userData',
          preserveNullAndEmptyArrays: true,
        },
      },
      {
        $replaceRoot: {
          newRoot: '$userData',
        },
      },
    ]);
  }

  async findAllUserPayments(
    user: User,
    paymentStatus: string,
    skip: number,
    limit: number,
  ) {
    const userId = new Types.ObjectId((user as any)._id);

    // Define valid payment statuses
    const validStatuses = Object.values(MoyasarPaymentStatus) as string[];

    const statusFilter = validStatuses.includes(paymentStatus)
      ? { paymentStatus }
      : { paymentStatus: MoyasarPaymentStatus.PAID };

    // Fetch only payments where the order belongs to the user
    const payments = await this.paymentsModel
      .find({
        ...statusFilter,
        order: { $ne: null }, // Ensures order exists
      })
      .populate({
        path: 'order',
        match: { user: userId }, // Ensures the order belongs to the user
      })
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 })
      .populate(this.populatedPaths);

    // Explicitly filter out payments where order is null
    const filteredPayments = payments.filter(
      (payment) => payment.order?.user?.toString() === userId.toString(),
    );

    return { payments: filteredPayments, count: filteredPayments.length };
  }

  async findPaymentByIdPopulatedOr404(id: string) {
    const payment = await this.paymentsModel
      .findById(id)
      .populate(this.populatedPaths)
      .populate({
        path: 'subscription',
        model: subscriptionsModelName,
        select: 'plan',
      })
      .populate({
        path: 'subscription',
        model: subscriptionsModelName,
        select: 'plan',
        populate: {
          path: 'plan',
          model: plansModelName,
          select: 'type',
        },
      })
      .populate({
        path: 'order',
        model: ordersModelName,
        populate: {
          path: 'user',
          model: userModelName,
        },
      });
    if (!payment)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا الطلب',
        en: 'Payment Not Found',
      });

    return payment;
  }

  async findPaymentByIdOr404(id: string) {
    const payment = await this.paymentsModel.findById(id);
    if (!payment)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا الطلب',
        en: 'Payment Not Found',
      });

    return payment;
  }
}
