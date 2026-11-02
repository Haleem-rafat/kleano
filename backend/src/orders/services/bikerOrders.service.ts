import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import {
  BikerScheduleModel,
  bikerScheduleModelName,
  Day,
} from 'src/biker-schedule/schemas/biker-schedule.schema';
import { CommissionType } from 'src/bikers/schemas/bikers.schema';
import { MethodNotAllowedResponse } from 'src/common/errors';
import { ForbiddenResponse } from 'src/common/errors/ForbiddenResponse';
import { PointService } from 'src/points/services/point.service';
import { User } from 'src/user/schemas/user.schema';
import { BikersService } from '../../bikers/services/bikers.service';
import { FirebaseService } from '../../common/services/firebase/firebase.service';
import { PaginationService } from '../../common/services/pagination/pagination.service';
import { LocationsService } from '../../locations/services/locations.service';
import { NotificationsService } from '../../notifications/services/notifications.service';
import { UserService } from '../../user/user.service';
import { AcceptOrderDTO } from '../dtos/acceptOrder.dto';
import { GetOrdersDTO } from '../dtos/getOrders.dto';
import { OrderGateway } from '../gateway/order.gateway';
import { OrdersRepository } from '../repositories/orders.repository';
import { Order, OrderStatus } from '../schemas/orders.schema';
import { OrderStatusValidator } from '../validators/orderStatusValidator';

@Injectable()
export class BikerOrdersService {
  constructor(
    private ordersRepository: OrdersRepository,
    private orderGateway: OrderGateway,
    private orderStatusValidator: OrderStatusValidator,
    private paginationService: PaginationService,
    private bikersService: BikersService,
    private locationsService: LocationsService,
    private userService: UserService,
    private notificationsService: NotificationsService,
    private pointService: PointService,
    private firebaseService: FirebaseService,
    @InjectModel(bikerScheduleModelName)
    private readonly bikerScheduleModel: Model<BikerScheduleModel>,
  ) {}

  async acceptOrderByBiker(bikerId: string, acceptOrderDTO: AcceptOrderDTO) {
    const order = await this.ordersRepository.findOrderByIdOr404(
      acceptOrderDTO.order,
    );

    const userOfOrder = await this.userService.getUser(order.user.toString());

    this.orderStatusValidator.isStatusValidForOrder(
      order,
      OrderStatus.ACCEPTED_BY_BIKER,
    );

    const biker = await this.bikersService.updateBikerLocation(bikerId, {
      latitude: Number(acceptOrderDTO.latitude),
      longitude: Number(acceptOrderDTO.longitude),
      subAdministrativeArea: acceptOrderDTO.subAdministrativeArea,
      streetName: acceptOrderDTO.streetName,
    });

    await this.ordersRepository.update(acceptOrderDTO.order, {
      biker: bikerId,
      status: OrderStatus.ACCEPTED_BY_BIKER,
    });

    await this.orderGateway.orderAcceptedByBikerEventHandler(
      acceptOrderDTO.order,
      order.user.toString(),
    );

    await this.notificationsService.sendOrderAcceptedByBikerNotificaiton(
      userOfOrder._id.toString(),
      userOfOrder.language || 'en',
      userOfOrder.fcmTokens,
      biker.userName,
      acceptOrderDTO.order,
      userOfOrder.isAllowNotification,
    );
  }

  async orderOnTheWay(bikerId: string, orderId: string) {
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);
    this.orderStatusValidator.isStatusValidForOrder(
      order,
      OrderStatus.BIKER_ON_THE_WAY,
    );
    const userOfOrder = await this.userService.getUser(order.user.toString());

    await this.ordersRepository.update(orderId, {
      status: OrderStatus.BIKER_ON_THE_WAY,
      OnTheWayAt: new Date(),
    });
    //  Emit order to user using socket streaming
    await this.orderGateway.orderOnTheWayEventHandler(
      orderId,
      order.user.toString(),
    );

    //  Send Notification to the user of order
    await this.notificationsService.sendBikerOnTheWayNotificaiton(
      userOfOrder._id.toString(),
      userOfOrder.language || 'en',
      userOfOrder.fcmTokens,
      order._id.toString(),
      userOfOrder.isAllowNotification,
    );
  }

  async bikerArrived(bikerId: string, orderId: string) {
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);
    this.orderStatusValidator.isStatusValidForOrder(
      order,
      OrderStatus.BIKER_ARRIVED,
    );
    const userOfOrder = await this.userService.getUser(order.user.toString());

    await this.ordersRepository.update(orderId, {
      status: OrderStatus.BIKER_ARRIVED,
    });
    //  Emit order to user using socket streaming
    await this.orderGateway.bikerArrivedEventHandler(
      orderId,
      order.user.toString(),
    );

    //  Send Notification to the user of order
    await this.notificationsService.sendBikerArrivedNotification(
      userOfOrder._id.toString(),
      userOfOrder.language || 'en',
      userOfOrder.fcmTokens,
      order._id.toString(),
      userOfOrder.isAllowNotification,
    );
  }

  async cancelOrderByBiker(bikerId: string, orderId: string) {
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);

    // Check access authorization for biker
    if (order.biker.toString() !== bikerId) {
      throw new ForbiddenResponse({
        ar: 'لا يمكنك إلغاء هذا الطلب',
        en: 'You cannot cancel this order',
      });
    }

    // Check if order can be cancelled (only certain statuses)
    const allowedStatuses: OrderStatus[] = [
      OrderStatus.ACCEPTED_BY_BIKER,
      OrderStatus.BIKER_ON_THE_WAY,
    ];

    if (!allowedStatuses.includes(order.status as OrderStatus)) {
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكن إلغاء الطلب في هذه المرحلة',
        en: 'Order cannot be cancelled at this stage',
      });
    }

    // Update order: set status to CANCELLED_BY_BIKER and remove biker
    await this.ordersRepository.update(orderId, {
      status: OrderStatus.CANCELLED_BY_BIKER,
      biker: null,
    });

    // Try to reassign to another biker (exclude the one who cancelled)
    const reassigned = await this.orderGateway.assignBikerToOrder(
      orderId,
      bikerId,
    );

    // If no biker found, mark as waiting for admin
    if (!reassigned) {
      await this.ordersRepository.update(orderId, {
        status: OrderStatus.WAITING_FOR_BIKER_BY_ADMIN,
      });

      // Notify admins
      try {
        // Use existing checkOrderAfterMins to notify admins
        // Note: This might send duplicate notifications, but ensures admins are aware
        const userOrdersService = this.orderGateway['usersOrdersService'];
        if (userOrdersService && userOrdersService.checkOrderAfterMins) {
          await userOrdersService.checkOrderAfterMins(
            orderId,
            order.user.toString(),
          );
        }
      } catch (e) {
        // Log error but don't fail the cancellation
        console.error('Failed to notify admins about cancelled order:', e);
      }
    }
  }

  async orderOnWashing(
    bikerId: string,
    orderId: string,
    image: Express.Multer.File,
  ) {
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);
    this.orderStatusValidator.isStatusValidForOrder(
      order,
      OrderStatus.ON_WASHING,
    );

    if (!image) {
      throw new MethodNotAllowedResponse({
        ar: 'يجب أن يكون لديك صورة للسيارة',
        en: 'You must have a photo of the car',
      });
    }

    const { fileLink, filePath } = await this.firebaseService.uploadImage(
      image,
    );

    await this.ordersRepository.update(orderId, {
      status: OrderStatus.ON_WASHING,
      onWashingAt: new Date(),
      carBeforeWashPath: filePath,
      carBeforeWashLink: fileLink,
    });
    // Emit order to user using socket streaming
    await this.orderGateway.orderOnWashingEventHandler(
      orderId,
      order.user.toString(),
    );
  }

  async orderCompleted(
    bikerId: string,
    orderId: string,
    image: Express.Multer.File,
  ) {
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);

    this.orderStatusValidator.isStatusValidForOrder(
      order,
      OrderStatus.COMPLETED,
    );

    if (!image) {
      throw new MethodNotAllowedResponse({
        ar: 'يجب أن يكون لديك صورة للسيارة',
        en: 'You must have a photo of the car',
      });
    }

    const { fileLink, filePath } = await this.firebaseService.uploadImage(
      image,
    );

    const userOfOrder = await this.userService.getUser(order.user.toString());

    const { commissionAmount, isWeekendForBiker } =
      await this.calculateBikerCommission(order);

    await this.ordersRepository.update(orderId, {
      status: OrderStatus.COMPLETED,
      endTime: new Date().toISOString(),
      carAfterWashPath: filePath,
      carAfterWashLink: fileLink,
      bikerCommission: commissionAmount,
      isWeekendForBiker: isWeekendForBiker,
    });
    //  Emit order to user using socket streaming
    await this.orderGateway.orderCompletedEventHandler(
      orderId,
      order.user.toString(),
    );

    //  Send Notification to the user of order
    await this.notificationsService.sendOrderCompletedNotification(
      userOfOrder._id.toString(),
      userOfOrder.language || 'en',
      userOfOrder.fcmTokens,
      order._id.toString(),
      userOfOrder.isAllowNotification,
    );

    // 🔹 Retrieve user's current points before upgrade
    const userBeforeUpdate = await this.userService.getUserById(
      String(order.user),
    );
    console.log(`User's points before update: ${userBeforeUpdate.points}`);

    const pointsToBeRewards = await this.pointService.calculateEarningPoints(
      order.totalPay,
    );

    await this.userService.userPointsUpgrade(
      String(order.user),
      pointsToBeRewards,
    );

    // 🔹 Retrieve user's points after upgrade
    const userAfterUpdate = await this.userService.getUserById(
      String(order.user),
    );
    console.log(`User's points after update: ${userAfterUpdate.points}`);

    // 🔹 Ensure points were updated successfully
    if (
      userAfterUpdate.points !==
      userBeforeUpdate.points + pointsToBeRewards
    ) {
      console.warn(
        `⚠️ Points upgrade mismatch! Expected: ${
          userBeforeUpdate.points + pointsToBeRewards
        }, Found: ${userAfterUpdate.points}`,
      );
    } else {
      console.log(`✅ Points successfully upgraded by ${pointsToBeRewards}`);
    }
  }

  //FIXME: Check locations valid for query
  async getAllBikerOrders(bikerId: string, getOrdersDTO: GetOrdersDTO) {
    const biker = await this.bikersService.getById(bikerId);
    const { skip, limit } = this.paginationService.getSkipAndLimit(
      Number(getOrdersDTO.page),
      Number(getOrdersDTO.perPage),
    );

    const locations = await this.locationsService.getAllLocationsInBikerAreas(
      biker.areas,
    );

    const { orders, count } = await this.ordersRepository.findAllBikerOrders(
      bikerId,
      getOrdersDTO.status,
      skip,
      limit,
      locations,
    );

    return this.paginationService.paginate(
      orders,
      count,
      Number(getOrdersDTO.page),
      Number(getOrdersDTO.perPage),
    );
  }

  async rateUser(bikerId: string, orderId: string, starsNum: number) {
    // Check order status
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);

    //  Check access authorization for biker
    if (order.biker.toString() != bikerId)
      throw new ForbiddenResponse({
        ar: 'لا يمكنك اجراء التقييم',
        en: 'You Can Not Rate Biker',
      });

    //  Check rating applied by biker for same order
    if (order.ratingOfUser)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك اجراء التقييم',
        en: 'You Can Not Rate Biker',
      });

    if (order.status !== OrderStatus.COMPLETED)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك اجراء التقييم',
        en: 'You Can Not Rate Biker',
      });

    // rate user
    order.ratingOfUser = starsNum;
    await order.save();

    const { average } = await this.calculateAverageRateForUser(order.user);

    // update user average rating
    const user = await this.userService.getUser(order.user.toString());

    user.rating = Number(average);
    await user.save();
  }

  async getBikerTotalOrders(bikerId: string, status: string) {
    return await this.ordersRepository.getBikerTotalOrders(bikerId, status);
  }

  async getBikerTotalCommission(bikerId: string) {
    // Get start and end of today
    const startOfToday = new Date();
    startOfToday.setHours(0, 0, 0, 0);

    const endOfToday = new Date();
    endOfToday.setHours(23, 59, 59, 999);

    // Get today's completed orders with commission
    const todayOrders = await this.ordersRepository.findManyQuery({
      biker: bikerId,
      status: OrderStatus.COMPLETED,
      endTime: {
        $gte: startOfToday,
        $lte: endOfToday,
      },
    });

    // Get all time completed orders with commission
    const allTimeOrders = await this.ordersRepository.findManyQuery({
      biker: bikerId,
      status: OrderStatus.COMPLETED,
    });

    const weekendOrders = await this.ordersRepository.findManyQuery({
      biker: bikerId,
      status: OrderStatus.COMPLETED,
      isWeekendForBiker: true,
    });

    // Calculate today's total commission
    const todayTotalCommission = todayOrders.reduce((total, order) => {
      return total + (order.bikerCommission || 0);
    }, 0);

    // Calculate all time total commission
    const allTimeTotalCommission = allTimeOrders.reduce((total, order) => {
      return total + (order.bikerCommission || 0);
    }, 0);

    const weekendTotalCommission = weekendOrders.reduce((total, order) => {
      return total + (order.bikerCommission || 0);
    }, 0);

    return {
      today: {
        totalCommission: Number(todayTotalCommission.toFixed(2)),
        ordersCount: todayOrders.length,
      },
      allTime: {
        totalCommission: Number(allTimeTotalCommission.toFixed(2)),
        ordersCount: allTimeOrders.length,
      },
      allWeekends: {
        totalCommission: Number(weekendTotalCommission.toFixed(2)),
        ordersCount: weekendOrders.length,
      },
    };
  }

  async calculateBikerCommission(order: Order) {
    const biker = await this.bikersService.getById(order.biker);
    const commissionType = biker.commissionType;
    let commissionAmount = 0;

    // Check biker schedule first to determine if it's a weekend
    const bikerSchedule = await this.bikerScheduleModel.findOne({
      biker: biker.id,
    });

    if (!bikerSchedule) {
      return {
        commissionAmount: commissionAmount.toFixed(2),
        isWeekendForBiker: false,
      };
    }

    // Map day number (0=Sunday, 1=Monday, ..., 6=Saturday) to Day enum
    const dayNames: Day[] = [
      Day.SUNDAY,
      Day.MONDAY,
      Day.TUESDAY,
      Day.WEDNESDAY,
      Day.THURSDAY,
      Day.FRIDAY,
      Day.SATURDAY,
    ];
    const currentDay = dayNames[new Date().getDay()];
    const isbikerWeekend = bikerSchedule.weekends.includes(currentDay);

    // Only validate ordersBeforeCommission if it's NOT the biker's weekend
    if (!isbikerWeekend) {
      // Get start and end of today
      const startOfToday = new Date();
      startOfToday.setHours(0, 0, 0, 0);

      const endOfToday = new Date();
      endOfToday.setHours(23, 59, 59, 999);

      const bikerOrders = await this.ordersRepository.findManyQuery({
        biker: order.biker,
        status: OrderStatus.COMPLETED,
        endTime: {
          $gte: startOfToday,
          $lte: endOfToday,
        },
      });

      // If biker hasn't completed enough orders, no commission
      if (
        biker.ordersBeforeCommission > 0 &&
        biker.ordersBeforeCommission <= bikerOrders.length
      ) {
        return {
          commissionAmount: commissionAmount.toFixed(2),
          isWeekendForBiker: false,
        };
      }
    }

    // Determine the commission rate based on weekend status
    const commissionRate = isbikerWeekend
      ? biker.weekendCommission
      : biker.commission;

    // Calculate commission based on commission type
    if (commissionType === CommissionType.PERCENTAGE) {
      commissionAmount = (order.totalPay * commissionRate) / 100;

      // Apply minimum commission if needed
      if (commissionAmount < biker.minimumCommission) {
        commissionAmount = biker.minimumCommission;
      }
    } else {
      commissionAmount = commissionRate;
    }

    return {
      commissionAmount: commissionAmount.toFixed(2),
      isWeekendForBiker: isbikerWeekend,
    };
  }

  private async calculateAverageRateForUser(userId: string | User) {
    const listOfRate = await this.ordersRepository.getUserRatedOrders(userId);
    const count: number = listOfRate.length;
    const sumOfRate = listOfRate.reduce(
      (prev: number, curr: Order) => prev + curr.ratingOfUser,
      0,
    );
    const avg = sumOfRate / count;

    const avgTwoDecimal = Number(avg.toFixed(0));

    return { average: avgTwoDecimal };
  }

  private formatDate(date) {
    date.toISOString().split('T')[0];
  }
}
