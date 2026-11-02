import { forwardRef, Inject, Logger, OnModuleInit } from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { InjectModel } from '@nestjs/mongoose';
import {
  OnGatewayConnection,
  OnGatewayDisconnect,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import { Model, Types } from 'mongoose';
import { Server, Socket } from 'socket.io';
import { BikerStatus } from 'src/bikers/schemas/bikers.schema';
import { AuthService } from '../../auth/auth.service';
import { getAssignmentDayFromOrderStartTime } from '../../biker-schedule/utils/saudi-assignment-day.util';
import {
  BikerScheduleModel,
  bikerScheduleModelName,
} from '../../biker-schedule/schemas/biker-schedule.schema';
import { NotificationsService } from '../../notifications/services/notifications.service';
import { UserService } from '../../user/user.service';
import {
  BIKER_TIMESLOT_OCCUPIED_ORDER_STATUSES,
  OrdersModel,
  ordersModelName,
  OrderStatus,
} from '../schemas/orders.schema';
import { UsersOrdersService } from '../services/userOrders.service';

@WebSocketGateway()
export class OrderGateway
  implements OnGatewayConnection, OnGatewayDisconnect, OnModuleInit
{
  constructor(
    private authService: AuthService,
    @Inject(forwardRef(() => UsersOrdersService))
    private usersOrdersService: UsersOrdersService,
    private userService: UserService,
    @InjectModel(bikerScheduleModelName)
    private readonly bikerScheduleModel: Model<BikerScheduleModel>,
    @InjectModel(ordersModelName)
    private readonly ordersModel: Model<OrdersModel>,
    private readonly eventEmitter: EventEmitter2,
    private readonly notificationsService: NotificationsService,
  ) {}
  @WebSocketServer()
  server: Server;
  private logger: Logger = new Logger('OrderGateway');

  onModuleInit() {
    this.logger.log('WebSocket Initialized ...');
  }

  handleDisconnect(socket: Socket) {
    socket.disconnect();
  }
  async handleConnection(socket: Socket) {
    const userPayload = this.authService.authenticateSocketUser(socket);
    if (!userPayload?.id) return;
    const user = await this.authService.getUserByIdAndRole(
      userPayload.id,
      userPayload.role,
    );
    if (user) {
      // Inject user into socket
      socket.data.user = user;
      // Update SocketId
      await this.authService.updateUserSocketId(
        userPayload.id,
        userPayload.role,
        socket.id,
      );
    } else {
      this.disconnect(socket);
    }
  }
  private disconnect(socket: Socket) {
    socket.disconnect();
  }

  orderFormaterForUser(event: string, order: any) {
    return {
      success: true,
      _id: order._id,
      status: order.status,
      ...(event === 'order:accepted'
        ? { biker: { ...order.toObject().biker } }
        : {}),
      ...(event === 'order:arrived'
        ? { duration: order.totalDuration }
        : { time: order.updatedAt }),
    };
  }

  /**
   * Find and assign the best available biker for an order
   * @param orderId - The order ID to assign
   * @param excludeBikerId - Optional biker ID to exclude from assignment (for reassignment)
   * @returns true if assignment succeeded, false otherwise
   */
  async assignBikerToOrder(
    orderId: string,
    excludeBikerId?: string,
  ): Promise<boolean> {
    const publishedOrder = await this.usersOrdersService.getOrderByIdPopulated(
      orderId,
    );

    // Get timeSlot and day from order
    const timeSlot = publishedOrder.timeSlot;
    const bookingDate: Date = publishedOrder.bookingDate;

    // Validate required fields
    if (!timeSlot) {
      this.logger.error(
        `[assignBikerToOrder] FAILED: Order ${orderId} missing timeSlot`,
      );
      return false;
    }

    if (!bookingDate) {
      this.logger.error(
        `[assignBikerToOrder] FAILED: Order ${orderId} missing bookingDate`,
      );
      return false;
    }

    if (!publishedOrder.location?.city || !publishedOrder.location?.area) {
      this.logger.error(
        `[assignBikerToOrder] FAILED: Order ${orderId} missing location data (city: ${publishedOrder.location?.city}, area: ${publishedOrder.location?.area})`,
      );
      return false;
    }

    const bookingDateStr = bookingDate.toISOString().slice(0, 10); // YYYY-MM-DD

    // Same helper as user biker schedule: day from startTime (see saudi-assignment-day.util).
    const dayEnum = getAssignmentDayFromOrderStartTime(
      publishedOrder.startTime as any,
    );

    const cityId = new Types.ObjectId(
      (publishedOrder.location.city as any)._id || publishedOrder.location.city,
    );
    const areaId = new Types.ObjectId(
      (publishedOrder.location.area as any)._id || publishedOrder.location.area,
    );

    this.logger.log(
      `[assignBikerToOrder] Order: ${orderId} | TimeSlot: ${timeSlot} | Date: ${bookingDateStr} | Day: ${dayEnum} | City: ${cityId} | Area: ${areaId} | PaymentType: ${publishedOrder.paymentType}`,
    );

    // Helper: check biker availability (by date and timeSlot only)
    const isBikerFree = async (bikerId: Types.ObjectId) => {
      const existingOrder = await this.ordersModel
        .aggregate([
          {
            $match: {
              biker: bikerId,
              status: { $in: BIKER_TIMESLOT_OCCUPIED_ORDER_STATUSES },
              timeSlot: timeSlot,
            },
          },
          {
            $addFields: {
              bookingDateStr: {
                $dateToString: { format: '%Y-%m-%d', date: '$bookingDate' },
              },
            },
          },
          {
            $match: {
              bookingDateStr: bookingDateStr,
            },
          },
          {
            $limit: 1,
          },
        ])
        .exec();

      return existingOrder.length === 0;
    };

    let selectedBikerSocket: string | null = null;
    let selectedBikerId: Types.ObjectId | null = null;
    let selectedBikerFcmTokens: string[] = [];
    let selectedBikerLanguage = 'ar';

    const excludeBikerObjectId = excludeBikerId
      ? new Types.ObjectId(excludeBikerId)
      : null;

    // Try priorities 1..3
    for (let priority = 1; priority <= 3 && !selectedBikerId; priority++) {
      // Find bikers having matching shift at this slot/location/day and priority
      const matchStage: any = {
        'shifts.timeSlot': timeSlot,
        'shifts.city': cityId,
        'shifts.area': areaId,
        'shifts.day': dayEnum,
        'shifts.priorityLevel': priority,
      };

      // Exclude the biker who cancelled (if provided)
      if (excludeBikerObjectId) {
        matchStage.biker = { $ne: excludeBikerObjectId };
      }

      const candidates = await this.bikerScheduleModel.aggregate([
        { $unwind: '$shifts' },
        { $match: matchStage },
        {
          $lookup: {
            from: 'bikers',
            localField: 'biker',
            foreignField: '_id',
            as: 'bikerInfo',
            pipeline: [
              {
                $match: {
                  status: { $ne: BikerStatus.SUSPENDED },
                  isDeleted: false,
                },
              },
              {
                $project: {
                  _id: 1,
                  socketId: 1,
                  latitude: 1,
                  longitude: 1,
                  fcmTokens: 1,
                  language: 1,
                },
              },
            ],
          },
        },
        { $unwind: '$bikerInfo' },
        {
          $project: {
            bikerId: '$bikerInfo._id',
            socketId: '$bikerInfo.socketId',
            lat: '$bikerInfo.latitude',
            lng: '$bikerInfo.longitude',
            fcmTokens: '$bikerInfo.fcmTokens',
            language: '$bikerInfo.language',
          },
        },
      ]);

      this.logger.log(
        `[assignBikerToOrder] Priority ${priority}: Found ${candidates.length} candidate(s)`,
      );

      // Filter free bikers
      const free: {
        bikerId: Types.ObjectId;
        socketId?: string | null;
        lat: number;
        lng: number;
        fcmTokens: string[];
        language: string;
      }[] = [];

      for (const c of candidates) {
        if (!(await isBikerFree(c.bikerId))) {
          this.logger.log(
            `[assignBikerToOrder] Biker ${c.bikerId} skipped: busy with another order`,
          );
        } else {
          free.push(c);
        }
      }

      this.logger.log(
        `[assignBikerToOrder] Priority ${priority}: ${free.length} biker(s) available`,
      );

      if (free.length === 0) continue;

      // Sort by bikerId for consistency and pick the first one
      free.sort((a, b) => String(a.bikerId).localeCompare(String(b.bikerId)));
      selectedBikerSocket = free[0].socketId ?? null;
      selectedBikerId = free[0].bikerId;
      selectedBikerFcmTokens = free[0].fcmTokens || [];
      selectedBikerLanguage = free[0].language || 'en';
      this.logger.log(
        `[assignBikerToOrder] Selected biker ${selectedBikerId} for order ${orderId}`,
      );
    }

    if (selectedBikerId) {
      if (selectedBikerSocket) {
        this.server
          .to(selectedBikerSocket)
          .emit('order:published', publishedOrder);
      }

      await this.ordersModel.updateOne(
        { _id: publishedOrder._id },
        {
          $set: {
            status: OrderStatus.ACCEPTED_BY_BIKER,
            biker: selectedBikerId,
          },
        },
      );

      // Send push notification to the assigned biker
      if (selectedBikerFcmTokens.length > 0) {
        try {
          await this.notificationsService.sendNewOrderToBikerNotification(
            String(selectedBikerId),
            selectedBikerLanguage,
            selectedBikerFcmTokens,
            orderId,
          );
          this.logger.log(
            `[assignBikerToOrder] Notification sent to biker ${selectedBikerId}`,
          );
        } catch (error) {
          this.logger.error(
            `[assignBikerToOrder] Failed to send notification to biker ${selectedBikerId}: ${error.message}`,
          );
        }
      }

      this.logger.log(
        `[assignBikerToOrder] SUCCESS: Order ${orderId} assigned to biker ${selectedBikerId}`,
      );
      return true;
    }

    this.logger.warn(
      `[assignBikerToOrder] FAILED: No available bikers found for order ${orderId}`,
    );
    return false;
  }

  async orderPublishedEventHandler(order: string) {
    const assigned = await this.assignBikerToOrder(order);

    if (assigned) {
      // Send email to admin after successful biker assignment
      if (process.env.NODE_ENV === 'prod') {
        this.eventEmitter.emit('order:email', { orderId: order });
      }
      return;
    }

    // Fallback: no biker found → mark waiting for admin and notify admins
    try {
      const publishedOrder =
        await this.usersOrdersService.getOrderByIdPopulated(order);

      await this.usersOrdersService.checkOrderAfterMins(
        String(publishedOrder._id),
        String((publishedOrder.user as any)._id || publishedOrder.user),
      );
      // Send email to admin after fallback to waiting for admin
      if (process.env.NODE_ENV === 'prod') {
        this.eventEmitter.emit('order:email', { orderId: order });
      }
    } catch (e) {
      this.logger.error(
        'Failed fallback to WAITING_FOR_BIKER_BY_ADMIN',
        e as any,
      );
    }
  }

  async orderAcceptedByBikerEventHandler(order: string, userId: string) {
    const listenerUser = await this.userService.getUser(userId);
    const acceptedOrder = await this.usersOrdersService.getOrderByIdPopulated(
      order,
    );
    const formatedOrder = this.orderFormaterForUser(
      'order:accepted',
      acceptedOrder,
    );
    this.server.to(listenerUser.socketId).emit('order:accepted', formatedOrder);
  }
  async orderOnTheWayEventHandler(order: string, userId: string) {
    const listenerUser = await this.userService.getUser(userId);
    const onTheWayOrder = await this.usersOrdersService.getOrderByIdPopulated(
      order,
    );
    const formatedOrder = this.orderFormaterForUser(
      'order:on-the-way',
      onTheWayOrder,
    );

    this.server
      .to(listenerUser.socketId)
      .emit('order:on-the-way', formatedOrder);
  }
  async bikerArrivedEventHandler(order: string, userId: string) {
    const listenerUser = await this.userService.getUser(userId);
    const arrivedOrder = await this.usersOrdersService.getOrderByIdPopulated(
      order,
    );
    const formatedOrder = this.orderFormaterForUser(
      'order:arrived',
      arrivedOrder,
    );

    this.server.to(listenerUser.socketId).emit('order:arrived', formatedOrder);
  }
  async orderOnWashingEventHandler(order: string, userId: string) {
    const listenerUser = await this.userService.getUser(userId);
    const onWashingOrder = await this.usersOrdersService.getOrderByIdPopulated(
      order,
    );
    const formatedOrder = this.orderFormaterForUser(
      'order:on-washing',
      onWashingOrder,
    );
    this.server
      .to(listenerUser.socketId)
      .emit('order:on-washing', formatedOrder);
  }
  async orderCompletedEventHandler(order: string, userId: string) {
    const listenerUser = await this.userService.getUser(userId);
    const completedOrder = await this.usersOrdersService.getOrderByIdPopulated(
      order,
    );
    const formatedOrder = this.orderFormaterForUser(
      'order:completed',
      completedOrder,
    );
    this.server
      .to(listenerUser.socketId)
      .emit('order:completed', formatedOrder);
  }
}
