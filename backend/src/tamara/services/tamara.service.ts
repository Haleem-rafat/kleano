import { HttpService } from '@nestjs/axios';
import {
  Inject,
  Injectable,
  InternalServerErrorException,
  forwardRef,
} from '@nestjs/common';
import { ClientSession, Types } from 'mongoose';
import { AddOnsService } from 'src/add-ons/services/add-ons.service';
import {
  OrderStatus,
  OrderTypes,
  PaymentTypes,
} from 'src/orders/schemas/orders.schema';
import { UsersOrdersService } from 'src/orders/services/userOrders.service';
import { PaymentsRepository } from 'src/payments/repositories/payments.repository';
import {
  MoyasarPaymentStatus,
  MoyasarSupportedCurrency,
} from 'src/payments/schemas/payments.schema';
import { PointService } from 'src/points/services/point.service';
import { PromoCodesService } from 'src/promo-code/services/promo-code.service';
import { SubscriptionsStatus } from 'src/subscriptions/schemas/subscriptions.schema';
import { UserService } from 'src/user/user.service';
import { CreateCheckoutSessionDto } from '../dto/create-checkout-session.dto';

@Injectable()
export class TamaraService {
  constructor(
    private readonly httpService: HttpService,
    private paymentsRepository: PaymentsRepository,
    @Inject(forwardRef(() => UsersOrdersService))
    private usersOrdersService: UsersOrdersService,
    private addOnsService: AddOnsService,
    private userService: UserService,
    private promoCodesService: PromoCodesService,
    private pointService: PointService,
  ) {}

  async createCheckoutSession(body: CreateCheckoutSessionDto) {
    const { baseApiUrl, apiKey } = this.getCredentials();

    try {
      const response = await this.httpService.axiosRef.post(
        `${baseApiUrl}/checkout`,
        body,
        {
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            Authorization: `Bearer ${apiKey}`,
          },
        },
      );

      return response.data;
    } catch (error) {
      console.error('Tamara Service Error:', error.response?.data || error);
      throw new InternalServerErrorException({
        ar: 'فشل في إنشاء الجلسة',
        en: 'Failed to create checkout session',
      });
    }
  }

  verifyWebhookSignature(signature: string): boolean {
    const notificationToken =
      process.env.NODE_ENV === 'prod'
        ? process.env.TAMARA_NOTIFICATION_TOKEN_PROD
        : process.env.TAMARA_NOTIFICATION_TOKEN_DEV;

    if (!notificationToken) return false;
    return signature === notificationToken;
  }

  private getCredentials() {
    const baseApiUrl =
      process.env.NODE_ENV === 'prod'
        ? process.env.TAMARA_BASE_URL_PROD
        : process.env.TAMARA_BASE_URL_DEV;

    const apiKey =
      process.env.NODE_ENV === 'prod'
        ? process.env.TAMARA_API_KEY_PROD
        : process.env.TAMARA_API_KEY_DEV;

    return { baseApiUrl, apiKey };
  }

  public async handleTamaraOrderApproved(
    tamaraOrderId: string,
    orderId: string,
    session: ClientSession,
  ) {
    console.log(`Processing Tamara approved order: ${orderId}`);

    const existingPayment = await this.paymentsRepository.findOne({
      order: new Types.ObjectId(orderId),
    });

    if (existingPayment) {
      console.log('Tamara payment document already exists, skipping...');
      await session.commitTransaction();
      return;
    }

    const order = await this.usersOrdersService.getOrderByIdPopulated(orderId);

    // Authorise the order then capture the payment on Tamara's side
    await this.authorizeOrder(tamaraOrderId);
    // await this.capturePayment(tamaraOrderId, order.totalPay);

    order.set({
      paymentStatus: MoyasarPaymentStatus.PAID,
      status: OrderStatus.ACTIVE,
    });
    await order.save({ session });

    await this.paymentsRepository.create({
      order: order._id,
      orderType: OrderTypes.SERVICE_BOOKING,
      totalAmount: order.totalPay,
      currency: MoyasarSupportedCurrency.SAR,
      transactionId: tamaraOrderId,
      paymentStatus: MoyasarPaymentStatus.PAID,
      paymentType: PaymentTypes.TAMARA,
    });

    const userId =
      typeof order.user === 'string'
        ? order.user
        : (order.user as any)?._id?.toString() || order.user.toString();

    if (order.promoCode) {
      const user = await this.userService.getUserById(userId);
      await this.promoCodesService.apply(user, order.promoCode);
    }

    if (order.appliedPoints) {
      const user = await this.userService.getUserById(userId);
      await this.userService.updateUserPointsAfterApplied(
        userId,
        user.points - order.appliedPoints,
      );
    }

    await session.commitTransaction();
    console.log('Tamara payment captured and order activated successfully');
  }

  public async handleTamaraOrderFailed(
    orderId: string,
    session: ClientSession,
  ) {
    console.log(`Processing Tamara declined/expired order: ${orderId}`);

    const order = await this.usersOrdersService.getOrderById(orderId);

    if (order.addOns && order.addOns.length > 0) {
      await this.incrementAddOnsStock(order.addOns);
    }

    order.set({
      paymentStatus: MoyasarPaymentStatus.FAILED,
      status: OrderStatus.PAYMENT_FAILED,
    });
    await order.save({ session });

    await session.commitTransaction();
    console.log('Tamara failed order processed successfully');
  }

  public async handleTamaraSubscriptionApproved(
    tamaraOrderId: string,
    subscription: any,
    subscriptionPopulated: any,
    session: ClientSession,
  ) {
    const subscriptionId = subscription._id.toString();
    console.log(`Processing Tamara approved subscription: ${subscriptionId}`);

    const existingPayment = await this.paymentsRepository.findOneBySubscription(
      { subscription: new Types.ObjectId(subscriptionId) },
    );

    if (existingPayment) {
      console.log(
        'Tamara subscription payment document already exists, skipping...',
      );
      await session.commitTransaction();
      return;
    }

    await this.authorizeOrder(tamaraOrderId);

    subscription.set({
      paymentStatus: MoyasarPaymentStatus.PAID,
      status: SubscriptionsStatus.ACTIVE,
    });
    await subscription.save({ session });

    await this.paymentsRepository.create({
      subscription: subscription._id,
      totalAmount: subscriptionPopulated.plan.price,
      currency: MoyasarSupportedCurrency.SAR,
      transactionId: tamaraOrderId,
      paymentStatus: MoyasarPaymentStatus.PAID,
      paymentType: PaymentTypes.TAMARA,
    });

    const numberOfPoints = await this.pointService.calculateEarningPoints(
      subscriptionPopulated.plan.price,
    );

    const subscriptionUserId =
      typeof subscription.user === 'string'
        ? subscription.user
        : (subscription.user as any)?._id?.toString() ||
          subscription.user.toString();

    await this.userService.userPointsUpgrade(
      subscriptionUserId,
      numberOfPoints,
    );

    await session.commitTransaction();
    console.log('Tamara subscription activated successfully');
  }

  public async handleTamaraSubscriptionFailed(
    subscription: any,
    session: ClientSession,
  ) {
    console.log(
      `Processing Tamara declined/expired subscription: ${subscription._id}`,
    );

    subscription.set({
      paymentStatus: MoyasarPaymentStatus.FAILED,
      status: SubscriptionsStatus.PAYMENT_FAILED,
    });
    await subscription.save({ session });

    await session.commitTransaction();
    console.log('Tamara failed subscription processed successfully');
  }

  /** Used by PaymentService for Tamara wallet top-up after webhook approval. */
  async authorizeCheckoutOrder(tamaraOrderId: string): Promise<any> {
    return this.authorizeOrder(tamaraOrderId);
  }

  private async authorizeOrder(tamaraOrderId: string): Promise<any> {
    const { baseApiUrl, apiKey } = this.getCredentials();

    try {
      const response = await this.httpService.axiosRef.post(
        `${baseApiUrl}/orders/${tamaraOrderId}/authorise`,
        {},
        {
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            Authorization: `Bearer ${apiKey}`,
          },
        },
      );

      return response.data;
    } catch (error) {
      console.error('Tamara Authorize Error:', error.response?.data || error);
      throw new InternalServerErrorException({
        ar: 'فشل في تفويض الطلب لدى تمارا',
        en: 'Failed to authorize order with Tamara',
      });
    }
  }

  private async capturePayment(
    tamaraOrderId: string,
    amount: number,
  ): Promise<any> {
    const { baseApiUrl, apiKey } = this.getCredentials();

    try {
      const response = await this.httpService.axiosRef.post(
        `${baseApiUrl}/payments/capture`,
        {
          order_id: tamaraOrderId,
          amount: { amount, currency: 'SAR' },
        },
        {
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            Authorization: `Bearer ${apiKey}`,
          },
        },
      );

      return response.data;
    } catch (error) {
      console.error('Tamara Capture Error:', error.response?.data || error);
      throw new InternalServerErrorException({
        ar: 'فشل في تحصيل الدفعة من تمارا',
        en: 'Failed to capture payment from Tamara',
      });
    }
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
}
