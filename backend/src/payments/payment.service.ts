import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { InjectConnection } from '@nestjs/mongoose';
import * as crypto from 'crypto';
import { Request } from 'express';
import { ClientSession, Connection, Types } from 'mongoose';
import * as queryString from 'querystring';
import { AddOns } from 'src/add-ons/schemas/add-ons.schema';
import { AddOnsService } from 'src/add-ons/services/add-ons.service';
import { NotificationsService } from 'src/notifications/services/notifications.service';
import { OrderGateway } from 'src/orders/gateway/order.gateway';
import {
  OrderStatus,
  OrderTypes,
  PaymentTypes,
} from 'src/orders/schemas/orders.schema';
import { UsersOrdersService } from 'src/orders/services/userOrders.service';
import { PointService } from 'src/points/services/point.service';
import { PromoCodesService } from 'src/promo-code/services/promo-code.service';
import { SubscriptionsStatus } from 'src/subscriptions/schemas/subscriptions.schema';
import { SubscriptionsService } from 'src/subscriptions/services/subscriptions.service';
import { TamaraService } from 'src/tamara/services/tamara.service';
import { parseTamaraWalletTopUpOrderReferenceId } from 'src/tamara/tamara-wallet-topup-reference';
import { TabbyService } from 'src/common/services/tabby.service';
import { parseTabbyWalletTopUpOrderReferenceId } from 'src/tabby/tabby-wallet-topup-reference';
import { UserService } from 'src/user/user.service';
import { WashingService } from 'src/washing-services/schemas/washing-services.schema';
import * as _ from 'underscore';
import { PaymentsRepository } from './repositories/payments.repository';
import {
  MoyasarPaymentStatus,
  MoyasarSupportedCurrency,
} from './schemas/payments.schema';
@Injectable()
export class PaymentService {
  constructor(
    @InjectConnection() private readonly connection: Connection,
    private paymentsRepository: PaymentsRepository,
    private pointService: PointService,
    private notificationService: NotificationsService,
    private userService: UserService,
    private usersOrdersService: UsersOrdersService,
    private subscriptionsService: SubscriptionsService,
    private promoCodesService: PromoCodesService,
    private orderGateway: OrderGateway,
    private addOnsService: AddOnsService,
    private eventEmitter: EventEmitter2,
    private tamaraService: TamaraService,
    private tabbyService: TabbyService,
  ) {}

  async webhookListener(request: Request) {
    console.log('Webhook Event Received... ');

    const { type, data } = request.body ?? {};
    console.log(request.body);

    const metadata = data?.metadata;
    if (!type || !data || !metadata) {
      console.warn('Moyasar webhook has no metadata, ignoring event', {
        type,
        id: data?.id,
      });
      return;
    }

    const session = await this.connection.startSession();
    try {
      session.startTransaction({ readPreference: 'primary' });

      if (metadata.type === 'wallet_topup') {
        await this.handleWalletTopUp(type, data, session);
      } else if (metadata.orderId) {
        switch (metadata.orderType) {
          case OrderTypes.SERVICE_BOOKING:
            await this.handleOrderPayment(type, data, session);
            break;

          case OrderTypes.SUBSCRIPTION_BOOKING:
            await this.handleSubscripedOrderPayment(type, data, session);
            break;

          default:
            console.log('Unhandled event or status');
        }
      } else if (metadata.subscriptionId) {
        await this.handleSubscriptionPayment(type, data, session);
      }
    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  }

  private async handleSubscriptionPayment(
    type: string,
    data: any,
    session: ClientSession,
  ) {
    if (type === 'payment_paid') {
      if (data.status === 'paid') {
        await this.processSuccessfulSubscriptionPayment(data, session);
      } else if (data.status !== 'paid') {
        await this.processFailedSubscriptionPayment(data, session);
      }
    } else if (type === 'payment_failed') {
      await this.processFailedSubscriptionPayment(data, session);
    }
  }

  private async handleOrderPayment(
    type: string,
    data: any,
    session: ClientSession,
  ) {
    if (type === 'payment_paid') {
      if (data.status === 'paid') {
        await this.processSuccessfulOrderPayment(data, session);
        await this.orderGateway.orderPublishedEventHandler(
          data.metadata.orderId,
        );
      } else if (data.status !== 'paid') {
        await this.processFailedOrderPayment(data, session);
      }
    } else if (type === 'payment_refunded') {
      if (data.status === 'refunded') {
        await this.processSuccessfulOrderRefund(data, session);
      } else if (data.status !== 'refunded') {
        await this.processFailedOrderRefund(data, session);
      }
    } else if (type === 'payment_failed') {
      await this.processFailedOrderPayment(data, session);
    }
  }

  private async processFailedOrderRefund(data: any, session: ClientSession) {
    console.log(`Processing failed refund for order: ${data.metadata.orderId}`);

    const orderId: string = data.metadata.orderId;
    const order = await this.usersOrdersService.getOrderById(orderId);
    const orderPopulated = await this.usersOrdersService.getOrderByIdPopulated(
      orderId,
    );

    // Update the order to indicate refund failure
    order.set({
      paymentStatus: MoyasarPaymentStatus.REFUND_FAILED,
      status: OrderStatus.CANCELLED_BY_USER,
    });
    await order.save({ session });

    // Log the failed refund transaction
    console.error(`Refund failed for order ${orderId}. Status: ${data.status}`);

    await this.notificationService.sendOrderRefundFailedNotification(
      (orderPopulated.user as any)._id,
      orderPopulated.user.language || 'en',
      orderPopulated.user.fcmTokens,
      orderId,
      orderPopulated.user.isAllowNotification,
    );

    await session.commitTransaction();
    console.log('Failed refund processed successfully');
  }

  private async processSuccessfulOrderRefund(
    data: any,
    session: ClientSession,
  ) {
    console.log(`Processing refund for order: ${data.metadata.orderId}`);

    const order = await this.usersOrdersService.getOrderById(
      data.metadata.orderId,
    );
    if (!order) {
      throw new NotFoundException({
        ar: `الطلب ${data.metadata.orderId} غير موجود.`,
        en: `Order ${data.metadata.orderId} not found.`,
      });
    }

    if (order.paymentStatus !== MoyasarPaymentStatus.PAID) {
      throw new BadRequestException({
        ar: `الطلب ${data.metadata.orderId} غير مؤهل لاسترداد الأموال.`,
        en: `Order ${data.metadata.orderId} is not eligible for refund.`,
      });
    }

    try {
      // Find existing payment record
      const existingPayment = await this.paymentsRepository.findOne({
        order: new Types.ObjectId(data.metadata.orderId),
      });

      if (!existingPayment) {
        throw new NotFoundException({
          ar: `سجل الدفع للطلب ${data.metadata.orderId} غير موجود.`,
          en: `Payment record for order ${data.metadata.orderId} not found.`,
        });
      }

      order.set({
        paymentStatus: MoyasarPaymentStatus.REFUNDED,
        // status: OrderStatus.CANCELLED_BY_USER,
      });
      await order.save({ session });

      existingPayment.set({
        paymentStatus: MoyasarPaymentStatus.REFUNDED,
        transactionId: data.id, // Update transaction ID if needed
      });
      await existingPayment.save({ session });
      // Log the refund transaction
      console.log(
        `Refund transaction recorded for order: ${data.metadata.orderId}`,
      );

      await session.commitTransaction();
    } catch (error) {
      console.error(
        `Failed to process refund for order ${data.metadata.orderId}:`,
        error,
      );
      throw new ConflictException({
        ar: 'فشل في معالجة الاسترداد.',
        en: 'Failed to process refund.',
      });
    }
  }

  private async handleSubscripedOrderPayment(
    type: string,
    data: any,
    session: ClientSession,
  ) {
    if (type === 'payment_paid') {
      if (data.status === 'paid') {
        await this.processSuccessfulSubscripedOrderPayment(data, session);
        await this.orderGateway.orderPublishedEventHandler(
          data.metadata.orderId,
        );
      } else if (data.status === 'failed') {
        await this.processFailedSubscripedOrderPayment(data, session);
      }
    }
  }

  private isValidSignature(request: Request, signature: string): boolean {
    const apiKey = process.env.API_SECRET_KEY;
    const { data } = request.body;

    data.signatureKeys.sort();
    const objectSignaturePayload = _.pick(data, data.signatureKeys);
    const signaturePayload = queryString.stringify(objectSignaturePayload);

    const hash = crypto
      .createHmac('sha256', `${apiKey}`)
      .update(signaturePayload)
      .digest('hex');

    return hash === signature;
  }

  private async processSuccessfulOrderPayment(
    data: any,
    session: ClientSession,
  ) {
    console.log(
      `Processing successful payment for order: ${data.metadata.orderId}`,
    );

    const existingPaymentDoc = await this.paymentsRepository.findOne({
      order: new Types.ObjectId(data.metadata.orderId),
    });

    if (existingPaymentDoc) {
      console.log('Payment document already exists, skipping...');
      return;
    }

    const orderId: string = data.metadata.orderId;
    const order = await this.usersOrdersService.getOrderByIdPopulated(orderId);

    // Validate payment amount matches order total
    // Moyasar sends amount in smallest currency unit (halalas for SAR)
    const paidAmount = Number((data.amount / 100).toFixed(2)); // Convert from halalas to SAR and round to 2 decimals
    const expectedAmount = Number(order.totalPay.toFixed(2)); // Round to 2 decimals to avoid floating point precision issues

    if (Math.abs(paidAmount - expectedAmount) > 0.01) {
      // Allow 0.01 difference for rounding
      const errorMessage = `Payment amount mismatch for order ${orderId}. Expected: ${expectedAmount} SAR, Received: ${paidAmount} SAR`;
      console.error(errorMessage);
      throw new BadRequestException({
        ar: `مبلغ الدفع لا يتطابق مع إجمالي الطلب`,
        en: 'Payment amount does not match order total',
        details: errorMessage,
      });
    }

    console.log(
      `Payment amount validated: ${paidAmount} SAR matches order total`,
    );

    order.set({
      paymentStatus: MoyasarPaymentStatus.PAID,
      status: OrderStatus.ACTIVE,
    });
    await order.save({ session });

    // Extract user ID from populated order
    const userId =
      typeof order.user === 'string'
        ? order.user
        : (order.user as any)?._id?.toString() || order.user.toString();

    // Apply promo code if one is attached to the order
    if (order.promoCode) {
      const user = await this.userService.getUserById(userId);
      await this.promoCodesService.apply(user, order.promoCode);
    }

    // Deduct points from user if points are applied
    if (order.appliedPoints) {
      const user = await this.userService.getUserById(userId);
      await this.userService.updateUserPointsAfterApplied(
        userId,
        user.points - order.appliedPoints,
      );
    }

    // Check if user has active subscription and order has addons
    // If user is subscribed and paying for addons via gateway, decrement subscription washes
    if (order.addOns && order.addOns.length > 0) {
      const user = await this.userService.getUserById(userId);
      const userSubscription =
        await this.subscriptionsService.isUserHasSubscription(user);

      if (userSubscription && userSubscription.remainingWashes > 0) {
        console.log(
          `User has active subscription with ${userSubscription.remainingWashes} washes remaining. Decrementing for order with addons.`,
        );
        await this.subscriptionsService.decrementUserRemainingWashes(
          userSubscription,
        );
      }
    }

    const paymentDoc = await this.paymentsRepository.create({
      order: order._id,
      orderType: OrderTypes.SERVICE_BOOKING,
      totalAmount: order.totalPay,
      currency: MoyasarSupportedCurrency.SAR,
      transactionId: data.id,
      paymentStatus: MoyasarPaymentStatus.PAID,
      paymentType: order.paymentType,
    });

    console.log(`payment is` + paymentDoc);
    console.log(`order is` + order);
    await session.commitTransaction();
    console.log('Payment document saved successfully');

    if (process.env.NODE_ENV === 'prod') {
      const orderItems = order.washingServices.map(
        (service: WashingService) => ({
          product_id: Number(service.qoyodProductId),
          quantity: 1,
          unit_price: service.price,
        }),
      );

      const addOnsItems = order.addOns.map((addOn: AddOns) => ({
        product_id: Number(addOn.qoyodProductId),
        quantity: 1,
        unit_price: addOn.price,
      }));

      const allItems = [...orderItems, ...addOnsItems];
      const itemsWithDiscount = this.distributeDiscountAcrossItems(
        allItems,
        order.discount || 0,
      );

      this.eventEmitter.emit('order.created', {
        orderId: orderId,
        userId: userId,
        orderItems: itemsWithDiscount,
      });
    }
  }

  async getPaymentByFilter(filter: any) {
    return await this.paymentsRepository.findOne(filter);
  }

  private async processFailedOrderPayment(data: any, session: ClientSession) {
    console.log(
      `Processing failed payment for order: ${data.metadata.orderId}`,
    );
    const orderId: string = data.metadata.orderId;

    const order = await this.usersOrdersService.getOrderById(orderId);

    // Increment add-ons stock if order has add-ons
    if (order.addOns && order.addOns.length > 0) {
      await this.incrementAddOnsStock(order.addOns);
    }

    order.set({
      paymentStatus: MoyasarPaymentStatus.FAILED,
      status: OrderStatus.PAYMENT_FAILED,
    });
    await order.save({ session });

    await session.commitTransaction();
    console.log('Failed payment processed successfully');
  }

  private async processSuccessfulSubscripedOrderPayment(
    data: any,
    session: ClientSession,
  ) {
    console.log(
      `Processing successful payment for sucscriped service: ${data.metadata.orderId}`,
    );

    const existingPaymentDoc = await this.paymentsRepository.findOne({
      order: new Types.ObjectId(data.metadata.orderId),
    });

    if (existingPaymentDoc) {
      console.log('Payment document already exists, skipping...');
      return;
    }

    const orderId: string = data.metadata.orderId;
    const order: any = await this.usersOrdersService.getOrderById(orderId);

    // Validate payment amount matches order total
    // Moyasar sends amount in smallest currency unit (halalas for SAR)
    const paidAmount = Number((data.amount / 100).toFixed(2)); // Convert from halalas to SAR and round to 2 decimals
    const expectedAmount = Number(order.totalPay.toFixed(2)); // Round to 2 decimals to avoid floating point precision issues

    if (Math.abs(paidAmount - expectedAmount) > 0.01) {
      // Allow 0.01 difference for rounding
      const errorMessage = `Payment amount mismatch for subscription order ${orderId}. Expected: ${expectedAmount} SAR, Received: ${paidAmount} SAR`;
      console.error(errorMessage);
      throw new BadRequestException({
        ar: `مبلغ الدفع لا يتطابق مع إجمالي الطلب`,
        en: 'Payment amount does not match order total',
        details: errorMessage,
      });
    }

    console.log(
      `Payment amount validated: ${paidAmount} SAR matches subscription order total`,
    );

    order.set({
      paymentStatus: MoyasarPaymentStatus.PAID,
      status: OrderStatus.ACTIVE,
    });
    await order.save({ session });

    const paymentDoc = await this.paymentsRepository.create({
      order: order._id,
      orderType: OrderTypes.SUBSCRIPTION_BOOKING,
      totalAmount: order.totalPay,
      currency: MoyasarSupportedCurrency.SAR,
      transactionId: data.id,
      paymentStatus: MoyasarPaymentStatus.PAID,
      paymentType: order.paymentType,
    });

    console.log(`payment is` + paymentDoc);
    console.log(`order is` + order);
    await session.commitTransaction();
    console.log('Payment document saved successfully');
  }

  private async processFailedSubscripedOrderPayment(
    data: any,
    session: ClientSession,
  ) {
    console.log(
      `Processing failed payment for sucscriped service: ${data.metadata.orderId}`,
    );
    const orderId: string = data.metadata.orderId;

    const order = await this.usersOrdersService.getOrderById(orderId);

    // Increment add-ons stock if order has add-ons
    if (order.addOns && order.addOns.length > 0) {
      await this.incrementAddOnsStock(order.addOns);
    }

    order.set({
      paymentStatus: MoyasarPaymentStatus.FAILED,
      status: OrderStatus.PAYMENT_FAILED,
    });
    await order.save({ session });

    await session.commitTransaction();
    console.log('Failed payment processed successfully');
  }

  private async processSuccessfulSubscriptionPayment(
    data: any,
    session: ClientSession,
  ) {
    console.log(
      `Processing successful payment for sucscription: ${data.metadata.subscriptionId}`,
    );

    const existingPaymentDoc =
      await this.paymentsRepository.findOneBySubscription({
        subscription: new Types.ObjectId(data.metadata.subscriptionId),
      });

    if (existingPaymentDoc) {
      console.log('Payment document already exists, skipping...');
      return;
    }

    const subscriptionId: string = data.metadata.subscriptionId;
    const subscription: any =
      await this.subscriptionsService.getSubscriptionById(subscriptionId);

    const subscriptionPopulated =
      await this.subscriptionsService.getSubscriptionByIdPopulated(
        subscription.id,
      ); // Ensure the plan is populated

    // Validate payment amount matches subscription plan price
    // Moyasar sends amount in smallest currency unit (halalas for SAR)
    const paidAmount = Number((data.amount / 100).toFixed(2)); // Convert from halalas to SAR and round to 2 decimals
    const expectedAmount = Number(subscriptionPopulated.plan.price.toFixed(2)); // Round to 2 decimals to avoid floating point precision issues

    if (Math.abs(paidAmount - expectedAmount) > 0.01) {
      // Allow 0.01 difference for rounding
      const errorMessage = `Payment amount mismatch for subscription ${subscriptionId}. Expected: ${expectedAmount} SAR, Received: ${paidAmount} SAR`;
      console.error(errorMessage);
      throw new BadRequestException({
        ar: `مبلغ الدفع لا يتطابق مع سعر الاشتراك`,
        en: 'Payment amount does not match subscription price',
        details: errorMessage,
      });
    }

    console.log(
      `Payment amount validated: ${paidAmount} SAR matches subscription price`,
    );

    subscription.set({
      paymentStatus: MoyasarPaymentStatus.PAID,
      status: SubscriptionsStatus.ACTIVE,
    });
    await subscription.save({ session });

    const paymentDoc = await this.paymentsRepository.create({
      subscription: subscription._id,
      totalAmount: subscriptionPopulated.plan.price,
      currency: MoyasarSupportedCurrency.SAR,
      transactionId: data.id,
      paymentStatus: MoyasarPaymentStatus.PAID,
      paymentType: subscription.paymentType,
    });

    // Calculate points for subscription
    const numberOfPoints = await this.pointService.calculateEarningPoints(
      subscriptionPopulated.plan.price,
    );

    console.log(numberOfPoints);

    // Extract user ID from subscription (handle both populated and non-populated cases)
    const subscriptionUserId =
      typeof subscription.user === 'string'
        ? subscription.user
        : (subscription.user as any)?._id?.toString() ||
          subscription.user.toString();

    // user points reward
    await this.userService.userPointsUpgrade(
      subscriptionUserId,
      numberOfPoints,
    );

    console.log(`payment is` + paymentDoc);
    console.log(`subscription is` + subscription);
    await session.commitTransaction();
    console.log('Payment document saved successfully');
  }

  private async processFailedSubscriptionPayment(
    data: any,
    session: ClientSession,
  ) {
    console.log(
      `Processing failed payment for subscription: ${data.metadata.subscriptionId}`,
    );
    const subscriptionId: string = data.metadata.subscriptionId;

    const subscription = await this.subscriptionsService.getSubscriptionById(
      subscriptionId,
    );
    subscription.set({
      paymentStatus: MoyasarPaymentStatus.FAILED,
      status: SubscriptionsStatus.PAYMENT_FAILED,
    });
    await subscription.save({ session });

    await session.commitTransaction();
    console.log('Failed payment processed successfully');
  }

  /**
   * Increments stock for each add-on by 1 when order payment fails
   * @param addOnsIds - Array of add-on IDs to increment stock for
   */
  private async incrementAddOnsStock(addOnsIds: any[]) {
    for (const addOnId of addOnsIds) {
      try {
        const addOn = await this.addOnsService.getByIdOr404(addOnId.toString());

        // Increment stock by 1
        await this.addOnsService.updateAddOns(addOnId.toString(), {
          ...addOn,
          stock: addOn.stock + 1,
        } as any);

        console.log(`Incremented stock for add-on ${addOn.name}`);
      } catch (error) {
        console.error(
          `Failed to increment stock for add-on ${addOnId}:`,
          error,
        );
        // Continue with other add-ons even if one fails
      }
    }
  }

  /**
   * Distributes the order discount proportionally across all line items
   * Ensures no item's discount exceeds its total price
   * @param items - Array of line items with product_id, quantity, and unit_price
   * @param totalDiscount - Total discount amount to distribute
   * @returns Array of items with discount applied
   */
  private distributeDiscountAcrossItems(
    items: Array<{
      product_id: number;
      quantity: number;
      unit_price: number;
    }>,
    totalDiscount: number,
  ): Array<{
    product_id: number;
    quantity: number;
    unit_price: number;
    discount: number;
  }> {
    // If no discount, return items with 0 discount
    if (totalDiscount <= 0 || items.length === 0) {
      return items.map((item) => ({ ...item, discount: 0 }));
    }

    // Calculate total order amount
    const totalAmount = items.reduce(
      (sum, item) => sum + item.quantity * item.unit_price,
      0,
    );

    // If total amount is 0, return items with 0 discount
    if (totalAmount <= 0) {
      return items.map((item) => ({ ...item, discount: 0 }));
    }

    // Distribute discount proportionally
    let remainingDiscount = totalDiscount;
    const itemsWithDiscount = items.map((item, index) => {
      const itemTotal = item.quantity * item.unit_price;

      // Calculate proportional discount for this item
      let itemDiscount: number;

      // For the last item, assign all remaining discount to avoid rounding errors
      if (index === items.length - 1) {
        itemDiscount = remainingDiscount;
      } else {
        itemDiscount = (itemTotal / totalAmount) * totalDiscount;
      }

      // Ensure discount doesn't exceed item's total price
      itemDiscount = Math.min(itemDiscount, itemTotal);

      // Round to 2 decimal places
      itemDiscount = Math.round(itemDiscount * 100) / 100;

      remainingDiscount -= itemDiscount;

      return {
        ...item,
        discount: itemDiscount,
      };
    });

    return itemsWithDiscount;
  }

  private async handleWalletTopUp(
    type: string,
    data: any,
    session: ClientSession,
  ) {
    if (type === 'payment_paid') {
      if (data.status === 'paid') {
        await this.processSuccessfulWalletTopUp(data, session);
      } else if (data.status !== 'paid') {
        await this.processFailedWalletTopUp(data, session);
      }
    } else if (type === 'payment_failed') {
      await this.processFailedWalletTopUp(data, session);
    }
  }

  private async processSuccessfulWalletTopUp(
    data: any,
    session: ClientSession,
  ) {
    console.log(`Processing wallet top-up for user: ${data.metadata.userId}`);

    const userId: string = data.metadata.userId;
    const amount: number = data.metadata.amount;

    // Validate payment amount
    const paidAmount = Number((data.amount / 100).toFixed(2)); // Convert from halalas to SAR and round to 2 decimals
    const expectedAmount = Number(amount.toFixed(2)); // Round to 2 decimals to avoid floating point precision issues

    if (Math.abs(paidAmount - expectedAmount) > 0.01) {
      const errorMessage = `Wallet top-up amount mismatch. Expected: ${expectedAmount} SAR, Received: ${paidAmount} SAR`;
      console.error(errorMessage);
      throw new BadRequestException({
        ar: 'مبلغ الدفع لا يتطابق مع مبلغ الشحن',
        en: 'Payment amount does not match top-up amount',
        details: errorMessage,
      });
    }

    // Add amount to user wallet
    await this.userService.topUpWallet(userId, amount);

    // Create payment document
    await this.paymentsRepository.create({
      totalAmount: amount,
      currency: MoyasarSupportedCurrency.SAR,
      transactionId: data.id,
      paymentStatus: MoyasarPaymentStatus.PAID,
      paymentType: PaymentTypes.CREDIT,
      walletTopUp: {
        userId: userId,
        amount: amount,
      },
    });

    await session.commitTransaction();
    console.log(`Wallet top-up successful for user ${userId}: +${amount} SAR`);
  }

  private async processFailedWalletTopUp(data: any, session: ClientSession) {
    console.log(
      `Processing failed wallet top-up for user: ${data.metadata.userId}`,
    );

    // Create failed payment document
    await this.paymentsRepository.create({
      totalAmount: data.metadata.amount,
      currency: MoyasarSupportedCurrency.SAR,
      transactionId: data.id,
      paymentStatus: MoyasarPaymentStatus.FAILED,
      paymentType: PaymentTypes.CREDIT,
      walletTopUp: {
        userId: data.metadata.userId,
        amount: data.metadata.amount,
      },
    });

    await session.commitTransaction();
    console.log('Failed wallet top-up processed');
  }

  private async processSuccessfulTamaraWalletTopUp(
    tamaraOrderId: string,
    userId: string,
    amount: number,
    session: ClientSession,
  ) {
    console.log(`Processing Tamara wallet top-up for user: ${userId}`);

    const existingPayment = await this.getPaymentByFilter({
      transactionId: tamaraOrderId,
    });
    if (existingPayment) {
      console.log('Tamara wallet top-up payment already recorded, skipping...');
      await session.commitTransaction();
      return;
    }

    await this.tamaraService.authorizeCheckoutOrder(tamaraOrderId);

    await this.userService.topUpWallet(userId, amount);

    await this.paymentsRepository.create({
      totalAmount: amount,
      currency: MoyasarSupportedCurrency.SAR,
      transactionId: tamaraOrderId,
      paymentStatus: MoyasarPaymentStatus.PAID,
      paymentType: PaymentTypes.TAMARA,
      walletTopUp: {
        userId,
        amount,
      },
    });

    await session.commitTransaction();
    console.log(
      `Tamara wallet top-up successful for user ${userId}: +${amount} SAR`,
    );
  }

  private async processFailedTamaraWalletTopUp(
    tamaraOrderId: string,
    userId: string,
    amount: number,
    session: ClientSession,
  ) {
    console.log(`Processing failed Tamara wallet top-up for user: ${userId}`);

    await this.paymentsRepository.create({
      totalAmount: amount,
      currency: MoyasarSupportedCurrency.SAR,
      transactionId: tamaraOrderId,
      paymentStatus: MoyasarPaymentStatus.FAILED,
      paymentType: PaymentTypes.TAMARA,
      walletTopUp: {
        userId,
        amount,
      },
    });

    await session.commitTransaction();
    console.log('Failed Tamara wallet top-up processed');
  }

  async tamaraWebhookListener(request: Request) {
    console.log('Tamara Webhook Event Received...');
    console.log(request.body);

    const signature = request.header('Tamara-Signature') || '';

    if (signature && !this.tamaraService.verifyWebhookSignature(signature)) {
      console.warn('Invalid Tamara webhook signature — ignoring event');
      return;
    }

    const {
      event_type,
      order_id: tamaraOrderId,
      order_reference_id: referenceId,
    } = request.body;

    const walletTopUp = parseTamaraWalletTopUpOrderReferenceId(referenceId);
    const isObjectId24 = /^[a-fA-F0-9]{24}$/.test(referenceId);
    let isSubscription = false;
    if (!walletTopUp && isObjectId24) {
      const subscriptionCheck = await this.subscriptionsService.getById(
        referenceId,
      );
      isSubscription = !!subscriptionCheck;
    }

    const session = await this.connection.startSession();
    try {
      session.startTransaction({ readPreference: 'primary' });

      switch (event_type) {
        case 'order_approved':
          if (walletTopUp) {
            await this.processSuccessfulTamaraWalletTopUp(
              tamaraOrderId,
              walletTopUp.userId,
              walletTopUp.amountSar,
              session,
            );
          } else if (isSubscription) {
            const subscription =
              await this.subscriptionsService.getSubscriptionById(referenceId);
            const subscriptionPopulated =
              await this.subscriptionsService.getSubscriptionByIdPopulated(
                referenceId,
              );
            await this.tamaraService.handleTamaraSubscriptionApproved(
              tamaraOrderId,
              subscription,
              subscriptionPopulated,
              session,
            );
          } else {
            await this.tamaraService.handleTamaraOrderApproved(
              tamaraOrderId,
              referenceId,
              session,
            );
            await this.orderGateway.orderPublishedEventHandler(referenceId);
          }
          break;

        case 'order_declined':
        case 'order_expired':
        case 'order_cancelled':
          if (walletTopUp) {
            await this.processFailedTamaraWalletTopUp(
              tamaraOrderId,
              walletTopUp.userId,
              walletTopUp.amountSar,
              session,
            );
          } else if (isSubscription) {
            const subscription =
              await this.subscriptionsService.getSubscriptionById(referenceId);
            await this.tamaraService.handleTamaraSubscriptionFailed(
              subscription,
              session,
            );
          } else {
            await this.tamaraService.handleTamaraOrderFailed(
              referenceId,
              session,
            );
          }
          break;

        default:
          console.log(`Unhandled Tamara event type: ${event_type}`);
          await session.abortTransaction();
          return;
      }
    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  }

  async tabbyWebhookListener(request: Request) {
    console.log('Tabby Webhook Event Received...');
    console.log(request.body);

    const { id: tabbyPaymentId, status, order } = request.body;
    const referenceId: string = order?.reference_id;

    if (!referenceId || !tabbyPaymentId || !status) {
      console.warn('Tabby webhook missing required fields, ignoring event');
      return;
    }

    const walletTopUp = parseTabbyWalletTopUpOrderReferenceId(referenceId);
    const isObjectId24 = /^[a-fA-F0-9]{24}$/.test(referenceId);
    let isSubscription = false;
    if (!walletTopUp && isObjectId24) {
      const subscriptionCheck = await this.subscriptionsService.getById(
        referenceId,
      );
      isSubscription = !!subscriptionCheck;
    }

    const session = await this.connection.startSession();
    try {
      session.startTransaction({ readPreference: 'primary' });

      const isSuccess = status === 'authorized' || status === 'closed';
      const isFailure = status === 'rejected' || status === 'expired';

      if (isSuccess) {
        if (walletTopUp) {
          await this.processSuccessfulTabbyWalletTopUp(
            tabbyPaymentId,
            walletTopUp.userId,
            walletTopUp.amountSar,
            session,
          );
        } else if (isSubscription) {
          const subscription =
            await this.subscriptionsService.getSubscriptionById(referenceId);
          const subscriptionPopulated =
            await this.subscriptionsService.getSubscriptionByIdPopulated(
              referenceId,
            );
          await this.tabbyService.handleTabbySubscriptionApproved(
            tabbyPaymentId,
            subscription,
            subscriptionPopulated,
            session,
          );
        } else {
          await this.tabbyService.handleTabbyOrderApproved(
            tabbyPaymentId,
            referenceId,
            session,
          );
          await this.orderGateway.orderPublishedEventHandler(referenceId);
        }
      } else if (isFailure) {
        if (walletTopUp) {
          await this.processFailedTabbyWalletTopUp(
            tabbyPaymentId,
            walletTopUp.userId,
            walletTopUp.amountSar,
            session,
          );
        } else if (isSubscription) {
          const subscription =
            await this.subscriptionsService.getSubscriptionById(referenceId);
          await this.tabbyService.handleTabbySubscriptionFailed(
            subscription,
            session,
          );
        } else {
          await this.tabbyService.handleTabbyOrderFailed(referenceId, session);
        }
      } else {
        console.log(`Unhandled Tabby payment status: ${status}`);
        await session.abortTransaction();
        return;
      }
    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
  }

  private async processSuccessfulTabbyWalletTopUp(
    tabbyPaymentId: string,
    userId: string,
    amount: number,
    session: ClientSession,
  ) {
    console.log(`Processing Tabby wallet top-up for user: ${userId}`);

    const existingPayment = await this.getPaymentByFilter({
      transactionId: tabbyPaymentId,
    });
    if (existingPayment) {
      console.log('Tabby wallet top-up payment already recorded, skipping...');
      await session.commitTransaction();
      return;
    }

    await this.tabbyService.capturePayment(
      tabbyPaymentId,
      amount,
      `capture-wallet-topup-${tabbyPaymentId}`,
    );

    await this.userService.topUpWallet(userId, amount);

    await this.paymentsRepository.create({
      totalAmount: amount,
      currency: MoyasarSupportedCurrency.SAR,
      transactionId: tabbyPaymentId,
      paymentStatus: MoyasarPaymentStatus.PAID,
      paymentType: PaymentTypes.TABBY,
      walletTopUp: {
        userId,
        amount,
      },
    });

    await session.commitTransaction();
    console.log(
      `Tabby wallet top-up successful for user ${userId}: +${amount} SAR`,
    );
  }

  private async processFailedTabbyWalletTopUp(
    tabbyPaymentId: string,
    userId: string,
    amount: number,
    session: ClientSession,
  ) {
    console.log(`Processing failed Tabby wallet top-up for user: ${userId}`);

    await this.paymentsRepository.create({
      totalAmount: amount,
      currency: MoyasarSupportedCurrency.SAR,
      transactionId: tabbyPaymentId,
      paymentStatus: MoyasarPaymentStatus.FAILED,
      paymentType: PaymentTypes.TABBY,
      walletTopUp: {
        userId,
        amount,
      },
    });

    await session.commitTransaction();
    console.log('Failed Tabby wallet top-up processed');
  }
}
