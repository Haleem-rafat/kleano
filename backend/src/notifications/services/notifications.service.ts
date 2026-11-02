import {
  Inject,
  Injectable,
  NotFoundException,
  forwardRef,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import mongoose, { Model, Types } from 'mongoose';
import { BikersService } from 'src/bikers/services/bikers.service';
import { FcmTopics, NotificationsType } from 'src/common/enums/topics.enum';
import { OrdersRepository } from 'src/orders/repositories/orders.repository';
import { AdminsOrdersService } from 'src/orders/services/adminOrders.service';
import { PromoCodesService } from 'src/promo-code/services/promo-code.service';
import { SegmentsService } from 'src/segments/services/segments.service';
import { FCMService } from '../../common/services/firebase/fcm.service';
import { PaginationService } from '../../common/services/pagination/pagination.service';
import { UserService } from '../../user/user.service';
import { NotifcationsPaginationsDTO } from '../dtos/notificationsPaginations.dto';
import {
  NotificationsModel,
  notificationsModelName,
} from '../schemas/notifications.schema';
import {
  Notification,
  NotificationsMessages,
} from './notifications-message.service';

@Injectable()
export class NotificationsService {
  constructor(
    @InjectModel(notificationsModelName)
    private readonly notificationsModel: Model<NotificationsModel>,
    @Inject(forwardRef(() => PromoCodesService))
    private promoCodeService: PromoCodesService,
    private fcmService: FCMService,
    @Inject(forwardRef(() => UserService)) private userService: UserService,
    @Inject(forwardRef(() => BikersService))
    private bikersService: BikersService,
    private paginationService: PaginationService,
    @Inject(forwardRef(() => AdminsOrdersService))
    private adminsOrdersService: AdminsOrdersService,
    private segmentsService: SegmentsService,
    private ordersRepository: OrdersRepository,
  ) {}

  async sendNewPromoCodeCreatedNotification(
    promoCode: string,
    discountPercentage?: number,
    discountFixedNumber?: number,
  ) {
    const newPromoCodeMsg = NotificationsMessages.newPromoCodePublished(
      promoCode,
      discountPercentage,
      discountFixedNumber,
    );

    await this.fcmService.pushNotificationToTopics({
      notification: newPromoCodeMsg['en'],
      topic: FcmTopics.PROMO_CODE_CREATED,
    });

    await this.saveTopicBasedNotification(
      NotificationsType.NEW_PROMO_CODE,
      newPromoCodeMsg,
    );
  }

  async sendNewPromoCodePublishedForNewComers(
    promoCode: string,
    discountPercentage?: number,
    discountFixedNumber?: number,
  ) {
    const newPromoCodeMsg = NotificationsMessages.newPromoCodePublished(
      promoCode,
      discountPercentage,
      discountFixedNumber,
    );

    const fcmTokens = [];

    const usersWithoutOrders = await this.getUsersWithoutOrders();

    // TODO: use bulkWrite to save docs
    for (const user of usersWithoutOrders) {
      fcmTokens.push(...user.fcmTokens);

      await this.saveNotification(
        user._id.toString(),
        newPromoCodeMsg,
        NotificationsType.NEW_PROMO_CODE,
      );
    }

    await this.fcmService.pushNotificationToMultiUser({
      notification: newPromoCodeMsg['en'],
      tokens: fcmTokens,
    });
  }

  async sendNewPromoCodePublishedForSegment(
    promoCode: string,
    discountPercentage?: number,
    discountFixedNumber?: number,
  ) {
    const newPromoCodeMsg = NotificationsMessages.newPromoCodePublished(
      promoCode,
      discountPercentage,
      discountFixedNumber,
    );

    const promoCodeDoc = await this.promoCodeService.getSegmentPromoByCode(
      promoCode,
    );

    if (!promoCodeDoc) {
      throw new NotFoundException({
        ar: 'لم يتم العثور على كود الخصم!',
        en: 'Promo code not found!',
      });
    }

    const { segment } = promoCodeDoc;

    const users = await this.segmentUsers(segment['_id']);

    const fcmTokens = [];

    // TODO: use bulkWrite to save docs
    for (const user of users) {
      fcmTokens.push(...user.fcmTokens);

      await this.saveNotification(
        user._id.toString(),
        newPromoCodeMsg,
        NotificationsType.NEW_PROMO_CODE,
      );
    }

    await this.fcmService.pushNotificationToMultiUser({
      notification: newPromoCodeMsg['en'],
      tokens: fcmTokens,
    });
  }

  async sendNewPromoCodePublishedForAggregatorUsers(
    promoCode: string,
    discountPercentage?: number,
    discountFixedNumber?: number,
  ) {
    const newPromoCodeMsg = NotificationsMessages.newPromoCodePublished(
      promoCode,
      discountPercentage,
      discountFixedNumber,
    );

    const promoCodeDoc = await this.promoCodeService.getAggregatorByCode(
      promoCode,
    );

    if (!promoCodeDoc) {
      throw new NotFoundException({
        ar: 'لم يتم العثور على كود الخصم!',
        en: 'Promo code not found!',
      });
    }

    const { expressionLeftSide, operator, expressionRightSide } = promoCodeDoc;

    const users = await this.aggregatorUsers(
      expressionLeftSide,
      operator,
      expressionRightSide,
    );

    const fcmTokens = [];

    // TODO: use bulkWrite to save docs
    for (const user of users) {
      fcmTokens.push(...user.fcmTokens);

      await this.saveNotification(
        user._id.toString(),
        newPromoCodeMsg,
        NotificationsType.NEW_PROMO_CODE,
      );
    }

    await this.fcmService.pushNotificationToMultiUser({
      notification: newPromoCodeMsg['en'],
      tokens: fcmTokens,
    });
  }

  async sendOrderAcceptedByBikerNotificaiton(
    userId: string,
    userLang: string,
    userFcmTokens: string[],
    bikerName: string,
    orderId: string,
    userAllowNotification: boolean,
  ) {
    const orderAcceptedByBikerMessage =
      NotificationsMessages.orderAcceptedByBikerMessage(
        bikerName,
        orderId,
        userId,
      );

    let fcmResponse: any;
    if (userAllowNotification) {
      fcmResponse = await this.fcmService.pushNotificationToDeviceGroup({
        notification: orderAcceptedByBikerMessage[userLang || 'en'],
        data: orderAcceptedByBikerMessage.data,
        tokens: userFcmTokens,
      });
    }

    await this.saveNotification(
      userId,
      orderAcceptedByBikerMessage,
      NotificationsType.ORDER_TRACKING,
    );

    await this.checkFcmResponse(fcmResponse, userId, userFcmTokens, 'user');
  }

  async sendBikerOnTheWayNotificaiton(
    userId: string,
    userLang: string,
    userFcmTokens: string[],
    orderId: string,
    userAllowNotification: boolean,
  ) {
    const bikerOnTheWayMessage = NotificationsMessages.bikerOntheWayMessage(
      orderId,
      userId,
    );

    let fcmResponse: any;
    if (userAllowNotification) {
      fcmResponse = await this.fcmService.pushNotificationToDeviceGroup({
        notification: bikerOnTheWayMessage[userLang || 'en'],
        data: bikerOnTheWayMessage.data,
        tokens: userFcmTokens,
      });
    }
    await this.saveNotification(
      userId,
      bikerOnTheWayMessage,
      NotificationsType.ORDER_TRACKING,
    );

    await this.checkFcmResponse(fcmResponse, userId, userFcmTokens, 'user');
  }

  async sendBikerArrivedNotification(
    receiverId: string,
    userLang: string,
    userFcmTokens: string[],
    orderId: string,
    userAllowNotification: boolean,
  ) {
    const bikerArrivedMessage = NotificationsMessages.bikerArrivedMessage(
      orderId,
      receiverId,
    );

    let fcmResponse: any;
    if (userAllowNotification)
      fcmResponse = await this.fcmService.pushNotificationToDeviceGroup({
        notification: bikerArrivedMessage[userLang || 'en'],
        data: bikerArrivedMessage.data,
        tokens: userFcmTokens,
      });

    await this.saveNotification(
      receiverId,
      bikerArrivedMessage,
      NotificationsType.ORDER_TRACKING,
    );

    await this.checkFcmResponse(fcmResponse, receiverId, userFcmTokens, 'user');
  }

  async sendOrderCompletedNotification(
    receiverId: string,
    userLang: string,
    userFcmTokens: string[],
    orderId: string,
    userAllowNotification: boolean,
  ) {
    const orderCompletedMsg = NotificationsMessages.orderCompletedMessage(
      orderId,
      receiverId,
    );

    let fcmResponse: any;
    if (userAllowNotification)
      fcmResponse = await this.fcmService.pushNotificationToDeviceGroup({
        notification: orderCompletedMsg[userLang || 'en'],
        data: orderCompletedMsg.data,
        tokens: userFcmTokens,
      });

    await this.saveNotification(
      receiverId,
      orderCompletedMsg,
      NotificationsType.ORDER_COMPLETED,
    );

    await this.checkFcmResponse(fcmResponse, receiverId, userFcmTokens, 'user');
  }

  async sendOrderUnderReviewNotification(
    receiverId: string,
    userLang: string,
    userFcmTokens: string[],
    orderId: string,
    userAllowNotification: boolean,
  ) {
    const orderUnderReviewMsg = NotificationsMessages.orderUnderReviewMessage(
      orderId,
      receiverId,
    );

    let fcmResponse: any;
    if (userAllowNotification)
      fcmResponse = await this.fcmService.pushNotificationToDeviceGroup({
        notification: orderUnderReviewMsg[userLang || 'en'],
        data: orderUnderReviewMsg.data,
        tokens: userFcmTokens,
      });

    await this.saveNotification(
      receiverId,
      orderUnderReviewMsg,
      NotificationsType.ORDER_WAITING_FOR_ADMIN,
    );

    await this.checkFcmResponse(fcmResponse, receiverId, userFcmTokens, 'user');
  }

  async sendOrderCancelledNotification(
    receiverId: string,
    userLang: string,
    userFcmTokens: string[],
    orderId: string,
    userAllowNotification: boolean,
  ) {
    const orderCancelledMsg = NotificationsMessages.orderCancelledMessage(
      orderId,
      receiverId,
    );

    let fcmResponse: any;
    if (userAllowNotification)
      fcmResponse = await this.fcmService.pushNotificationToDeviceGroup({
        notification: orderCancelledMsg[userLang || 'en'],
        data: orderCancelledMsg.data,
        tokens: userFcmTokens,
      });

    await this.saveNotification(
      receiverId,
      orderCancelledMsg,
      NotificationsType.ORDER_CANCELLED_BY_USER,
    );

    console.log(
      `notification comes from sendOrderCancelledNotification` +
        orderCancelledMsg,
    );

    await this.checkFcmResponse(fcmResponse, receiverId, userFcmTokens, 'user');
  }

  async sendOrderCancelledByAdminNotification(
    receiverId: string,
    userLang: string,
    userFcmTokens: string[],
    orderId: string,
    userAllowNotification: boolean,
  ) {
    const orderCancelledMsg = NotificationsMessages.orderCancelledMessage(
      orderId,
      receiverId,
    );

    let fcmResponse: any;
    if (userAllowNotification)
      fcmResponse = await this.fcmService.pushNotificationToDeviceGroup({
        notification: orderCancelledMsg[userLang || 'en'],
        data: orderCancelledMsg.data,
        tokens: userFcmTokens,
      });

    await this.saveNotification(
      receiverId,
      orderCancelledMsg,
      NotificationsType.ORDER_CANCELLED_BY_ADMIN,
    );

    console.log(
      `notification comes from sendOrderCancelledNotification` +
        orderCancelledMsg,
    );

    await this.checkFcmResponse(fcmResponse, receiverId, userFcmTokens, 'user');
  }

  async sendOrderRefundFailedNotification(
    receiverId: string,
    userLang: string,
    userFcmTokens: string[],
    orderId: string,
    userAllowNotification: boolean,
  ) {
    const orderRefundFailedMsg = NotificationsMessages.orderRefundFailedMessage(
      orderId,
      receiverId,
    );

    let fcmResponse: any;
    if (userAllowNotification)
      fcmResponse = await this.fcmService.pushNotificationToDeviceGroup({
        notification: orderRefundFailedMsg[userLang || 'en'],
        data: orderRefundFailedMsg.data,
        tokens: userFcmTokens,
      });

    await this.saveNotification(
      receiverId,
      orderRefundFailedMsg,
      NotificationsType.ORDER_REFUND_FAILED,
    );
    console.log(
      `notification comes from sendOrderRefundFailedNotification` +
        orderRefundFailedMsg,
    );

    await this.checkFcmResponse(fcmResponse, receiverId, userFcmTokens, 'user');
  }

  async sendAdminAssignedOrderToBikerNotification(
    receiverId: string,
    userLang: string,
    userFcmTokens: string[],
    orderId: string,
  ) {
    const assignOrderToBikerByAdminMsg =
      NotificationsMessages.assignOrderToBikerByAdminMessage(
        orderId,
        receiverId,
      );

    const fcmResponse = await this.fcmService.pushNotificationToDeviceGroup({
      notification: assignOrderToBikerByAdminMsg[userLang || 'en'],
      data: assignOrderToBikerByAdminMsg.data,
      tokens: userFcmTokens,
    });
    await this.saveNotification(receiverId, assignOrderToBikerByAdminMsg);

    await this.checkFcmResponse(
      fcmResponse,
      receiverId,
      userFcmTokens,
      'biker',
    );
  }

  async sendNewOrderToBikerNotification(
    receiverId: string,
    bikerLang: string,
    bikerFcmTokens: string[],
    orderId: string,
  ) {
    const newOrderMsg = NotificationsMessages.newOrderCreated(
      orderId,
      receiverId,
    );

    const fcmResponse = await this.fcmService.pushNotificationToDeviceGroup({
      notification: newOrderMsg[bikerLang || 'en'],
      data: newOrderMsg.data,
      tokens: bikerFcmTokens,
    });
    await this.saveNotification(receiverId, newOrderMsg);

    await this.checkFcmResponse(
      fcmResponse,
      receiverId,
      bikerFcmTokens,
      'biker',
    );
  }

  async sendPendingOrderToAdminNotification(
    adminsIds: string[],
    orderId: string,
  ) {
    const orderPendingAdminAssignMsg =
      NotificationsMessages.orderPendingAdminAssign(orderId);

    adminsIds.forEach(async (adminId) => {
      await this.saveNotification(adminId, orderPendingAdminAssignMsg);
    });
  }

  async sendCancellingOrderToAdminNotification(
    adminsIds: string[],
    orderId: string,
  ) {
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);

    const orderCancellingAdminAssignMsg =
      NotificationsMessages.orderCancellingAdminAssign(order);

    adminsIds.forEach(async (adminId) => {
      await this.saveNotification(adminId, orderCancellingAdminAssignMsg);
      console.log(
        `from sendCancellingOrderToAdminNotification` +
          orderCancellingAdminAssignMsg,
      );
    });
  }

  async saveNotification(
    receiverId: string,
    message: Notification,
    type?: NotificationsType,
  ) {
    await this.notificationsModel.create({
      receiver: new mongoose.Types.ObjectId(receiverId),
      receiverModel: message.data.receiverModel,
      clickableItem: new mongoose.Types.ObjectId(message.data.clickableItem),
      clickableItemModel: message.data.clickItemModel,
      'message.arTitle': message.ar.title,
      'message.arBody': message.ar.body,
      'message.enTitle': message.en.title,
      'message.enBody': message.en.body,
      type: type,
    });
  }

  async saveTopicBasedNotification(type: string, message: Notification) {
    await this.notificationsModel.create({
      'message.arTitle': message.ar.title,
      'message.arBody': message.ar.body,
      'message.enTitle': message.en.title,
      'message.enBody': message.en.body,
      type: type,
    });
  }

  async setNotificationIsRead(notificationId: string) {
    await this.notificationsModel.findByIdAndUpdate(notificationId, {
      $set: { isRead: true },
    });
  }

  async getAllNotificationsForReceiver(
    receiverId: string,
    role: string,
    notifcationsPaginationsDTO: NotifcationsPaginationsDTO,
  ) {
    const { skip, limit } = this.paginationService.getSkipAndLimit(
      Number(notifcationsPaginationsDTO.page),
      Number(notifcationsPaginationsDTO.perPage),
    );

    let userCreatedDate: Date;
    if (role === 'user')
      userCreatedDate = (await this.userService.getUserById(receiverId))
        .createdAt;

    const notifications = await this.notificationsModel
      .find({
        ...(role === 'user'
          ? {
              $or: [
                { receiver: new Types.ObjectId(receiverId) },
                {
                  $and: [
                    { createdAt: { $gte: userCreatedDate.toISOString() } },
                    { receiver: null },
                  ],
                },
              ],
            }
          : { receiver: new Types.ObjectId(receiverId) }),
      })
      .skip(skip)
      .limit(limit)
      .sort({ createdAt: -1 });
    const count = await this.notificationsModel.countDocuments({
      ...(role === 'user'
        ? {
            $or: [
              { receiver: new Types.ObjectId(receiverId) },
              {
                $and: [
                  { createdAt: { $gte: userCreatedDate.toISOString() } },
                  { receiver: null },
                ],
              },
            ],
          }
        : { receiver: new Types.ObjectId(receiverId) }),
    });
    const totalUnRead = await this.notificationsModel.countDocuments({
      ...(role === 'user'
        ? {
            $or: [
              { receiver: new Types.ObjectId(receiverId) },
              {
                $and: [
                  { createdAt: { $gte: userCreatedDate.toISOString() } },
                  { receiver: null },
                ],
              },
            ],
          }
        : { receiver: new Types.ObjectId(receiverId) }),
      isRead: false,
    });

    const paginationResult = this.paginationService.paginate(
      notifications,
      count,
      Number(notifcationsPaginationsDTO.page),
      Number(notifcationsPaginationsDTO.perPage),
    );

    return {
      paginationResult,
      totalUnRead,
    };
  }
  async checkFcmResponse(
    response: any,
    receiverId: string,
    tokens: string[],
    role: string,
  ) {
    // if response includes token error
    if (response?.failureCount > 0) {
      console.log(response);
      console.log(tokens);

      // iterate and get the invalid one then remove it
      for (let i = 0; i < response.responses.length; i++) {
        if (!response.responses[i].success) {
          if (
            response.responses[i].error.code ===
              'messaging/registration-token-not-registered' ||
            response.responses[i].error.code === 'messaging/invalid-argument' ||
            response.responses[i].error.code ===
              'messaging/invalid-registration-token'
          ) {
            console.log(response.responses[i]);
            console.log(tokens[i] + ' is invalid then remove it');

            // Call appropriate service based on role
            if (role === 'biker') {
              await this.bikersService.removeInvalidFcmTokenForBiker(
                receiverId,
                tokens[i],
              );
            } else {
              await this.userService.removeInvalidFcmToken(
                receiverId,
                tokens[i],
              );
            }
          }
        }
      }
    }
  }

  async newlyRegisteredUsers() {
    const newUsersDocs = await this.userService.getAllNewUsers();
    return newUsersDocs;
  }

  async getUsersWithoutOrders() {
    return await this.userService.getUsersWithoutOrders();
  }

  async aggregatorUsers(
    expressionLeftSide: string,
    operator: string,
    expressionRightSide: number,
  ) {
    const users =
      await this.adminsOrdersService.findAllUsersWithOrdersAggregator(
        expressionLeftSide,
        operator,
        expressionRightSide,
      );
    return users;
  }

  async segmentUsers(segmentId: string) {
    const users = (await this.segmentsService.getOneByIdForPromoCode(segmentId))
      .users;

    return users;
  }
}
