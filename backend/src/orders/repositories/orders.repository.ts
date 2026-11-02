import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { adminModelName, Roles } from 'src/admin/schemas/admin.schema';
import { areaModelName } from 'src/area/schemas/area.schema';
import { MoyasarPaymentStatus } from 'src/payments/schemas/payments.schema';
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
import { OrderCreationDTO } from '../dtos/OrderCreation.dto';
import {
  Order,
  OrdersModel,
  ordersModelName,
  OrderStatus,
} from '../schemas/orders.schema';

@Injectable()
export class OrdersRepository {
  populatedPaths = [
    {
      path: 'washingServices',
      populate: {
        path: 'icon',
        select: 'iconPath iconLink',
        model: servicesIconModelName,
      },
      model: WashingServicesModelName,
      select: 'name price description duration qoyodProductId',
    },
    {
      path: 'addOns',
      populate: {
        path: 'icon',
        select: 'iconPath iconLink',
        model: servicesIconModelName,
      },
      model: addOnsModelName,
      select: 'name price qoyodProductId',
    },
    {
      path: 'vehicle',
      model: vehicleModelName,
      select: 'type brand model plateNumber color imageLink imagePath',
    },
    {
      path: 'location',
      model: locationModelName,
      select:
        'latitude longitude streetName subAdministrativeArea isSaved savedName city area',
      populate: {
        path: 'city',
        model: cityModelName,
        select: 'name',
      },
    },
    {
      path: 'promoCode',
      model: promoCodeModelName,
      select: 'code',
    },
    {
      path: 'user',
      model: userModelName,
      select: 'userName phone imageLink',
    },
    {
      path: 'biker',
      model: bikerModelName,
      select: 'userName phone imageLink imagePath latitude longitude rating',
    },
    {
      path: 'cancelledByAdmin',
      model: adminModelName,
    },
  ];

  populatedPathsForAdminView = [
    {
      path: 'washingServices',
      populate: {
        path: 'icon',
        select: 'iconPath iconLink',
        model: servicesIconModelName,
      },
      model: WashingServicesModelName,
      select: 'name price description duration',
    },
    {
      path: 'addOns',
      populate: {
        path: 'icon',
        select: 'iconPath iconLink',
        model: servicesIconModelName,
      },
      model: addOnsModelName,
      select: 'name price',
    },
    {
      path: 'vehicle',
      model: vehicleModelName,
      select: 'type brand model plateNumber color imageLink imagePath',
    },
    {
      path: 'location',
      populate: [
        {
          path: 'city',
          select: 'name',
          model: cityModelName,
        },
        {
          path: 'area',
          select: 'name',
          model: areaModelName,
        },
      ],
      model: locationModelName,
      select:
        'latitude longitude streetName subAdministrativeArea isSaved savedName',
    },
    {
      path: 'promoCode',
      model: promoCodeModelName,
      select: 'code',
    },
    {
      path: 'user',
      model: userModelName,
      select: 'userName phone imageLink',
    },
    {
      path: 'biker',
      model: bikerModelName,
      select: 'userName phone imageLink imagePath latitude longitude rating',
    },
    {
      path: 'cancelledByAdmin',
      model: adminModelName,
    },
  ];

  constructor(
    @InjectModel(ordersModelName)
    private readonly ordersModel: Model<OrdersModel>,
  ) {}

  async create(
    user: User,
    orderCreationDTO: OrderCreationDTO,
    location: Location,
    totalDuration: number,
    orderStatus: OrderStatus,
    washingServices: WashingService[],
  ) {
    const bookingDate = orderCreationDTO.bookingDate.slice(0, 10);
    const date = new Date(bookingDate);

    date.setHours(15, 0, 0, 0);

    const createdOrder = await this.ordersModel.create({
      user: user,
      washingServices: washingServices,
      addOns: orderCreationDTO.addOns,
      vehicle: orderCreationDTO.vehicle,
      location: location,
      startTime: orderCreationDTO.startTime,
      timeSlot:
        orderCreationDTO.timeSlot ||
        (typeof orderCreationDTO.startTime === 'string'
          ? orderCreationDTO.startTime.slice(11, 16)
          : undefined),
      totalDuration: totalDuration,
      description: orderCreationDTO.description,
      type: orderCreationDTO.type,
      totalPrice: orderCreationDTO.totalPrice,
      totalPay: orderCreationDTO.totalPrice,
      subscription: orderCreationDTO.subscription,
      status: orderStatus,
      paymentType: orderCreationDTO.paymentType,
      bookingDate: date,
      isCarFreshened: orderCreationDTO.isCarFreshened,
      userOS: orderCreationDTO.userOS,
    });

    return createdOrder;
  }

  // Find order by ID method
  async findById(id: Types.ObjectId): Promise<Order | null> {
    try {
      const order = await this.ordersModel.findById(id).exec();
      return order; // If order not found, it will return null
    } catch (error) {
      throw new NotFoundException({
        ar: 'خطأ في العثور على الطلب بواسطة المعرف',
        en: 'Error finding order by ID',
      });
    }
  }

  async findAllUserOrders(
    user: User,
    status: string,
    skip: number,
    limit: number,
  ) {
    if (status === OrderStatus.SCHEDULED) {
      const orders = await this.ordersModel
        .find({
          user: user,
          status: {
            $nin: [
              OrderStatus.PENDING_USER_REVIEW,
              OrderStatus.PENDING_USER_PAYMENT,
              OrderStatus.CANCELLED_BY_USER,
              OrderStatus.CANCELLED_BY_ADMIN,
              OrderStatus.CANCELLED_BY_BIKER,
              OrderStatus.COMPLETED,
            ],
          },
          paymentStatus: MoyasarPaymentStatus.PAID,
          startTime: { $gt: new Date(Date.now() + 3 * 60 * 60 * 1000) },
        })
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 })
        .populate(this.populatedPaths);
      const count = await this.ordersModel.count({
        user: user,
        status: {
          $nin: [
            OrderStatus.PENDING_USER_REVIEW,
            OrderStatus.PENDING_USER_PAYMENT,
            OrderStatus.CANCELLED_BY_USER,
            OrderStatus.CANCELLED_BY_ADMIN,
            OrderStatus.CANCELLED_BY_BIKER,
            OrderStatus.COMPLETED,
          ],
        },
        paymentStatus: MoyasarPaymentStatus.PAID,
        startTime: { $gt: new Date(Date.now() + 3 * 60 * 60 * 1000) },
      });

      return { orders, count };
    }

    let statusListFilter: any = [];
    let paymentStatusFilter: any = [];
    if (status === OrderStatus.ACTIVE) {
      statusListFilter = [
        OrderStatus.ACTIVE,
        OrderStatus.WAITING_FOR_BIKER_BY_ADMIN,
        OrderStatus.ACCEPTED_BY_BIKER,
        OrderStatus.BIKER_ON_THE_WAY,
        OrderStatus.BIKER_ARRIVED,
        OrderStatus.ON_WASHING,
      ];
      paymentStatusFilter = [MoyasarPaymentStatus.PAID];
    } else if (status === 'HISTORY') {
      statusListFilter = [
        OrderStatus.CANCELLED_BY_BIKER,
        OrderStatus.CANCELLED_BY_USER,
        OrderStatus.CANCELLED_BY_ADMIN,
        OrderStatus.COMPLETED,
      ];
      paymentStatusFilter = [
        MoyasarPaymentStatus.PAID,
        MoyasarPaymentStatus.REFUNDED,
        MoyasarPaymentStatus.REFUND_FAILED,
      ];
    }

    const orders = await this.ordersModel
      .find({
        user: user,
        status: { $in: statusListFilter },
        paymentStatus: { $in: paymentStatusFilter },
      })
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 })
      .populate(this.populatedPaths);
    const count = await this.ordersModel.count({
      user: user,
      status: { $in: statusListFilter },
      paymentStatus: MoyasarPaymentStatus.PAID,
    });
    return { orders, count };
  }

  ordersStatusFiltersForBiker(
    bikerId: string,
    status: string,
    locations: Location[],
  ) {
    if (status === OrderStatus.ACTIVE) {
      return {
        biker: bikerId,
        status: {
          $in: [
            OrderStatus.ACCEPTED_BY_BIKER,
            OrderStatus.BIKER_ON_THE_WAY,
            OrderStatus.BIKER_ARRIVED,
            OrderStatus.ON_WASHING,
          ],
        },
        paymentStatus: MoyasarPaymentStatus.PAID,
      };
    }
    if (status === 'PENDING') {
      return {
        status: {
          $in: [OrderStatus.ACTIVE, OrderStatus.WAITING_FOR_BIKER_BY_ADMIN],
        },
        location: { $in: locations },
        paymentStatus: MoyasarPaymentStatus.PAID,
      };
    }

    if (status === OrderStatus.COMPLETED) {
      return {
        biker: bikerId,
        status: OrderStatus.COMPLETED,
        paymentStatus: MoyasarPaymentStatus.PAID,
      };
    }

    // if (status === OrderStatus.SCHEDULED) {
    //   return {
    //     biker: bikerId,
    //     // status: OrderStatus.SCHEDULED,
    //   };
    // }
  }

  async findAllBikerOrders(
    bikerId: string,
    status: string,
    skip: number,
    limit: number,
    locations: Location[],
  ) {
    const orders = await this.ordersModel
      .find({
        ...this.ordersStatusFiltersForBiker(bikerId, status, locations),
      })
      .skip(skip)
      .limit(limit)
      .sort({ startTime: 1 })
      .populate(this.populatedPaths)
      .select({ biker: 0 });
    const count = await this.ordersModel.count({
      ...this.ordersStatusFiltersForBiker(bikerId, status, locations),
    });
    return { orders, count };
  }

  async getBikerRatedOrders(bikerId: string | Biker) {
    return await this.ordersModel.find({
      biker: bikerId,
      ratingOfBiker: { $gte: 0 },
    });
  }

  async getUserRatedOrders(userId: string | User) {
    return await this.ordersModel.find({
      user: userId,
      ratingOfUser: { $gte: 0 },
    });
  }

  async findAllByAdmin(
    skip: number,
    limit: number,
    role: string,
    status?: OrderStatus[],
    cities?: City[],
    search?: string,
  ) {
    const matchConditions: any = {
      ...(status?.length
        ? {
            status: { $in: status },
            ...(status.includes(OrderStatus.CANCELLED_BY_ADMIN) ||
            status.includes(OrderStatus.CANCELLED_BY_USER)
              ? {
                  paymentStatus: {
                    $in: [
                      MoyasarPaymentStatus.PAID,
                      MoyasarPaymentStatus.REFUNDED,
                      MoyasarPaymentStatus.REFUND_FAILED,
                    ],
                  },
                }
              : { paymentStatus: MoyasarPaymentStatus.PAID }),
          }
        : {
            status: {
              $nin: [
                OrderStatus.PENDING_USER_PAYMENT,
                OrderStatus.PENDING_USER_REVIEW,
              ],
            },
            paymentStatus: MoyasarPaymentStatus.PAID,
          }),
      ...(role === Roles.SubAdmin && cities?.length
        ? { 'location.city': { $in: cities } }
        : {}),
    };
    const orders = await this.ordersModel.aggregate([
      {
        $match: matchConditions,
      },
      {
        $sort: { createdAt: -1 },
      },
      {
        $lookup: {
          from: 'users',
          let: { userId: '$user' },
          pipeline: [
            {
              $match: {
                $expr: {
                  $eq: ['$_id', '$$userId'],
                },
                ...(search
                  ? {
                      $or: [
                        {
                          userName: {
                            $regex: new RegExp(search, 'i'),
                          },
                        },
                        {
                          phone: {
                            $regex: new RegExp(search, 'i'),
                          },
                        },
                      ],
                    }
                  : {}),
              },
            },
          ],
          as: 'order_user',
        },
      },
      {
        $unwind: {
          path: '$order_user',
          preserveNullAndEmptyArrays: false,
        },
      },
      {
        $lookup: {
          from: 'locations',
          localField: 'location',
          foreignField: '_id',
          as: 'order_location',
        },
      },
      {
        $facet: {
          metadata: [{ $count: 'count' }],
          data: [{ $skip: skip }, { $limit: limit }],
        },
      },
    ]);
    await this.ordersModel.populate(
      orders[0]['data'],
      this.populatedPathsForAdminView,
    );
    // Remove temporary fields after population
    orders[0]['data']?.forEach((order: any) => {
      delete order['order_location'];
      delete order['order_user'];
    });
    return {
      orders: orders[0]['data'],
      count: orders[0]['metadata']?.length
        ? orders[0]['metadata'][0]['count']
        : 0,
    };
  }

  async findAllAssignedByAdmin(skip: number, limit: number, adminId: string) {
    const orders = await this.ordersModel
      .find({ assignedBy: adminId })
      .skip(skip)
      .limit(limit)
      .sort({ updatedAt: -1 })
      .populate(this.populatedPathsForAdminView);
    const count = await this.ordersModel.countDocuments({
      assignedBy: adminId,
    });
    return { orders, count };
  }

  async findOrderByIdOr404(id: string) {
    const order = await this.ordersModel.findById(id);
    if (!order)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا الطلب',
        en: 'Order Not Found',
      });

    return order;
  }

  async findOrderByIdPopulatedOr404(id: string) {
    const order = await this.ordersModel
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
      });
    if (!order)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا الطلب',
        en: 'Order Not Found',
      });

    return order;
  }

  async findOrderWithCityByIdPopulatedOr404(id: string) {
    const order = await this.ordersModel
      .findById(id)
      .populate(this.populatedPathsForAdminView)
      .populate({
        path: 'subscription',
        model: subscriptionsModelName,
        select: 'plan remainingWashes washesCount',
        populate: [
          {
            path: 'plan',
            model: plansModelName,
            select: 'type color price washingServices',
            populate: {
              path: 'washingServices',
              model: WashingServicesModelName,
              select: 'name',
            },
          },
        ],
      })
      .lean();
    if (!order)
      throw new NotFoundResponse({
        ar: 'لا يوجد هذا الطلب',
        en: 'Order Not Found',
      });

    const lat = order.location?.latitude;
    const long = order.location?.longitude;
    const userId = (order as any)?.user?._id ?? order?.user;
    const userOrdersCount = await this.ordersModel.countDocuments({
      user: userId,
    });

    return {
      ...order,
      googleMapsLink:
        lat && long ? `https://www.google.com/maps?q=${lat},${long}` : null,
      userOrdersCount,
    };
  }

  async findOrder(order: Order) {
    return await this.ordersModel.findOne({ _id: order });
  }

  async update(id: string, updatedKeys: any) {
    return await this.ordersModel.findByIdAndUpdate(
      id,
      {
        $set: { ...updatedKeys },
      },
      { returnDocument: 'after' },
    );
  }

  async findOneQuery(QueryObject: any) {
    return await this.ordersModel.findOne(QueryObject);
  }

  async findManyQuery(QueryObject: any) {
    return await this.ordersModel.find(QueryObject);
  }

  async findManyQueryPopulated(QueryObject: any) {
    return await this.ordersModel
      .find(QueryObject)
      .populate(this.populatedPaths);
  }

  async findAllUsersWithOrdersAggregator(
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

    return await this.ordersModel.aggregate([
      {
        $group: {
          _id: '$user',
          orderCount: { $sum: 1 },
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

  // async findAllScheduledOrders() {
  //   return await this.ordersModel
  //     .find({ status: OrderStatus.SCHEDULED, isScheduled: true })
  //     ;
  // }

  async getOrderTotalDurationReport() {
    const orders = await this.ordersModel.find({
      onWashingAt: { $exists: true },
      endTime: { $exists: true },
      status: 'COMPLETED',
    });
    const durations = orders
      .map((order) => {
        if (order.onWashingAt && order.endTime) {
          const durationInMinutes = Math.round(
            (order.endTime.getTime() - order.onWashingAt.getTime()) /
              (1000 * 60),
          );
          return {
            orderId: order._id,
            duration: durationInMinutes,
          };
        }
        return null;
      })
      .filter((result) => result !== null);

    // const totalDuration = durations.reduce(
    //   (acc, { duration }) => acc + duration,
    //   0,
    // );

    return {
      // totalDuration,
      durations,
    };
  }

  async getOrdersForExport() {
    return await this.ordersModel
      .find()
      .populate(this.populatedPathsForAdminView)
      .populate({
        path: 'subscription',
        model: subscriptionsModelName,
        select: 'plan remainingWashes washesCount',
        populate: [
          {
            path: 'plan',
            model: plansModelName,
            select: 'type color price washingServices',
            populate: {
              path: 'washingServices',
              model: WashingServicesModelName,
              select: 'name',
            },
          },
        ],
      })
      .populate({
        path: 'vehicle',
        populate: {
          path: 'user',
          select: 'serialNumber userName email phone gender',
        },
      })
      .lean();
  }

  async getOrdersRevenuePerMonthForCurrentYear() {
    const nowDate = new Date();
    const thisYear = nowDate.getFullYear();

    const data = await this.ordersModel.aggregate([
      {
        $match: {
          createdAt: {
            $gte: new Date(`${thisYear}-01-01T00:00:00Z`),
            $lt: new Date(`${thisYear + 1}-01-01T00:00:00Z`),
          },
          status: 'COMPLETED',
        },
      },
      {
        $group: {
          _id: { month: { $month: '$createdAt' } },
          totalEarnings: { $sum: '$totalPay' },
          totalOrders: { $sum: 1 },
        },
      },
      {
        $sort: { '_id.month': 1 },
      },
      {
        $project: {
          month: '$_id.month',
          totalEarnings: 1,
          totalOrders: 1,
          _id: 0,
        },
      },
      {
        $facet: {
          monthlyData: [
            {
              $set: {
                month: '$month',
                totalEarnings: '$totalEarnings',
                totalOrders: '$totalOrders',
              },
            },
          ],
          totalRevenue: [
            {
              $group: {
                _id: null,
                totalRevenue: { $sum: '$totalEarnings' },
              },
            },
          ],
        },
      },
      {
        $project: {
          monthlyReport: {
            $map: {
              input: { $range: [1, 13] },
              as: 'monthNumber',
              in: {
                $let: {
                  vars: {
                    monthData: {
                      $arrayElemAt: [
                        {
                          $filter: {
                            input: '$monthlyData',
                            as: 'month',
                            cond: {
                              $eq: ['$$month.month', '$$monthNumber'],
                            },
                          },
                        },
                        0,
                      ],
                    },
                  },
                  in: {
                    month: '$$monthNumber',
                    totalEarnings: {
                      $ifNull: ['$$monthData.totalEarnings', 0],
                    },
                    totalOrders: {
                      $ifNull: ['$$monthData.totalOrders', 0],
                    },
                  },
                },
              },
            },
          },
          totalRevenue: { $arrayElemAt: ['$totalRevenue.totalRevenue', 0] },
        },
      },
    ]);

    return {
      monthlyReport: data[0]?.monthlyReport || [],
      yearTotalRevenue: data[0]?.totalRevenue || 0,
    };
  }

  async getOrdersRevenuePerWeek() {
    const startOfWeek = new Date();
    const dayOfWeek = startOfWeek.getDay();

    startOfWeek.setDate(startOfWeek.getDate() - dayOfWeek);
    startOfWeek.setHours(0, 0, 0, 0);

    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 7);

    return this.ordersModel.aggregate([
      {
        $match: {
          createdAt: {
            $gte: startOfWeek,
            $lt: endOfWeek,
          },
          status: 'COMPLETED',
        },
      },
      {
        $group: {
          _id: { day: { $dayOfWeek: '$createdAt' } },
          totalEarnings: { $sum: '$totalPay' },
          totalOrders: { $sum: 1 },
        },
      },
      {
        $sort: { '_id.day': 1 },
      },
      {
        $project: {
          day: '$_id.day',
          totalEarnings: 1,
          totalOrders: 1,
          _id: 0,
        },
      },
      {
        $facet: {
          dailyData: [
            {
              $set: {
                day: '$day',
                totalEarnings: '$totalEarnings',
                totalOrders: '$totalOrders',
              },
            },
          ],
          allDays: [
            {
              $project: {
                days: Array.from({ length: 7 }, (_, i) => ({
                  day: i + 1,
                  totalEarnings: 0,
                  totalOrders: 0,
                })),
              },
            },
          ],
        },
      },
      {
        $project: {
          dailyReport: {
            $map: {
              input: { $range: [1, 8] },
              as: 'dayNumber',
              in: {
                $let: {
                  vars: {
                    dayData: {
                      $arrayElemAt: [
                        {
                          $filter: {
                            input: '$dailyData',
                            as: 'day',
                            cond: { $eq: ['$$day.day', '$$dayNumber'] },
                          },
                        },
                        0,
                      ],
                    },
                  },
                  in: {
                    day: '$$dayNumber',
                    totalEarnings: { $ifNull: ['$$dayData.totalEarnings', 0] },
                    totalOrders: { $ifNull: ['$$dayData.totalOrders', 0] },
                  },
                },
              },
            },
          },
        },
      },
      {
        $unwind: '$dailyReport',
      },
      {
        $replaceRoot: { newRoot: '$dailyReport' },
      },
    ]);
  }

  async getBikerTotalOrders(bikerId: string, status: string) {
    return await this.ordersModel.countDocuments({
      biker: bikerId,
      status: status,
    });
  }

  /**
   * Find orders that are in a specific status and created before a threshold time
   * @param status - Order status to filter by
   * @param createdBefore - Date threshold (orders created before this will be returned)
   * @returns Array of expired orders
   */
  async findExpiredPendingOrders(status: OrderStatus, createdBefore: Date) {
    return await this.ordersModel
      .find({
        status: status,
        createdAt: { $lt: createdBefore },
      })
      .select('_id status paymentStatus createdAt')
      .lean();
  }

  /**
   * Update order status and payment status
   * @param orderId - Order ID
   * @param updateData - Object containing status and/or paymentStatus
   */
  async updateOrderStatus(
    orderId: string,
    updateData: {
      status?: OrderStatus;
      paymentStatus?: MoyasarPaymentStatus;
    },
  ) {
    return await this.ordersModel.findByIdAndUpdate(
      orderId,
      { $set: updateData },
      { new: true },
    );
  }
}
