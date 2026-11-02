import { HttpService } from '@nestjs/axios';
import {
  BadRequestException,
  ConflictException,
  Inject,
  Injectable,
  forwardRef,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { InjectConnection } from '@nestjs/mongoose';
import { Connection, HydratedDocument, Types } from 'mongoose';
import { AddOnsService } from 'src/add-ons/services/add-ons.service';
import { AdminService } from 'src/admin/admin.service';
import { Biker } from 'src/bikers/schemas/bikers.schema';
import { BikersService } from 'src/bikers/services/bikers.service';
import { ForbiddenResponse } from 'src/common/errors/ForbiddenResponse';
import { NotificationsService } from 'src/notifications/services/notifications.service';
import { PaymentsRepository } from 'src/payments/repositories/payments.repository';
import {
  MoyasarPaymentStatus,
  MoyasarSupportedCurrency,
} from 'src/payments/schemas/payments.schema';
import { PointService } from 'src/points/services/point.service';
import {
  CreateCheckoutSessionDto,
  ItemDto,
  TamaraSupportedCurrency,
} from 'src/tamara/dto/create-checkout-session.dto';
import { TamaraService } from 'src/tamara/services/tamara.service';
import { TabbyService } from '../../common/services/tabby.service';
import { ServiceType } from 'src/washing-services/schemas/washing-services.schema';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';
import { PaginationService } from '../../common/services/pagination/pagination.service';
import { Location } from '../../locations/schemas/location.schema';
import { LocationsService } from '../../locations/services/locations.service';
import { PlansService } from '../../plans/services/plans.service';
import { PromoCodesService } from '../../promo-code/services/promo-code.service';
import { SubscriptionsService } from '../../subscriptions/services/subscriptions.service';
import { User } from '../../user/schemas/user.schema';
import { UserService } from '../../user/user.service';
import { WashingServicesService } from '../../washing-services/services/washing-services.service';
import { GetOrdersDTO } from '../dtos/getOrders.dto';
import { OrderCreationDTO } from '../dtos/OrderCreation.dto';
import { OrderGateway } from '../gateway/order.gateway';
import { OrdersRepository } from '../repositories/orders.repository';
import {
  Order,
  OrderStatus,
  OrderTypes,
  PaymentTypes,
} from '../schemas/orders.schema';
import { OrderStatusValidator } from '../validators/orderStatusValidator';

@Injectable()
export class UsersOrdersService {
  constructor(
    @InjectConnection() private readonly connection: Connection,

    private ordersRepository: OrdersRepository,
    private paymentsRepository: PaymentsRepository,
    private userService: UserService,
    private locationsService: LocationsService,
    private washingServicesService: WashingServicesService,
    @Inject(forwardRef(() => SubscriptionsService))
    private subscriptionsService: SubscriptionsService,
    private plansService: PlansService,
    private orderStatusValidator: OrderStatusValidator,
    private promoCodesService: PromoCodesService,
    private paginationService: PaginationService,
    private readonly httpService: HttpService,
    @Inject(forwardRef(() => OrderGateway))
    private orderGateway: OrderGateway,
    private notificationService: NotificationsService,
    private adminService: AdminService,
    private bikersService: BikersService,
    private pointService: PointService,
    private addOnsService: AddOnsService,
    @Inject(forwardRef(() => TamaraService))
    private tamaraService: TamaraService,
    @Inject(forwardRef(() => TabbyService))
    private tabbyService: TabbyService,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  //FIXME: Check order creation for order with subscription plan only
  async createOrder(userId: string, orderCreationDTO: OrderCreationDTO) {
    // Get User
    const user = await this.userService.getUserById(userId);

    // Validate add-ons stock before creating order
    if (orderCreationDTO.addOns && orderCreationDTO.addOns.length > 0) {
      await this.validateAddOnsStock(orderCreationDTO.addOns);
    }

    // Set order location
    const location = await this.locationsService.createOrderLocationOrGetIt(
      user,
      this.locationObjectFormat(orderCreationDTO),
    );

    let result;
    switch (orderCreationDTO.type) {
      case OrderTypes.SERVICE_BOOKING:
        result = await this.createServicesOrder(
          user,
          orderCreationDTO,
          location,
        );
        break;
      case OrderTypes.SUBSCRIPTION_BOOKING:
        result = await this.createSubscriptionOrder(
          user,
          orderCreationDTO,
          location,
        );
        break;
    }

    // Decrement stock for add-ons after successful order creation
    if (orderCreationDTO.addOns && orderCreationDTO.addOns.length > 0) {
      await this.decrementAddOnsStock(orderCreationDTO.addOns);
    }

    return result;
  }

  async createServicesOrder(
    user: User,
    orderCreationDTO: OrderCreationDTO,
    location: Location,
  ) {
    // Validate payment type for non-free orders
    this.paymentTypeValidator(orderCreationDTO.paymentType);

    // Validate totalPrice for SERVICE_BOOKING orders
    await this.validateTotalPriceForServiceBooking(
      orderCreationDTO,
      orderCreationDTO.type,
    );

    // Calculate totalDuration for washingServices
    const totalDuration =
      await this.washingServicesService.getTotalDurationForWashingServices(
        orderCreationDTO.washingServices,
      );

    const washingServices = orderCreationDTO.washingServices;
    let mainServiceCounter = 0;

    for (const service of washingServices) {
      const serviceDoc =
        await this.washingServicesService.getWashingServiceById(
          service.toString(),
        );

      if (serviceDoc.type === ServiceType.MAIN) {
        mainServiceCounter++;
      }

      if (mainServiceCounter > 1) {
        throw new BadRequestException({
          success: false,
          message: {
            ar: 'يمكن اختيار خدمة رئيسية واحدة فقط',
            en: 'Only one main service can be chosen',
          },
        });
      }
    }

    // Set initial status to PENDING_USER_PAYMENT
    const initialStatus = OrderStatus.PENDING_USER_PAYMENT;

    const createdOrder = await this.ordersRepository.create(
      user,
      orderCreationDTO,
      location,
      totalDuration,
      initialStatus,
      orderCreationDTO.washingServices,
    );

    if (orderCreationDTO.code) {
      const userIdForPromo = (
        (user as any)?._id || (user as any)?.id
      )?.toString();
      await this.applyPromoCodeForOrder(
        userIdForPromo,
        createdOrder.id,
        orderCreationDTO.code,
      );
    }

    // Apply points if provided
    if (orderCreationDTO.appliedPoints) {
      const userIdForPoints = (
        (user as any)?._id || (user as any)?.id
      )?.toString();

      await this.applyPointsToOrder(
        userIdForPoints,
        createdOrder.id,
        orderCreationDTO.appliedPoints,
      );
    }

    // Recalculate totalPay after promo code and points application and check if it's free
    const recalculatedOrder = await this.ordersRepository.findOrderByIdOr404(
      createdOrder.id,
    );

    await recalculatedOrder.populate(this.ordersRepository.populatedPaths);

    if (recalculatedOrder.totalPay === 0) {
      await this.processFreeOrder(recalculatedOrder);
    }

    recalculatedOrder.user = undefined;

    return {
      createdOrder: recalculatedOrder,
      redeemLimit: (await this.pointService.getPointsSystem()).redeemLimit,
    };
  }

  paymentTypeValidator(paymentType: string) {
    if (!paymentType)
      throw new MethodNotAllowedResponse({
        ar: 'قم باختيار طريقة الدفع',
        en: 'Choose Payment Type',
      });

    if (
      paymentType !== PaymentTypes.CREDIT &&
      paymentType !== PaymentTypes.WALLET &&
      paymentType !== PaymentTypes.SUBSCRIBED &&
      paymentType !== PaymentTypes.APPLE_PAY &&
      paymentType !== PaymentTypes.FREE &&
      paymentType !== PaymentTypes.TAMARA &&
      paymentType !== PaymentTypes.TABBY
    )
      throw new MethodNotAllowedResponse({
        ar: 'قم باختيار طريقة الدفع صالحة',
        en: 'Choose Valid Payment Type',
      });
  }

  async createSubscriptionOrder(
    user: User,
    orderCreationDTO: OrderCreationDTO,
    location: Location,
  ) {
    const userSubscription =
      await this.subscriptionsService.isUserHasSubscription(user);

    if (!userSubscription)
      throw new MethodNotAllowedResponse({
        ar: 'لا يوجد لديك اشتراكات',
        en: 'You Have No Subscription',
      });

    if (!userSubscription.remainingWashes)
      throw new MethodNotAllowedResponse({
        ar: 'لقد بلغت الحد الاقصي للاستخدام من الباقة',
        en: 'You Have No Remaining Washes',
      });

    const hasExtraServicesOrAddOns =
      this.isOrderHasExtraServicesOrAddOns(orderCreationDTO);

    // Check if order is free (no extra services/addons)
    const isFreeOrder = !hasExtraServicesOrAddOns;

    if (hasExtraServicesOrAddOns) {
      this.paymentTypeValidator(orderCreationDTO.paymentType);
    }

    const plan = await this.plansService.getPlanById(userSubscription.plan);

    // Calculate totalDuration for washingServices
    const totalDuration =
      await this.washingServicesService.getTotalDurationForWashingServices([
        ...(orderCreationDTO.washingServices
          ? orderCreationDTO.washingServices
          : []),
        ...plan.washingServices,
      ]);

    const createdOrder = await this.ordersRepository.create(
      user,
      orderCreationDTO,
      location,
      totalDuration,
      hasExtraServicesOrAddOns
        ? OrderStatus.PENDING_USER_PAYMENT
        : OrderStatus.PENDING_USER_REVIEW,
      [
        ...(orderCreationDTO.washingServices
          ? orderCreationDTO.washingServices
          : []),
        ...plan.washingServices,
      ],
    );

    if (orderCreationDTO.code) {
      const userIdForPromo = (
        (user as any)?._id || (user as any)?.id
      )?.toString();
      await this.applyPromoCodeForOrder(
        userIdForPromo,
        createdOrder.id,
        orderCreationDTO.code,
      );
    }

    // Apply points if provided
    if (orderCreationDTO.appliedPoints) {
      const userIdForPoints = (
        (user as any)?._id || (user as any)?.id
      )?.toString();

      await this.applyPointsToOrder(
        userIdForPoints,
        createdOrder.id,
        orderCreationDTO.appliedPoints,
      );
    }

    await createdOrder.populate(this.ordersRepository.populatedPaths);

    createdOrder.user = undefined;

    // Recalculate totalPay after promo code and points application and check if it's free
    const recalculatedOrder = await this.ordersRepository.findOrderByIdOr404(
      createdOrder.id,
    );
    if (isFreeOrder || recalculatedOrder.totalPay === 0) {
      await this.processFreeOrder(recalculatedOrder);
    }
    return {
      createdOrder,
      redeemLimit: (await this.pointService.getPointsSystem()).redeemLimit,
    };
  }

  isOrderHasExtraServicesOrAddOns(orderCreationDTO: OrderCreationDTO) {
    return orderCreationDTO.washingServices?.length ||
      orderCreationDTO.addOns?.length
      ? true
      : false;
  }

  locationObjectFormat(orderCreationDTO: OrderCreationDTO) {
    return {
      latitude: Number(orderCreationDTO.location.latitude),
      longitude: Number(orderCreationDTO.location.longitude),
      streetName: orderCreationDTO.location.streetName,
      subAdministrativeArea: orderCreationDTO.location.subAdministrativeArea,
      country: orderCreationDTO.location.country,
    };
  }

  async getAllUserOrders(userId: string, getOrdersDTO: GetOrdersDTO) {
    // Get User
    const user = await this.userService.getUserById(userId);

    const { skip, limit } = this.paginationService.getSkipAndLimit(
      Number(getOrdersDTO.page),
      Number(getOrdersDTO.perPage),
    );
    const { orders, count } = await this.ordersRepository.findAllUserOrders(
      user,
      getOrdersDTO.status,
      skip,
      limit,
    );

    return this.paginationService.paginate(
      orders,
      count,
      Number(getOrdersDTO.page),
      Number(getOrdersDTO.perPage),
    );
  }

  async getOrderByIdPopulated(orderId: string) {
    return await this.ordersRepository.findOrderByIdPopulatedOr404(orderId);
  }

  async getOrderById(orderId: string) {
    return await this.ordersRepository.findOrderByIdOr404(orderId);
  }

  async cancelOrderByUser(orderId: string, userId: string) {
    const session = await this.connection.startSession();
    try {
      session.startTransaction({ readPreference: 'primary' });
      const order = await this.ordersRepository.findOrderByIdOr404(orderId);

      this.orderStatusValidator.isStatusValidForOrder(
        order,
        OrderStatus.CANCELLED_BY_USER,
      );

      // 🚀 **Check time restriction only if the order is paid**
      if (
        order.paymentType &&
        order.paymentStatus === 'PAID' &&
        order.startTime
      ) {
        const currentTime = new Date();
        const startTime = new Date(order.startTime);
        const hoursDifference =
          (startTime.getTime() - currentTime.getTime()) / (1000 * 60 * 60);

        if (hoursDifference < 4) {
          throw new BadRequestException({
            success: false,
            message: {
              en: 'Cancellation is only allowed at least 4 hours before the booking time.',
              ar: 'الإلغاء مسموح فقط قبل 4 ساعات على الأقل من وقت الحجز.',
            },
          });
        }
      }

      // 🚀 **Process Refund if Paid with Credit Card**
      if (order.paymentType === 'CREDIT' && order.paymentStatus === 'PAID') {
        const payment = await this.paymentsRepository.findOne({
          order: new Types.ObjectId(orderId),
        });

        console.log(`payment with the order` + payment);
        if (payment && payment.transactionId) {
          await this.processRefund(
            payment.transactionId,
            payment.totalAmount,
            orderId,
          );
          order.refundAmount = payment.totalAmount;
        }
      }

      if (
        order.paymentType === PaymentTypes.TAMARA &&
        order.paymentStatus === 'PAID'
      ) {
        const payment = await this.paymentsRepository.findOne({
          order: new Types.ObjectId(orderId),
        });

        console.log(`payment with the order` + payment);
        if (payment && payment.transactionId) {
          await this.tamaraProcessRefund(
            payment.transactionId,
            payment.totalAmount,
            orderId,
          );
          order.refundAmount = payment.totalAmount;
        }
      }

      // 🔹 **Refund points if they were applied**
      if (order.appliedPoints > 0) {
        await this.userService.userPointsUpgrade(
          String(order.user),
          order.appliedPoints,
        );

        // **Reset Points Fields in Order**
        order.isPointsApplied = false; // ✅ Reset flag
        order.appliedPoints = 0; // ✅ Reset points count
        order.pointsDiscount = 0; // ✅ Reset points count
      }

      if (order.type && order.type === OrderTypes.SUBSCRIPTION_BOOKING) {
        const userSubscription =
          await this.subscriptionsService.isUserHasSubscription(order.user);

        if (!userSubscription)
          throw new BadRequestException({
            success: false,
            message: {
              ar: 'لا يوجد لديك اشتراكات',
              en: 'You Have No Subscription',
            },
          });

        await this.subscriptionsService.incrementUserRemainingWashes(
          (userSubscription as any)._id,
        );
      }

      order.status = OrderStatus.CANCELLED_BY_USER;
      order.cancellationDate = new Date();
      await order.save();

      const user = await this.userService.getUser(userId);
      const adminsIds = await this.adminService.getAllAdminInCity(
        order.location.city,
      );

      await this.notificationService.sendCancellingOrderToAdminNotification(
        adminsIds,
        orderId,
      );

      await this.notificationService.sendOrderCancelledNotification(
        userId,
        user.language || 'en',
        user.fcmTokens,
        orderId,
        user.isAllowNotification,
      );

      await session.commitTransaction();

      return {
        order,
        message:
          user.language === 'en'
            ? 'Order has been successfully cancelled.'
            : 'تم إلغاء الطلب بنجاح.',
      };
    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  }

  private async processRefund(
    transactionId: string,
    amount: number,
    orderId: string,
  ) {
    try {
      const response = await this.httpService.axiosRef.post(
        `https://api.moyasar.com/v1/payments/${transactionId}/refund`,
        {
          amount: amount * 100, // Convert to halalas
          statement_descriptor: 'KleanO',
          display_name: 'KleanO',
        },
        {
          auth: {
            username: process.env.API_SECRET_KEY,
            password: '',
          },
        },
      );

      if (process.env.NODE_ENV === 'prod') {
        this.eventEmitter.emit('order.cancelled', {
          orderId,
          refundAmount: amount,
        });
      }

      console.log('Refund successful:', response.data);
      return response.data;
    } catch (error) {
      console.error('Refund Error:', error.response?.data || error);
      throw new ConflictException({
        ar: 'فشل في معالجة الاسترداد.',
        en: 'Failed to process refund.',
      });
    }
  }

  private async tamaraProcessRefund(
    transactionId: string,
    amount: number,
    orderId: string,
  ) {
    const devUrl = `https://api-sandbox.tamara.co/payments/simplified-refund/${transactionId}`;
    const prodUr = `https://api.tamara.co/payments/simplified-refund/${transactionId}`;

    try {
      const response = await this.httpService.axiosRef.post(
        process.env.NODE_ENV === 'prod' ? prodUr : devUrl,
        {
          total_amount: {
            amount: amount,
            currency: 'SAR',
          },
          comment: 'order cancelled by user',
        },
        {
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            Authorization: `Bearer ${
              process.env.NODE_ENV === 'prod'
                ? process.env.TAMARA_API_KEY_PROD
                : process.env.TAMARA_API_KEY_DEV
            }`,
          },
        },
      );

      if (process.env.NODE_ENV === 'prod') {
        this.eventEmitter.emit('order.cancelled', {
          orderId,
          refundAmount: amount,
        });
      }

      console.log('Refund successful:', response.data);
      return response.data;
    } catch (error) {
      console.error('Refund Error:', error.response?.data || error);
      throw new ConflictException({
        ar: 'فشل في معالجة الاسترداد.',
        en: 'Failed to process refund.',
      });
    }
  }

  async applyUserPoints(userId: string, orderId: string) {
    const user = await this.userService.getUserById(userId);

    await this.isCurrentPointsValidForRedeem(user.points);

    const order = await this.ordersRepository.findOrderByIdOr404(orderId);

    if (order.isPointsApplied)
      throw new MethodNotAllowedResponse({
        ar: 'لقد قمت باستخدام النقاط',
        en: 'Points is already applied',
      });

    if (order.promoCode)
      throw new MethodNotAllowedResponse({
        ar: 'تم استخدام كود خصم مسبقاً لهذا الطلب',
        en: 'A promo code has already been applied to this order',
      });

    const { newTotalPay, numberOfRemainsPoints, deductedPoints } =
      await this.getTotalPayAfterPointsApplied(user.points, order.totalPay);

    // 🔹 Calculate the discount amount
    const pointsDiscount =
      order.totalPay - (newTotalPay <= 0 ? 0 : newTotalPay);

    const updatedOrder = await this.ordersRepository.update(orderId, {
      totalPay: newTotalPay <= 0 ? 0 : newTotalPay,
      isPointsApplied: true,
      appliedPoints: deductedPoints,
      pointsDiscount, // ✅ Save discount amount
    });

    await updatedOrder.populate(this.ordersRepository.populatedPaths);

    updatedOrder.user = undefined;

    await this.userService.updateUserPointsAfterApplied(
      userId,
      numberOfRemainsPoints,
    );

    return {
      _id: updatedOrder._id,
      totalPay: updatedOrder.totalPay,
      totalPrice: updatedOrder.totalPrice,
      pointsDiscount: updatedOrder.pointsDiscount, // ✅ Include in response
    };
  }

  async getTotalPayAfterPointsApplied(points: number, totalPay: number) {
    const pointsExchange = await this.pointService.calculatePointsExchange(
      points,
    );
    const newTotalPay = totalPay - pointsExchange;

    let numberOfRemainsPoints = 0;
    let deductedPoints = points; // Assume full deduction initially

    // 🔹 If more points were provided than needed, adjust deduction
    if (pointsExchange > totalPay) {
      numberOfRemainsPoints = (points * totalPay) / pointsExchange;
      deductedPoints = points - numberOfRemainsPoints; // Actual points deducted
    }

    return { newTotalPay, numberOfRemainsPoints, deductedPoints };
  }

  async isCurrentPointsValidForRedeem(points: number) {
    const redeemLimit = (await this.pointService.getPointsSystem()).redeemLimit;
    if (points < redeemLimit)
      throw new MethodNotAllowedResponse({
        ar: `الحد الادني من عدد النقاط للاستخدام ${redeemLimit}`,
        en: 'You must exceeds the redeem limit',
      });
  }

  async applyPromoCodeForOrder(userId: string, orderId: string, code: string) {
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);
    const user = await this.userService.getUserById(userId);
    const promoCode = await this.promoCodesService.getByCode(code);

    if (!promoCode)
      throw new MethodNotAllowedResponse({
        ar: 'لا يوجد هذا الكود',
        en: 'Promo Code Not Exist',
      });

    if (order.promoCode)
      throw new MethodNotAllowedResponse({
        ar: 'تم استخدام كود خصم مسبقاً لهذا الطلب',
        en: 'A promo code has already been applied to this order',
      });

    if (order.isPointsApplied)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك استخدام كود الخصم عند تطبيق النقاط',
        en: 'You cannot use a promo code when points are applied',
      });

    const { totalPayAfterDiscount, discountAmount } =
      await this.getTotalPayAfterPromoCode(code, order.totalPrice, user);

    const updatedOrder = await this.ordersRepository.update(orderId, {
      totalPay: totalPayAfterDiscount,
      promoCode: promoCode,
      discount: discountAmount,
    });

    await updatedOrder.populate(this.ordersRepository.populatedPaths);

    updatedOrder.user = undefined;

    return {
      _id: updatedOrder._id,
      discount: updatedOrder.discount,
      totalPay: updatedOrder.totalPay,
      totalPrice: updatedOrder.totalPrice,
    };
  }

  async getTotalPayAfterPromoCode(
    code: string,
    totalPrice: number,
    user: User,
  ) {
    const totalPay = totalPrice;

    const promoCode = await this.promoCodesService.getByCode(code);

    if (!promoCode) {
      return {
        totalPayAfterDiscount: totalPay,
        discountAmount: 0,
      };
    }

    await this.promoCodesService.isValidPromoCode(promoCode, user);

    if (promoCode.discountPercentage) {
      const discountPercentage = promoCode.discountPercentage / 100;
      const discountAmount = Math.round(totalPay * discountPercentage);
      const totalPayAfterDiscount = Math.round(totalPay - discountAmount);
      return { totalPayAfterDiscount, discountAmount };
    } else if (promoCode.discountFixedNumber) {
      const discountAmount = Math.round(promoCode.discountFixedNumber);
      let totalPayAfterDiscount = totalPay - discountAmount;
      if (totalPay < discountAmount) {
        totalPayAfterDiscount = 0;
      } else {
        totalPayAfterDiscount = Math.round(totalPayAfterDiscount);
      }
      return { totalPayAfterDiscount, discountAmount };
    }

    return {
      totalPayAfterDiscount: totalPay,
      discountAmount: 0,
    };
  }

  async applyPointsToOrder(
    userId: string,
    orderId: string,
    appliedPoints: number,
  ) {
    const user = await this.userService.getUserById(userId);
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);

    // Validate user has enough points
    if (user.points < appliedPoints) {
      throw new MethodNotAllowedResponse({
        ar: 'ليس لديك نقاط كافية',
        en: 'You do not have enough points',
      });
    }

    // Validate minimum redeem limit
    await this.isCurrentPointsValidForRedeem(appliedPoints);

    // Calculate points discount on totalPrice (base price)
    const pointsDiscountAmount =
      await this.pointService.calculatePointsExchange(appliedPoints);

    // Calculate totalPay = totalPrice - discount - pointsDiscount (minimum 0)
    // Round to 2 decimal places to avoid floating point precision issues
    const totalPay = Number(
      Math.max(
        0,
        order.totalPrice - order.discount - pointsDiscountAmount,
      ).toFixed(2),
    );

    // Update order with points information
    await this.ordersRepository.update(orderId, {
      appliedPoints: appliedPoints,
      pointsDiscount: pointsDiscountAmount,
      isPointsApplied: true,
      totalPay: totalPay,
    });

    // Deduct points from user
    // await this.userService.updateUserPointsAfterApplied(
    //   userId,
    //   user.points - appliedPoints,
    // );

    return { pointsDiscountAmount, totalPay };
  }

  async payOrder(
    userId: string,
    orderId: string,
    paymentDetails?: {
      name: string;
      number: string;
      cvc: string;
      month: string;
      year: string;
    },
    paymentId?: string,
  ) {
    const pendingOrder = await this.ordersRepository.findOrderByIdOr404(
      orderId,
    );

    // this.orderStatusValidator.isStatusValidForOrder(
    //   pendingOrder,
    //   OrderStatus.ACTIVE,
    // );

    this.paymentTypeValidator(pendingOrder.paymentType);
    let paymentResponse;
    switch (pendingOrder.paymentType) {
      case PaymentTypes.APPLE_PAY:
        if (!paymentId) {
          throw new BadRequestException({
            ar: 'تفاصيل الدفع مطلوبة لمدفوعات Apple Pay.',
            en: 'Payment details are required for Apple Pay payments.',
          });
        }
        // paymentDetails = await this.getApplePayPaymentDetails(paymentId);
        break;
      case PaymentTypes.CREDIT:
        if (!paymentDetails) {
          throw new BadRequestException({
            ar: 'تفاصيل الدفع مطلوبة لمدفوعات البطاقة الائتمانية.',
            en: 'Payment details are required for credit card payments.',
          });
        }
        paymentResponse = await this.payCredit(orderId, paymentDetails);
        //Handle the case where paymentResponse is undefined or when it says payment has failed
        break;

      case PaymentTypes.WALLET:
        paymentResponse = await this.payWallet(userId, orderId);
        break;

      case PaymentTypes.SUBSCRIBED:
        paymentResponse = await this.paySubscribedOrder(
          orderId,
          paymentDetails,
        );
        break;

      case PaymentTypes.FREE:
        paymentResponse = await this.payFreeOrder(orderId);
        break;

      case PaymentTypes.TAMARA:
        paymentResponse = await this.payTamara(orderId);
        break;

      case PaymentTypes.TABBY:
        paymentResponse = await this.payTabby(orderId);
        break;

      default:
        throw new ConflictException({
          ar: 'نوع الدفع غير صالح.',
          en: 'Invalid payment type.',
        });
    }

    return {
      orderId: pendingOrder._id.toString(),
      ...paymentResponse,
    };
  }

  async payTamara(orderId: string) {
    const pendingOrder =
      await this.ordersRepository.findOrderByIdPopulatedOr404(orderId);

    if (pendingOrder.paymentType !== PaymentTypes.TAMARA)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك الدفع بواسطة تامارا',
        en: 'You could not pay using Tamara',
      });

    const washingServices = pendingOrder.washingServices.map((service) => {
      const serviceDoc = service as any; // Populated document has _id
      return {
        name: service.name,
        quantity: 1,
        reference_id: serviceDoc._id.toString(),
        type: 'Physical',
        sku: serviceDoc._id.toString(),
        unit_price: {
          amount: service.price,
          currency: TamaraSupportedCurrency.SAR,
        },
        total_amount: {
          amount: service.price,
          currency: TamaraSupportedCurrency.SAR,
        },
      };
    });

    const addOns = pendingOrder.addOns.map((addOn) => {
      const addOnDoc = addOn as any; // Populated document has _id
      return {
        name: addOn.name,
        quantity: 1,
        reference_id: addOnDoc._id.toString(),
        type: 'Physical',
        sku: addOnDoc._id.toString(),
        unit_price: {
          amount: addOn.price,
          currency: TamaraSupportedCurrency.SAR,
        },
        total_amount: {
          amount: addOn.price,
          currency: TamaraSupportedCurrency.SAR,
        },
      };
    });

    const cityRef = pendingOrder.location?.city as
      | { name?: { en?: string; ar?: string } }
      | Types.ObjectId
      | undefined;
    const localizedCityName =
      cityRef &&
      typeof cityRef === 'object' &&
      !(cityRef instanceof Types.ObjectId) &&
      cityRef.name &&
      typeof cityRef.name === 'object'
        ? cityRef.name.en || cityRef.name.ar
        : undefined;
    const tamaraShippingCity =
      (localizedCityName && String(localizedCityName).trim()) ||
      pendingOrder.location.subAdministrativeArea?.trim();
    if (!tamaraShippingCity) {
      throw new BadRequestException({
        ar: 'بيانات عنوان التوصيل ناقصة (المدينة).',
        en: 'Shipping address is missing a city name.',
      });
    }

    const payload: CreateCheckoutSessionDto = {
      total_amount: {
        amount: pendingOrder.totalPay,
        currency: TamaraSupportedCurrency.SAR,
      },
      shipping_amount: {
        amount: 0,
        currency: TamaraSupportedCurrency.SAR,
      },
      tax_amount: {
        amount: 0,
        currency: TamaraSupportedCurrency.SAR,
      },
      order_reference_id: pendingOrder._id.toString(),
      discount: {
        name: 'discount',
        amount: {
          amount: pendingOrder.discount,
          currency: TamaraSupportedCurrency.SAR,
        },
      },
      items: [...washingServices, ...addOns] as ItemDto[],
      consumer: {
        email: pendingOrder.user.email,
        first_name: pendingOrder.user.userName.split(' ')[0],
        last_name:
          pendingOrder.user.userName.split(' ')[1] ||
          pendingOrder.user.userName,
        phone_number: pendingOrder.user.phone,
      },
      country_code: 'SA',
      description: `Payment for Order #${pendingOrder._id}`,
      merchant_url: {
        cancel: `https://kleano.sa/orders?status=cancel`,
        failure: `https://kleano.sa/orders?status=failure`,
        success: `https://kleano.sa/orders?status=success`,
      },
      shipping_address: {
        city: tamaraShippingCity,
        country_code: 'SA',
        first_name: pendingOrder.user.userName.split(' ')[0],
        last_name:
          pendingOrder.user.userName.split(' ')[1] ||
          pendingOrder.user.userName,
        line1: pendingOrder.location.streetName,
      },
      is_mobile: true,
    };

    const tamaraResponse = await this.tamaraService.createCheckoutSession(
      payload,
    );

    return { paymentUrl: tamaraResponse.checkout_url };
  }

  async payTabby(orderId: string) {
    const pendingOrder =
      await this.ordersRepository.findOrderByIdPopulatedOr404(orderId);

    if (pendingOrder.paymentType !== PaymentTypes.TABBY)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك الدفع بواسطة تابي',
        en: 'You could not pay using Tabby',
      });

    const washingServiceItems = pendingOrder.washingServices.map((service) => {
      const serviceDoc = service as any;
      return {
        title:
          typeof service.name === 'object'
            ? (service.name as any).en || (service.name as any).ar || 'Service'
            : String(service.name),
        reference_id: serviceDoc._id.toString(),
        quantity: 1,
        unit_price: service.price.toFixed(2),
        category: 'Services',
      };
    });

    const addOnItems = pendingOrder.addOns.map((addOn) => {
      const addOnDoc = addOn as any;
      return {
        title:
          typeof addOn.name === 'object'
            ? (addOn.name as any).en || (addOn.name as any).ar || 'Add-on'
            : String(addOn.name),
        reference_id: addOnDoc._id.toString(),
        quantity: 1,
        unit_price: addOn.price.toFixed(2),
        category: 'Services',
      };
    });

    const cityRef = pendingOrder.location?.city as
      | { name?: { en?: string; ar?: string } }
      | Types.ObjectId
      | undefined;
    const localizedCityName =
      cityRef &&
      typeof cityRef === 'object' &&
      !(cityRef instanceof Types.ObjectId) &&
      cityRef.name &&
      typeof cityRef.name === 'object'
        ? cityRef.name.en || cityRef.name.ar
        : undefined;
    const shippingCity =
      (localizedCityName && String(localizedCityName).trim()) ||
      pendingOrder.location.subAdministrativeArea?.trim();
    if (!shippingCity) {
      throw new BadRequestException({
        ar: 'بيانات عنوان التوصيل ناقصة (المدينة).',
        en: 'Shipping address is missing a city name.',
      });
    }

    const payload = {
      payment: {
        amount: pendingOrder.totalPay.toFixed(2),
        currency: 'SAR',
        description: `Payment for Order #${pendingOrder._id}`,
        buyer: {
          name: pendingOrder.user.userName,
          email: pendingOrder.user.email,
          phone: pendingOrder.user.phone,
        },
        shipping_address: {
          city: shippingCity,
          address: pendingOrder.location.streetName || shippingCity,
          zip: '00000',
        },
        order: {
          reference_id: pendingOrder._id.toString(),
          items: [...washingServiceItems, ...addOnItems],
          discount_amount: (pendingOrder.discount || 0).toFixed(2),
          tax_amount: '0.00',
          shipping_amount: '0.00',
        },
        buyer_history: {
          registered_since: new Date().toISOString(),
          loyalty_level: 0,
        },
        order_history: [],
      },
      lang: 'en',
      merchant_code: this.tabbyService.getMerchantCode(),
      merchant_urls: {
        cancel: `orders?status=cancel`,
        failure: `orders?status=failure`,
        success: `orders?status=success`,
      },
    };

    const tabbyResponse = await this.tabbyService.createCheckoutSession(
      payload,
    );

    const webUrl =
      tabbyResponse?.configuration?.available_products?.installments?.[0]
        ?.web_url;

    if (!webUrl) {
      throw new ConflictException({
        ar: 'تابي غير متاح لهذا الطلب.',
        en: 'Tabby is not available for this order.',
      });
    }

    return { paymentUrl: webUrl };
  }

  async checkOrderAfterMins(orderId: string, userId: string) {
    const order = await this.ordersRepository.findOrderByIdPopulatedOr404(
      orderId,
    );
    if (order.status === OrderStatus.ACTIVE) {
      await this.ordersRepository.update(orderId, {
        status: OrderStatus.WAITING_FOR_BIKER_BY_ADMIN,
      });

      const user = await this.userService.getUser(userId);

      const adminsIds = await this.adminService.getAllAdminInCity(
        order.location.city,
      );

      await this.notificationService.sendPendingOrderToAdminNotification(
        adminsIds,
        orderId,
      );

      await this.notificationService.sendOrderUnderReviewNotification(
        userId,
        user.language || 'en',
        user.fcmTokens,
        orderId,
        user.isAllowNotification,
      );
    }
  }

  async getApplePayPaymentDetails(paymentId: string) {
    try {
      const response = await this.httpService.axiosRef.get(
        `https://api.moyasar.com/v1/payments/${paymentId}`,
        {
          auth: {
            username: process.env.API_SECRET_KEY,
            password: '',
          },
        },
      );

      console.log('Payment Details:', response.data);
      return response.data;
    } catch (error) {
      console.error('Payment Fetch Error:', error.response?.data || error);
      throw new BadRequestException({
        ar: 'فشل في جلب بيانات الدفع.',
        en: 'Failed to fetch payment.',
      });
    }
  }

  async payCredit(
    orderId: string,
    paymentDetails: {
      name: string;
      number: string;
      cvc: string;
      month: string;
      year: string;
    },
  ) {
    const pendingOrder = await this.ordersRepository.findOrderByIdOr404(
      orderId,
    );

    if (pendingOrder.paymentType !== PaymentTypes.CREDIT)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك الدفع ',
        en: 'You could not pay',
      });

    if (
      pendingOrder.type === OrderTypes.SUBSCRIPTION_BOOKING ||
      pendingOrder.subscription
    ) {
      await this.subscriptionsService.decrementUserRemainingWashes(
        pendingOrder.subscription,
      );
    }

    // await this.orderGateway.orderPublishedEventHandler(orderId);

    // Step 1: Initiate Moyasar Payment
    const moyasarResponse = await this.initiateMoyasarPayment(
      pendingOrder,
      paymentDetails,
    );

    if (!moyasarResponse || !moyasarResponse.id) {
      throw new ConflictException({
        ar: 'فشل بدء عملية الدفع.',
        en: 'Payment initiation failed.',
      });
    }

    console.log(moyasarResponse);

    // Return the payment URL for frontend redirection
    return { paymentUrl: moyasarResponse.source.transaction_url };
  }

  private async initiateMoyasarPayment(
    order: HydratedDocument<Order>,
    paymentDetails: {
      name: string;
      number: string;
      cvc: string;
      month: string;
      year: string;
    },
  ) {
    const DOMAIN_URL = process.env.DOMAIN_URL; // Ensure this is correctly set in your .env
    const callbackUrl = `${DOMAIN_URL}/payment-success?orderId=${order._id.toString()}`;
    const webhookUrl = `${DOMAIN_URL}/payments/webhook-listener`;

    const payload = {
      amount: order.totalPay * 100, // Convert to halalas
      currency: MoyasarSupportedCurrency.SAR,
      description: `Payment for Order #${order._id}`,
      callback_url: callbackUrl, // User is redirected here after payment
      webhook_url: webhookUrl, // Moyasar sends a POST request here
      statement_descriptor: 'KleanO',
      display_name: 'KleanO',
      source: {
        type: 'creditcard',
        ...paymentDetails, // Use dynamic payment details from the user
      },
      metadata: {
        orderId: order._id.toString(),
        userId: order.user.toString(),
        totalAmount: order.totalPay,
        createdAt: order.createdAt.toISOString(),
        orderType: order.type,
      },
    };

    try {
      const response = await this.httpService.axiosRef.post(
        'https://api.moyasar.com/v1/payments',
        payload,
        {
          auth: {
            username: process.env.API_SECRET_KEY,
            password: '',
          },
        },
      );

      return response.data;
    } catch (error) {
      console.error('Moyasar Payment Error:', error.response?.data || error);
      throw new ConflictException({
        ar: 'فشل في معالجة الدفع.',
        en: 'Failed to process payment.',
      });
    }
  }

  //TODO: Use Transactions to update user+subscription+order
  async payWallet(userId: string, orderId: string) {
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);
    const user = await this.userService.getUserById(userId);

    if (order.paymentType !== PaymentTypes.WALLET)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك الدفع بالمحفظة',
        en: 'You could not pay using wallet',
      });

    const IsUserWalletBalanceValid = this.userService.checkWalletBalanceValid(
      user,
      order.totalPay,
    );

    if (!IsUserWalletBalanceValid)
      throw new MethodNotAllowedResponse({
        ar: 'لا تحتوي محفظتك الإلكترونية علي هذا المبلغ',
        en: 'Your Wallet Balance Is Not Valid',
      });

    if (order.type === OrderTypes.SUBSCRIPTION_BOOKING || order.subscription) {
      await this.subscriptionsService.decrementUserRemainingWashes(
        order.subscription,
      );
    }

    // Decrement wallet from user
    await this.userService.payWithWallet(userId, order.totalPay);

    await this.ordersRepository.update(orderId, {
      status: OrderStatus.ACTIVE,
      paymentStatus: MoyasarPaymentStatus.PAID,
    });

    if (order.promoCode) {
      await this.promoCodesService.apply(user, order.promoCode);
    }

    // Deduct points from user if points are applied
    if (order.appliedPoints) {
      await this.userService.updateUserPointsAfterApplied(
        userId,
        user.points - order.appliedPoints,
      );
    }

    await this.orderGateway.orderPublishedEventHandler(orderId);
  }

  //TODO: Use Transactions to update subscription+order
  async paySubscribedOrder(
    orderId: string,
    paymentDetails: {
      name: string;
      number: string;
      cvc: string;
      month: string;
      year: string;
    },
  ) {
    const pendingOrder = await this.ordersRepository.findOrderByIdOr404(
      orderId,
    );

    const pendingOrderPop = await this.ordersRepository.findOrderByIdOr404(
      orderId,
    );

    if (pendingOrder.paymentType !== PaymentTypes.SUBSCRIBED)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك الدفع ',
        en: 'You could not pay',
      });

    await this.subscriptionsService.decrementUserRemainingWashes(
      pendingOrder.subscription,
    );

    // Check if order is free (no extra services/addons or totalPay is 0)
    const hasExtraServicesOrAddOns =
      pendingOrderPop.washingServices?.length || pendingOrderPop.addOns?.length;

    if (hasExtraServicesOrAddOns && pendingOrder.totalPay > 0) {
      const moyasarResponse = await this.initiateMoyasarPayment(
        pendingOrder,
        paymentDetails,
      );

      if (!moyasarResponse || !moyasarResponse.id) {
        throw new ConflictException({
          ar: 'فشل بدء عملية الدفع.',
          en: 'Payment initiation failed.',
        });
      }

      console.log(moyasarResponse.source.transaction_url);

      // Return the payment URL for frontend redirection
      return { paymentUrl: moyasarResponse.source.transaction_url };
    }

    // For free orders, update status to ACTIVE and mark as PAID
    if (pendingOrder.totalPay === 0) {
      await this.ordersRepository.update(orderId, {
        status: OrderStatus.ACTIVE,
        paymentStatus: MoyasarPaymentStatus.PAID,
      });

      await this.orderGateway.orderPublishedEventHandler(orderId);

      // Apply promo code if one is attached to the order
      if (pendingOrder.promoCode) {
        const user = await this.userService.getUserById(
          pendingOrder.user.toString(),
        );
        await this.promoCodesService.apply(user, pendingOrder.promoCode);
      }
    }

    return { paymentUrl: '' };
  }

  getTotalPayAfterWallet(order: Order, walletAmount: number) {
    return order.totalPay - walletAmount;
  }

  async payFreeOrder(orderId: string) {
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);

    if (order.paymentType !== PaymentTypes.FREE)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك الدفع',
        en: 'You could not pay',
      });

    if (order.totalPay !== 0)
      throw new MethodNotAllowedResponse({
        ar: 'هذا الطلب ليس مجاني',
        en: 'This order is not free',
      });

    // Handle subscription decrement if applicable
    if (order.type === OrderTypes.SUBSCRIPTION_BOOKING || order.subscription) {
      await this.subscriptionsService.decrementUserRemainingWashes(
        order.subscription,
      );
    }

    // Update order status to ACTIVE and mark as PAID
    await this.ordersRepository.update(orderId, {
      status: OrderStatus.ACTIVE,
      paymentStatus: MoyasarPaymentStatus.PAID,
    });

    // Apply promo code if one is attached to the order
    if (order.promoCode) {
      const user = await this.userService.getUserById(order.user.toString());
      await this.promoCodesService.apply(user, order.promoCode);
    }

    // Deduct points from user if points are applied
    if (order.appliedPoints) {
      const user = await this.userService.getUserById(order.user.toString());
      await this.userService.updateUserPointsAfterApplied(
        order.user.toString(),
        user.points - order.appliedPoints,
      );
    }

    // Trigger order published event
    await this.orderGateway.orderPublishedEventHandler(orderId);

    return { paymentUrl: 'free' };
  }

  private async processFreeOrder(order: HydratedDocument<Order>) {
    // Determine the correct payment type based on order type
    const paymentType =
      order.type === OrderTypes.SUBSCRIPTION_BOOKING
        ? PaymentTypes.SUBSCRIBED
        : PaymentTypes.FREE;

    // Update order status to ACTIVE and mark as PAID
    order.set({
      paymentStatus: MoyasarPaymentStatus.PAID,
      status: OrderStatus.ACTIVE,
      paymentType: paymentType,
    });
    await order.save();

    // order.user may be a populated User object or a plain ObjectId depending on
    // the call path, so extract a plain string id that works for all downstream calls
    const userId = ((order.user as any)?._id ?? order.user).toString();

    // Apply promo code if one is attached to the order
    if (order.promoCode) {
      const user = await this.userService.getUserById(userId);
      await this.promoCodesService.apply(user, order.promoCode);
    }

    // Handle subscription decrement if applicable
    if (order.type === OrderTypes.SUBSCRIPTION_BOOKING || order.subscription) {
      await this.subscriptionsService.decrementUserRemainingWashes(
        order.subscription,
      );

      // Fetch updated subscription to check remaining washes
      const userSubscription =
        await this.subscriptionsService.isUserHasSubscription(
          order.user as any,
        );

      if (userSubscription && userSubscription.remainingWashes === 0) {
        await this.subscriptionsService.unsubscribeUser(userId);
      }
    }

    // Trigger order published event
    await this.orderGateway.orderPublishedEventHandler(order._id.toString());
  }

  async getOrderByQuery(query: any) {
    return await this.ordersRepository.findOneQuery(query);
  }

  async getOrdersByQuery(query: any) {
    return await this.ordersRepository.findManyQuery(query);
  }

  async rateBiker(userId: string, orderId: string, starsNum: number) {
    // Check order status
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);

    //  Check order authorization
    if (order.user.toString() !== userId)
      throw new ForbiddenResponse({
        ar: 'لا يمكنك اجراء التقييم',
        en: 'You Can Not Rate Biker',
      });

    //  Check rating applied by user for same order
    if (order.ratingOfBiker)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك اجراء التقييم',
        en: 'You Can Not Rate Biker',
      });

    if (order.status !== OrderStatus.COMPLETED)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك اجراء التقييم',
        en: 'You Can Not Rate Biker',
      });

    // rate biker
    order.ratingOfBiker = starsNum;
    await order.save();

    const { average } = await this.calculateAverageRateForBiker(order.biker);
    // update biker average rating
    const biker = await this.bikersService.getById(order.biker);
    biker.rating = average;
    await biker.save();
  }

  private async calculateAverageRateForBiker(bikerId: string | Biker) {
    const listOfRate = await this.ordersRepository.getBikerRatedOrders(bikerId);
    const count: number = listOfRate.length;
    const sumOfRate = listOfRate.reduce(
      (prev: number, curr: Order) => prev + curr.ratingOfBiker,
      0,
    );
    const avg = sumOfRate / count;

    const avgTwoDecimal = Number(avg.toFixed(0));

    return { average: avgTwoDecimal };
  }

  /**
   * Validates that all add-ons have sufficient stock available
   * @param addOnsIds - Array of add-on IDs to validate
   * @throws MethodNotAllowedResponse if any add-on is out of stock
   */
  private async validateAddOnsStock(addOnsIds: any[]) {
    for (const addOnId of addOnsIds) {
      const addOn = await this.addOnsService.getByIdOr404(addOnId.toString());

      if (addOn.stock <= 0) {
        throw new MethodNotAllowedResponse({
          ar: `${addOn.name} غير متوفر في المخزون`,
          en: `${addOn.name} is out of stock`,
        });
      }
    }
  }

  /**
   * Decrements stock for each add-on in the order by 1
   * @param addOnsIds - Array of add-on IDs to decrement stock for
   */
  private async decrementAddOnsStock(addOnsIds: any[]) {
    for (const addOnId of addOnsIds) {
      const addOn = await this.addOnsService.getByIdOr404(addOnId.toString());

      // Decrement stock by 1
      await this.addOnsService.updateAddOns(addOnId.toString(), {
        ...addOn,
        stock: addOn.stock - 1,
      } as any);
    }
  }

  /**
   * Validates that the totalPrice from DTO matches the calculated price from washingServices and addOns
   * Only validates for SERVICE_BOOKING orders
   * @param orderCreationDTO - The order creation DTO containing the totalPrice and service/addon IDs
   * @param type - The order type (should be SERVICE_BOOKING for validation to run)
   * @throws BadRequestException if the totalPrice doesn't match the calculated price
   */
  private async validateTotalPriceForServiceBooking(
    orderCreationDTO: OrderCreationDTO,
    type: string,
  ) {
    // Only validate for SERVICE_BOOKING orders
    if (type !== OrderTypes.SERVICE_BOOKING) {
      return;
    }

    let calculatedPrice = 0;

    // Calculate total price from washing services
    if (
      orderCreationDTO.washingServices &&
      orderCreationDTO.washingServices.length > 0
    ) {
      for (const serviceId of orderCreationDTO.washingServices) {
        const service = await this.washingServicesService.getWashingServiceById(
          serviceId.toString(),
        );
        calculatedPrice += service.price || 0;
      }
    }

    // Calculate total price from add-ons
    if (orderCreationDTO.addOns && orderCreationDTO.addOns.length > 0) {
      for (const addOnId of orderCreationDTO.addOns) {
        const addOn = await this.addOnsService.getByIdOr404(addOnId.toString());
        calculatedPrice += addOn.price || 0;
      }
    }

    // Compare the calculated price with the totalPrice from DTO
    if (calculatedPrice !== orderCreationDTO.totalPrice) {
      throw new BadRequestException({
        success: false,
        message: {
          ar: `السعر الإجمالي غير صحيح. المتوقع: ${calculatedPrice}, المستلم: ${orderCreationDTO.totalPrice}`,
          en: `Total price mismatch. Expected: ${calculatedPrice}, Received: ${orderCreationDTO.totalPrice}`,
        },
      });
    }
  }
}
