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

@Injectable()
export class TabbyService {
  constructor(
    private readonly httpService: HttpService,
    private paymentsRepository: PaymentsRepository,
    @Inject(forwardRef(() => UsersOrdersService))
    private usersOrdersService: UsersOrdersService,
    private addOnsService: AddOnsService,
    @Inject(forwardRef(() => UserService))
    private userService: UserService,
    private promoCodesService: PromoCodesService,
    private pointService: PointService,
  ) {}

  async createCheckoutSession(payload: Record<string, any>): Promise<any> {
    const { baseApiUrl, publicKey } = this.getCredentials();

    try {
      const response = await this.httpService.axiosRef.post(
        `${baseApiUrl}/api/v2/checkout`,
        payload,
        {
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            Authorization: `Bearer ${publicKey}`,
          },
        },
      );

      return response.data;
    } catch (error) {
      console.error('Tabby Service Error:', error.response?.data || error);
      throw new InternalServerErrorException({
        ar: 'فشل في إنشاء جلسة الدفع مع تابي.',
        en: 'Failed to create Tabby checkout session.',
      });
    }
  }

  /**
   * Capture an authorized Tabby payment. API requires `amount` and `reference_id`
   * (capture idempotency key); see https://docs.tabby.ai/api-reference/payments/capture-a-payment
   */
  async capturePayment(
    tabbyPaymentId: string,
    amount: number,
    captureReferenceId: string,
  ): Promise<any> {
    const { baseApiUrl, secretKey } = this.getCredentials();

    if (
      amount == null ||
      !Number.isFinite(Number(amount)) ||
      Number(amount) <= 0
    ) {
      throw new InternalServerErrorException({
        ar: 'مبلغ التحصيل غير صالح.',
        en: 'Capture amount must be a positive number.',
      });
    }

    try {
      const response = await this.httpService.axiosRef.post(
        `${baseApiUrl}/api/v2/payments/${tabbyPaymentId}/captures`,
        {
          amount: Number(amount).toFixed(2),
          reference_id: captureReferenceId,
        },
        {
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            Authorization: `Bearer ${secretKey}`,
          },
        },
      );

      return response.data;
    } catch (error) {
      console.error('Tabby Capture Error:', error.response?.data || error);
      throw new InternalServerErrorException({
        ar: 'فشل في تحصيل الدفعة من تابي.',
        en: 'Failed to capture payment from Tabby.',
      });
    }
  }

  private getCredentials() {
    const isProd = process.env.NODE_ENV === 'prod';

    const baseApiUrl = isProd
      ? process.env.TABBY_BASE_URL_PROD
      : process.env.TABBY_BASE_URL_DEV;

    const publicKey = isProd
      ? process.env.TABBY_PUBLIC_KEY_PROD
      : process.env.TABBY_PUBLIC_KEY_DEV;

    const secretKey = isProd
      ? process.env.TABBY_SECRET_KEY_PROD
      : process.env.TABBY_SECRET_KEY_DEV;

    return { baseApiUrl, publicKey, secretKey };
  }

  getMerchantCode(): string {
    return process.env.TABBY_MERCHANT_CODE || '';
  }

  public async handleTabbyOrderApproved(
    tabbyPaymentId: string,
    orderId: string,
    session: ClientSession,
  ) {
    console.log(`Processing Tabby approved order: ${orderId}`);

    const existingPayment = await this.paymentsRepository.findOne({
      order: new Types.ObjectId(orderId),
    });

    if (existingPayment) {
      console.log('Tabby payment document already exists, skipping...');
      await session.commitTransaction();
      return;
    }

    const order = await this.usersOrdersService.getOrderByIdPopulated(orderId);

    await this.capturePayment(
      tabbyPaymentId,
      order.totalPay,
      `capture-order-${orderId}`,
    );

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
      transactionId: tabbyPaymentId,
      paymentStatus: MoyasarPaymentStatus.PAID,
      paymentType: PaymentTypes.TABBY,
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
    console.log('Tabby payment captured and order activated successfully');
  }

  public async handleTabbyOrderFailed(orderId: string, session: ClientSession) {
    console.log(`Processing Tabby declined/expired order: ${orderId}`);

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
    console.log('Tabby failed order processed successfully');
  }

  public async handleTabbySubscriptionApproved(
    tabbyPaymentId: string,
    subscription: any,
    subscriptionPopulated: any,
    session: ClientSession,
  ) {
    const subscriptionId = subscription._id.toString();
    console.log(`Processing Tabby approved subscription: ${subscriptionId}`);

    const existingPayment = await this.paymentsRepository.findOneBySubscription(
      { subscription: new Types.ObjectId(subscriptionId) },
    );

    if (existingPayment) {
      console.log(
        'Tabby subscription payment document already exists, skipping...',
      );
      await session.commitTransaction();
      return;
    }

    await this.capturePayment(
      tabbyPaymentId,
      subscriptionPopulated.plan.price,
      `capture-subscription-${subscriptionId}`,
    );

    subscription.set({
      paymentStatus: MoyasarPaymentStatus.PAID,
      status: SubscriptionsStatus.ACTIVE,
    });
    await subscription.save({ session });

    await this.paymentsRepository.create({
      subscription: subscription._id,
      totalAmount: subscriptionPopulated.plan.price,
      currency: MoyasarSupportedCurrency.SAR,
      transactionId: tabbyPaymentId,
      paymentStatus: MoyasarPaymentStatus.PAID,
      paymentType: PaymentTypes.TABBY,
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
    console.log('Tabby subscription activated successfully');
  }

  public async handleTabbySubscriptionFailed(
    subscription: any,
    session: ClientSession,
  ) {
    console.log(
      `Processing Tabby declined/expired subscription: ${subscription._id}`,
    );

    subscription.set({
      paymentStatus: MoyasarPaymentStatus.FAILED,
      status: SubscriptionsStatus.PAYMENT_FAILED,
    });
    await subscription.save({ session });

    await session.commitTransaction();
    console.log('Tabby failed subscription processed successfully');
  }

  private async incrementAddOnsStock(addOnsIds: any[]) {
    for (const addOnId of addOnsIds) {
      try {
        const addOn = await this.addOnsService.getByIdOr404(addOnId.toString());
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
      }
    }
  }
}
