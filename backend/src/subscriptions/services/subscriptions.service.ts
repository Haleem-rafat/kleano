import { HttpService } from '@nestjs/axios';
import {
  BadRequestException,
  ConflictException,
  forwardRef,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { HydratedDocument } from 'mongoose';
import { TabbyService } from 'src/common/services/tabby.service';
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
import { NearestCityCalculator } from '../../city/nearestCityCalculator.service';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';
import { PlansService } from '../../plans/services/plans.service';
import { User } from '../../user/schemas/user.schema';
import { UserService } from '../../user/user.service';
import { GetSubscriptionsDTO } from '../dtos/getSubscriptions.dto';
import { GetSubscriptionByLocationDTO } from '../dtos/subscriptionByLocation.dto';
import { SubscriptionsRepository } from '../repositories/subscriptions.repository';
import {
  Subscription,
  SubscriptionPaymentTypes,
  SubscriptionsStatus,
} from '../schemas/subscriptions.schema';

@Injectable()
export class SubscriptionsService {
  constructor(
    private subscriptionsRepository: SubscriptionsRepository,
    @Inject(forwardRef(() => PlansService))
    private plansService: PlansService,
    private readonly httpService: HttpService,

    @Inject(forwardRef(() => UserService))
    private userService: UserService,
    private nearestCityCalculator: NearestCityCalculator,
    private pointService: PointService,
    @Inject(forwardRef(() => TabbyService))
    private tabbyService: TabbyService,
  ) {}

  async createUserSubscription(
    userId: string,
    planId: string,
    paymentType: string,
  ) {
    const user = await this.userService.getUserById(userId);

    if (await this.isUserHasSubscription(user))
      throw new MethodNotAllowedResponse({
        ar: 'انت مشترك في باقة اخري',
        en: 'You Have Already Subscribed',
      });

    const plan = await this.plansService.getById(planId);

    const expiryDate = this.calculateExpiryDate(plan.duration);

    return await this.subscriptionsRepository.create(
      user,
      plan,
      expiryDate,
      paymentType,
    );
  }

  async unsubscribeUser(userId: string) {
    const user = await this.userService.getUserById(userId);

    const userSubscription = await this.subscriptionsRepository.findOne(user);

    if (!userSubscription) {
      throw new NotFoundException({
        ar: 'لم يتم العثور على اشتراك نشط.',
        en: 'No active subscription found.',
      });
    }

    // if (userSubscription.remainingWashes > 0) {
    //   throw new MethodNotAllowedResponse({
    //     ar: 'لا يمكنك إلغاء الاشتراك حتى تستهلك جميع الغسلات.',
    //     en: 'You cannot unsubscribe until you use all washes.',
    //   });
    // }

    userSubscription.status = SubscriptionsStatus.CANCELLED;
    userSubscription.expiryDate = new Date(); // Set expiry date to now

    await userSubscription.save();

    return {
      message: {
        ar: 'تم إلغاء الاشتراك بنجاح.',
        en: 'Subscription cancelled successfully.',
      },
    };
  }

  calculateExpiryDate(duration: number) {
    const currentDate = new Date();
    return new Date(currentDate.setMonth(currentDate.getMonth() + duration));
  }

  async isUserHasSubscription(user: User) {
    return await this.subscriptionsRepository.findOne(user);
  }

  async getUserSubscription(userId: string) {
    const user = await this.userService.getUserById(userId);

    return await this.subscriptionsRepository.findOnePopulated(user);
  }

  async getUserSubscriptionWithStatusFilter(
    userId: string,
    getSubscriptionsDTO: GetSubscriptionsDTO,
  ) {
    const user = await this.userService.getUserById(userId);

    return await this.subscriptionsRepository.findOnePopulatedWithStatusFilter(
      user,
      getSubscriptionsDTO?.status,
    );
  }

  async getById(subscriptionId: string) {
    return await this.subscriptionsRepository.findById(subscriptionId);
  }

  async decrementUserRemainingWashes(subscription: Subscription) {
    await this.subscriptionsRepository.decrementUserRemaingWashes(subscription);
  }

  async incrementUserRemainingWashes(subscription: Subscription) {
    await this.subscriptionsRepository.incrementUserRemaingWashes(subscription);
  }

  async getUserSubscriptionByLocation(
    userId: string,
    getSubscriptionByLocationDTO: GetSubscriptionByLocationDTO,
  ) {
    const user = await this.userService.getUserById(userId);
    const subscription = await this.subscriptionsRepository.findOneWithPlan(
      user,
    );
    if (!subscription)
      throw new MethodNotAllowedResponse({
        ar: 'انت ليس مشترك في باقة',
        en: 'You Have No Subscription',
      });

    const city = await this.nearestCityCalculator.findNearestCity(
      Number(getSubscriptionByLocationDTO.latitude),
      Number(getSubscriptionByLocationDTO.longitude),
    );

    if (!city['city'])
      return {
        subscription,
        message:
          user.language === 'en'
            ? 'Our Service Not Exist Waiting for us soon..'
            : 'خدماتنا غير متوفرة حاليا',
      };

    const isPlanExistInCity =
      await this.plansService.checkPlanExistenceWithCity(
        subscription.plan,
        city['city']._id,
      );

    return {
      subscription,
      message: isPlanExistInCity
        ? ''
        : 'Your plan is not accepted in this city',
    };
  }

  async cancelUserSubscription(userId: string, planId: string) {
    await this.subscriptionsRepository.cancel(userId, planId);
  }

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async checkSubscriptionsExpiryDateReached() {
    console.log(`Subscriptions Expiry Date Reached Started at ${new Date()}`);
    const today = new Date();

    // Get the Subscruption that today or befor is its expairy date
    const expairedSubscriptions = await this.subscriptionsRepository.findAll({
      expiryDate: { $lte: today },
      status: SubscriptionsStatus.ACTIVE,
    });

    console.log(
      `Number of Subscriptions to be Exipred at ${new Date()} is ${
        expairedSubscriptions.length
      }`,
    );

    // TODO: Send notifications to the Subscriptions Users

    // Set the status of the Subscriptions to EXPIRED
    await this.subscriptionsRepository.update(
      {
        _id: {
          $in: expairedSubscriptions.map(
            (expiredSubscription) => expiredSubscription._id,
          ),
        },
      },
      { status: SubscriptionsStatus.EXPIRED },
    );
  }

  paymentTypeValidator(paymentType: string) {
    if (!paymentType)
      throw new MethodNotAllowedResponse({
        ar: 'قم باختيار طريقة الدفع',
        en: 'Choose Payment Type',
      });

    if (
      paymentType !== SubscriptionPaymentTypes.CREDIT &&
      paymentType !== SubscriptionPaymentTypes.WALLET &&
      paymentType !== SubscriptionPaymentTypes.APPLE_PAY &&
      paymentType !== SubscriptionPaymentTypes.TAMARA &&
      paymentType !== SubscriptionPaymentTypes.TABBY
    )
      throw new MethodNotAllowedResponse({
        ar: 'قم باختيار طريقة الدفع صالحة',
        en: 'Choose Valid Payment Type',
      });
  }

  async paySubscription(
    userId: string,
    subscriptionId: string,
    paymentDetails?: {
      name: string;
      number: string;
      cvc: string;
      month: string;
      year: string;
    },
  ) {
    const pendingSubscription =
      await this.subscriptionsRepository.findSubscriptionByIdOr404(
        subscriptionId,
      );

    if (!(pendingSubscription.status === SubscriptionsStatus.PENDING)) {
      throw new BadRequestException({
        ar: 'حالة الاشتراك غير صالحة.',
        en: 'Subscription status invalid.',
      });
    }

    this.paymentTypeValidator(pendingSubscription.paymentType);

    let paymentResponse;
    switch (pendingSubscription.paymentType) {
      case SubscriptionPaymentTypes.CREDIT:
        if (!paymentDetails) {
          throw new BadRequestException({
            ar: 'تفاصيل الدفع مطلوبة لمدفوعات البطاقة الائتمانية.',
            en: 'Payment details are required for credit card payments.',
          });
        }
        paymentResponse = await this.payCredit(subscriptionId, paymentDetails);
        break;

      case SubscriptionPaymentTypes.WALLET:
        paymentResponse = await this.payWallet(userId, subscriptionId);
        break;

      case SubscriptionPaymentTypes.TAMARA:
        paymentResponse = await this.payTamara(userId, subscriptionId);
        break;

      case SubscriptionPaymentTypes.TABBY:
        paymentResponse = await this.payTabby(userId, subscriptionId);
        break;

      default:
        throw new ConflictException({
          ar: 'نوع الدفع غير صالح.',
          en: 'Invalid payment type.',
        });
    }
    return {
      subscriptionId: pendingSubscription._id.toString(),
      ...paymentResponse,
    };
  }

  async payTamara(userId: string, subscriptionId: string) {
    const subscription =
      await this.subscriptionsRepository.findSubscriptionByIdPopulatedOr404(
        subscriptionId,
      );

    if (subscription.paymentType !== SubscriptionPaymentTypes.TAMARA)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك الدفع بواسطة تامارا',
        en: 'You could not pay using Tamara',
      });

    const user = await this.userService.getUserById(userId);

    const tamaraCity = user.location?.subAdministrativeArea?.trim();
    // if (!tamaraCity) {
    //   throw new BadRequestException({
    //     ar: 'بيانات عنوان المستخدم ناقصة (المدينة).',
    //     en: 'User address is missing a city name.',
    //   });
    // }

    const planItem: ItemDto = {
      name: subscription.plan.type,
      quantity: 1,
      reference_id: (subscription.plan as any)._id.toString(),
      type: 'Digital',
      sku: (subscription.plan as any)._id.toString(),
      unit_price: {
        amount: subscription.plan.price,
        currency: TamaraSupportedCurrency.SAR,
      },
      total_amount: {
        amount: subscription.plan.price,
        currency: TamaraSupportedCurrency.SAR,
      },
    };

    const payload: CreateCheckoutSessionDto = {
      total_amount: {
        amount: subscription.plan.price,
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
      order_reference_id: subscription._id.toString(),
      items: [planItem] as ItemDto[],
      consumer: {
        email: user.email,
        first_name: user.userName.split(' ')[0],
        last_name: user.userName.split(' ')[1] || user.userName,
        phone_number: user.phone,
      },
      country_code: 'SA',
      description: `Payment for Subscription #${subscription._id}`,
      merchant_url: {
        cancel: `https://kleano.sa/subscriptions?status=cancel`,
        failure: `https://kleano.sa/subscriptions?status=failure`,
        success: `https://kleano.sa/subscriptions?status=success`,
      },
      shipping_address: {
        city: tamaraCity,
        country_code: 'SA',
        first_name: user.userName.split(' ')[0],
        last_name: user.userName.split(' ')[1] || user.userName,
        line1: user.location?.streetName || tamaraCity,
      },
      is_mobile: true,
    };

    const tamaraResponse = await this.createTamaraCheckoutSession(payload);

    return { paymentUrl: tamaraResponse.checkout_url };
  }

  async payTabby(userId: string, subscriptionId: string) {
    const subscription =
      await this.subscriptionsRepository.findSubscriptionByIdPopulatedOr404(
        subscriptionId,
      );

    if (subscription.paymentType !== SubscriptionPaymentTypes.TABBY)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك الدفع بواسطة تابي',
        en: 'You could not pay using Tabby',
      });

    const user = await this.userService.getUserById(userId);

    const city = user.location?.subAdministrativeArea?.trim();
    // if (!city) {
    //   throw new BadRequestException({
    //     ar: 'بيانات عنوان المستخدم ناقصة (المدينة).',
    //     en: 'User address is missing a city name.',
    //   });
    // }

    const planTitle =
      typeof subscription.plan.type === 'object'
        ? (subscription.plan.type as any).en ||
          (subscription.plan.type as any).ar ||
          'Subscription Plan'
        : String(subscription.plan.type);

    const payload = {
      payment: {
        amount: subscription.plan.price.toFixed(2),
        currency: 'SAR',
        description: `Payment for Subscription #${subscription._id}`,
        buyer: {
          name: user.userName,
          email: user.email,
          phone: user.phone,
        },
        shipping_address: {
          city,
          address: user.location?.streetName || city,
          zip: '00000',
        },
        order: {
          reference_id: subscription._id.toString(),
          items: [
            {
              title: planTitle,
              reference_id: (subscription.plan as any)._id.toString(),
              quantity: 1,
              unit_price: subscription.plan.price.toFixed(2),
              category: 'Services',
            },
          ],
          discount_amount: '0.00',
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
        cancel: `subscriptions?status=cancel`,
        failure: `subscriptions?status=failure`,
        success: `subscriptions?status=success`,
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
        ar: 'تابي غير متاح لهذا الاشتراك.',
        en: 'Tabby is not available for this subscription.',
      });
    }

    return { paymentUrl: webUrl };
  }

  private async createTamaraCheckoutSession(body: CreateCheckoutSessionDto) {
    const baseApiUrl =
      process.env.NODE_ENV === 'prod'
        ? process.env.TAMARA_BASE_URL_PROD
        : process.env.TAMARA_BASE_URL_DEV;

    const apiKey =
      process.env.NODE_ENV === 'prod'
        ? process.env.TAMARA_API_KEY_PROD
        : process.env.TAMARA_API_KEY_DEV;

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
      console.error('Tamara Checkout Error:', error.response?.data || error);
      throw new ConflictException({
        ar: 'فشل في إنشاء جلسة الدفع مع تامارا.',
        en: 'Failed to create Tamara checkout session.',
      });
    }
  }

  async payWallet(userId: string, subscriptionId: string) {
    const subscription =
      await this.subscriptionsRepository.findSubscriptionByIdPopulatedOr404(
        subscriptionId,
      );

    if (subscription.paymentType !== SubscriptionPaymentTypes.WALLET)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك الدفع ',
        en: 'You could not pay',
      });

    const user = await this.userService.getUserById(userId);

    const IsUserWalletBalanceValid = this.userService.checkWalletBalanceValid(
      user,
      subscription.plan.price,
    );

    if (!IsUserWalletBalanceValid)
      throw new MethodNotAllowedResponse({
        ar: 'لا تحتوي محفظتك الإلكترونية علي هذا المبلغ',
        en: 'Your Wallet Balance Is Not Valid',
      });

    await this.userService.payWithWallet(userId, subscription.plan.price);

    await this.subscriptionsRepository.update(
      { _id: subscription._id },
      {
        paymentStatus: MoyasarPaymentStatus.PAID,
        status: SubscriptionsStatus.ACTIVE,
      },
    );

    return {
      message: 'Subscription paid successfully',
    };
  }

  async payCredit(
    subscriptionId: string,
    paymentDetails: {
      name: string;
      number: string;
      cvc: string;
      month: string;
      year: string;
    },
  ) {
    const pendingSubscription =
      await this.subscriptionsRepository.findSubscriptionByIdOr404(
        subscriptionId,
      );

    if (pendingSubscription.paymentType !== SubscriptionPaymentTypes.CREDIT)
      throw new MethodNotAllowedResponse({
        ar: 'لا يمكنك الدفع ',
        en: 'You could not pay',
      });

    // Step 1: Initiate Moyasar Payment
    const moyasarResponse = await this.initiateMoyasarPayment(
      pendingSubscription,
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

  private async initiateMoyasarPayment(
    subscription: HydratedDocument<Subscription>,
    paymentDetails: {
      name: string;
      number: string;
      cvc: string;
      month: string;
      year: string;
    },
  ) {
    const subscriptionPopulated = await this.getSubscriptionByIdPopulated(
      subscription.id,
    ); // Ensure the plan is populated
    console.log(`subscription pop is` + subscriptionPopulated);

    const DOMAIN_URL = process.env.DOMAIN_URL; // Ensure this is correctly set in your .env

    const callbackUrl = `${DOMAIN_URL}/payment-success?subscriptionId=${subscription._id.toString()}`;
    const webhookUrl = `${DOMAIN_URL}/payments/webhook-listener`;
    const payload = {
      amount: subscriptionPopulated.plan.price * 100, // Convert to halalas
      currency: MoyasarSupportedCurrency.SAR,
      description: `Payment for Subscription #${subscription._id}`,
      callback_url: callbackUrl, // User is redirected here after payment
      webhook_url: webhookUrl, // Moyasar sends a POST request here
      statement_descriptor: 'KleanO',
      display_name: 'KleanO',
      source: {
        type: 'creditcard',
        ...paymentDetails, // Use dynamic payment details from the user
      },
      metadata: {
        subscriptionId: subscription._id.toString(),
        userId: subscription.user.toString(),
        totalAmount: subscription.plan.price,
        createdAt: subscription.createdAt.toISOString(),
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

  async getSubscriptionById(subscriptionId: string) {
    return await this.subscriptionsRepository.findSubscriptionByIdOr404(
      subscriptionId,
    );
  }

  async getSubscriptionByIdPopulated(subscriptionId: string) {
    return await this.subscriptionsRepository.findSubscriptionByIdPopulatedOr404(
      subscriptionId,
    );
  }
}
