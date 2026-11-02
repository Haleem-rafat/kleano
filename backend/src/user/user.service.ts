import { HttpService } from '@nestjs/axios';
import {
  BadRequestException,
  ConflictException,
  forwardRef,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { EventEmitter2 } from '@nestjs/event-emitter';
import * as ExcelJS from 'exceljs';
import { FcmTopics } from 'src/common/enums/topics.enum';
import { FCMService } from 'src/common/services/firebase/fcm.service';
import { MoyasarSupportedCurrency } from 'src/payments/schemas/payments.schema';
import { PointService } from 'src/points/services/point.service';
import {
  CreateCheckoutSessionDto,
  ItemDto,
  TamaraSupportedCurrency,
} from 'src/tamara/dto/create-checkout-session.dto';
import { buildTamaraWalletTopUpOrderReferenceId } from 'src/tamara/tamara-wallet-topup-reference';
import { buildTabbyWalletTopUpOrderReferenceId } from 'src/tabby/tabby-wallet-topup-reference';
import { TabbyService } from '../common/services/tabby.service';
import { VehiclesService } from 'src/vehicles/vehicles.service';
import { NearestCityCalculator } from '../city/nearestCityCalculator.service';
import { SubscriptionsService } from '../subscriptions/services/subscriptions.service';
import { UpdateUserLocation } from './dto';
import { UserRegisterDTO } from './dto/user.register.dto';
import { UpdatePhoneNumberDTO } from './dto/user.updatePhoneNumber.dto';
import { UserUpdateProfileDTO } from './dto/user.updateProfile.dto';
import { User } from './schemas/user.schema';
import { UserRepository } from './user.repository';
import { UserQueriesHelper } from './userQueriesHelper.service';

@Injectable()
export class UserService {
  constructor(
    private userRepository: UserRepository,
    private userQueriesHelper: UserQueriesHelper,
    private nearestCityCalculator: NearestCityCalculator,
    @Inject(forwardRef(() => SubscriptionsService))
    private subscriptionsService: SubscriptionsService,
    private fcmService: FCMService,
    @Inject(forwardRef(() => PointService))
    private readonly pointService: PointService,
    private vehiclesService: VehiclesService,
    private eventEmitter: EventEmitter2,
    private readonly httpService: HttpService,
    @Inject(forwardRef(() => TabbyService))
    private tabbyService: TabbyService,
  ) {}

  async create(userRegsiterDTO: UserRegisterDTO) {
    // Create User
    const createdUser = await this.userRepository.create(userRegsiterDTO);

    if (process.env.NODE_ENV === 'prod') {
      this.eventEmitter.emit('user.created', {
        userId: createdUser.id,
        userName: createdUser.userName,
        phone: createdUser.phone,
        email: createdUser.email,
      });
    }

    // TODO: Add FcmTokens service
    return createdUser;
  }

  async update(
    userId: string,
    userUpdateProfileDTO: UserUpdateProfileDTO,
    image: Express.Multer.File,
  ) {
    const updatedProfile = await this.userRepository.update(
      userId,
      userUpdateProfileDTO,
      image,
    );

    if (process.env.NODE_ENV === 'prod') {
      this.eventEmitter.emit('user.updated', {
        userId: updatedProfile.id,
        qoyodCustomerId: updatedProfile.qoyodCustomerId,
        userName: updatedProfile.userName,
        email: updatedProfile.email,
      });
    }

    return updatedProfile;
  }

  async updatePhoneNumber(
    id: string,
    updatePhoneNumberDTO: UpdatePhoneNumberDTO,
  ) {
    const user = await this.userRepository.findUserByIdOr404(id);

    user.phone = updatePhoneNumberDTO.phone;
    await user.save();

    return user;
  }

  async updateUserLocation(id: string, updateUserLocation: UpdateUserLocation) {
    const user = await this.userRepository.findUserByIdOr404(id);

    const nearestCity = await this.nearestCityCalculator.findNearestCity(
      Number(updateUserLocation.latitude),
      Number(updateUserLocation.longitude),
    );

    if (!nearestCity['city'])
      return user.language === 'en'
        ? 'Our Service Not Exist Waiting for us soon..'
        : 'خدماتنا غير متوفرة حاليا';

    // Update User Location
    await this.userQueriesHelper.updateUserLocation(
      id,
      updateUserLocation,
      nearestCity['city']._id,
    );

    return user.language === 'en' ? 'done' : 'تم التعديل بنجاح';
  }

  async updateUserLanguage(id: string, language: string) {
    const user = await this.userRepository.findUserByIdOr404(id);

    user.language = language;
    await user.save();
  }

  async delete(userId: string) {
    await this.userRepository.delete(userId);
  }

  async getAll(): Promise<User[]> {
    return await this.userRepository.findAll();
  }

  async getAllForAdmin(): Promise<User[]> {
    return await this.userRepository.getAllForAdmin();
  }

  async getAllNewUsers() {
    return await this.userRepository.findAllNewUsers();
  }

  async getUsersWithoutOrders() {
    return await this.userRepository.findUsersWithoutOrders();
  }

  async getAllUsers() {
    return await this.userRepository.findAll();
  }

  async getUsersBySegment(segmentId: string) {
    return await this.userRepository.findUsersBySegment(segmentId);
  }

  async getUsersByAggregatorCriteria(
    expressionLeftSide: string,
    operator: string,
    expressionRightSide: number,
  ) {
    // Get users meeting aggregator criteria based on order count
    return await this.userRepository.findUsersByAggregatorCriteria(
      expressionLeftSide,
      operator,
      expressionRightSide,
    );
  }

  async isPhoneExist(phone: string) {
    return await this.userRepository.checkPhoneExistence(phone);
  }

  async getUserByPhoneOr404(phone: string) {
    const user = await this.userRepository.findUserByPhoneOr404(phone);
    return user;
  }

  async getUserByIdOr404(userId: string) {
    const user = await this.userRepository.findUserByIdOr404(userId);
    if (!user) {
      throw new NotFoundException({
        ar: `المستخدم ذو المعرف ${userId} غير موجود.`,
        en: `User with ID ${userId} not found.`,
      });
    }

    const vehicles = await this.vehiclesService.getAll(userId);

    const subscription = await this.subscriptionsService.getUserSubscription(
      userId,
    );

    return {
      ...user.toObject(),
      isSubscribed: subscription ? true : false,
      vehicles,
      registrationDate: user.createdAt,
    };
  }

  async getUserById(id: string) {
    return await this.userRepository.findUserById(id);
  }
  async getUser(userId: string) {
    return await this.userRepository.findUser(userId);
  }

  async getUserDetails(userId: string) {
    return await this.userRepository.getUserDetails(userId);
  }

  async updateUserSocketId(id: string, socketId: string) {
    const user = await this.userRepository.findUserByIdOr404(id);

    user.socketId = socketId;
    await user.save();
  }
  checkWalletBalanceValid(user: User, orderTotalPrice: number) {
    return user.walletBalance >= orderTotalPrice ? true : false;
  }
  async payWithWallet(userId: string, amount: number) {
    const user = await this.userRepository.findUserByIdOr404(userId);
    user.walletBalance = user.walletBalance - amount;
    await user.save();
  }

  async userPointsUpgrade(userId: string, points: number) {
    const user = await this.userRepository.findUserById(userId);
    user.points = user.points + points;
    await user.save();
  }

  async updateUserPointsAfterApplied(userId: string, points: number) {
    const user = await this.userRepository.findUserById(userId);
    user.points = points;
    await user.save();
  }
  async removeInvalidFcmToken(userId: string, fcmToken: string) {
    const user = await this.userRepository.findUser(userId);

    if (!user) {
      console.log(
        `User with id ${userId} not found, skipping FCM token removal`,
      );
      return;
    }

    if (!user.fcmTokens || user.fcmTokens.length === 0) {
      console.log(`User ${userId} has no FCM tokens to remove`);
      return;
    }

    const updatedUserFcmTokens = user.fcmTokens.filter((fcmTokenItem) => {
      return fcmTokenItem !== fcmToken;
    });
    console.log('valid fcmTokens :' + updatedUserFcmTokens);

    user.fcmTokens = updatedUserFcmTokens;
    await user.save();
  }

  async updateUserNotificationPermission(userId: string, allow: string) {
    const user = await this.userRepository.findUser(userId);

    user.isAllowNotification = allow === 'on' ? true : false;

    if (allow === 'on') {
      // Subscribe user to topic when enabling notifications
      if (user.fcmTokens.length) {
        await this.fcmService.subscribeToTopic(
          user.fcmTokens,
          FcmTopics.PROMO_CODE_CREATED,
        );
      }
    } else {
      // Unsubscribe user from topic when disabling notifications
      if (user.fcmTokens.length) {
        await this.fcmService.unSubscribeToTopic(
          user.fcmTokens,
          FcmTopics.PROMO_CODE_CREATED,
        );
      }
    }
    await user.save();
  }

  async getUserPointSystem(userId: string) {
    const user = await this.getUserById(userId);

    const currentPoints = user.points;
    const pointsExchange = await this.pointService.calculatePointsExchange(
      currentPoints,
    );

    return {
      points: currentPoints,
      pointsExchange,
      redeemLimit: (await this.pointService.getPointsSystem()).redeemLimit,
    };
  }

  async exportUsersToExcel(): Promise<Buffer> {
    const users = await this.userRepository.getUsersToExcel();

    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Users');

    worksheet.columns = [
      { header: 'Serial Number', key: 'serialNumber', width: 20 },
      { header: 'User Name', key: 'userName', width: 30 },
      { header: 'Email Address', key: 'email', width: 50 },
      { header: 'Mobile Number', key: 'phone', width: 20 },
      { header: 'Gender', key: 'gender', width: 20 },
      { header: 'Registration Date', key: 'createdAt', width: 20 },
      { header: 'Vehicles', key: 'vehicles', width: 100 },
      { header: 'Orders Count', key: 'ordersCount', width: 20 },
      { header: 'Total Orders Price', key: 'totalOrdersPrice', width: 20 },
      { header: 'Add Ons Count', key: 'addOnsCount', width: 20 },
      { header: 'Total Add Ons Price', key: 'totalAddOnsPrice', width: 20 },
    ];

    users.forEach((user) => {
      const vehiclesList = user.vehicles
        .map((vehicle) => {
          return `{"brand":"${vehicle.brand} "model":"${vehicle.model} "plateNumber":"${vehicle.plateNumber} }`;
        })
        .join(', ');
      worksheet.addRow({
        serialNumber: user.serialNumber,
        userName: user.userName,
        email: user.email,
        phone: user.phone,
        gender: user.gender,
        createdAt: user.createdAt,
        vehicles: vehiclesList,
        ordersCount: user.ordersCount,
        totalOrdersPrice: user.totalOrdersPrice,
        addOnsCount: user.addOnsCount,
        totalAddOnsPrice: user.totalAddOnsPrice,
      });
    });

    const buffer = await workbook.xlsx.writeBuffer();
    return Buffer.from(buffer);
  }

  async topUpWallet(userId: string, amount: number) {
    return await this.userRepository.incrementWalletBalance(userId, amount);
  }

  async createWalletTopUpPayment(
    userId: string,
    amount: number,
    paymentDetails: {
      name: string;
      number: string;
      cvc: string;
      month: string;
      year: string;
    },
  ) {
    const DOMAIN_URL = process.env.DOMAIN_URL; // Ensure this is correctly set in your .env
    const callbackUrl = `${DOMAIN_URL}/wallet/payment-success?userId=${userId}`;
    const webhookUrl = `${DOMAIN_URL}/payments/webhook-listener`;

    const payload = {
      amount: amount * 100, // Convert to halalas
      currency: MoyasarSupportedCurrency.SAR,
      description: `Wallet Top-up - ${amount} SAR`,
      callback_url: callbackUrl, // User is redirected here after payment
      webhook_url: webhookUrl, // Moyasar sends a POST request here
      statement_descriptor: 'KleanO',
      display_name: 'KleanO',
      source: {
        type: 'creditcard',
        ...paymentDetails, // Use dynamic payment details from the user
      },
      metadata: {
        userId: userId,
        amount: amount,
        type: 'wallet_topup',
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

      return response.data.source.transaction_url;
    } catch (error) {
      console.error(
        'Moyasar Wallet Payment Error:',
        error.response?.data || error,
      );
      throw new ConflictException({
        ar: 'فشل في معالجة الدفع',
        en: 'Failed to process payment',
      });
    }
  }

  async createWalletTamaraTopUp(userId: string, amount: number) {
    const user = await this.getUserById(userId);
    const tamaraCity = user.location?.subAdministrativeArea?.trim();
    // if (!tamaraCity) {
    //   throw new BadRequestException({
    //     ar: 'بيانات عنوان المستخدم ناقصة (المدينة).',
    //     en: 'User address is missing a city name.',
    //   });
    // }

    const DOMAIN_URL = process.env.DOMAIN_URL;
    const orderRef = buildTamaraWalletTopUpOrderReferenceId(userId, amount);

    const item: ItemDto = {
      name: { en: 'Wallet top-up', ar: 'شحن المحفظة' },
      quantity: 1,
      reference_id: orderRef,
      type: 'Digital',
      sku: orderRef,
      unit_price: {
        amount,
        currency: TamaraSupportedCurrency.SAR,
      },
      total_amount: {
        amount,
        currency: TamaraSupportedCurrency.SAR,
      },
    };

    const payload: CreateCheckoutSessionDto = {
      total_amount: {
        amount,
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
      order_reference_id: orderRef,
      items: [item] as ItemDto[],
      consumer: {
        email: user.email,
        first_name: user.userName.split(' ')[0],
        last_name: user.userName.split(' ')[1] || user.userName,
        phone_number: user.phone,
      },
      country_code: 'SA',
      description: `Wallet top-up — ${amount} SAR`,
      merchant_url: {
        cancel: `https://kleano.sa/wallet?status=cancel`,
        failure: `https://kleano.sa/wallet?status=failure`,
        success: `https://kleano.sa/wallet?status=success`,
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
        payload,
        {
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json',
            Authorization: `Bearer ${apiKey}`,
          },
        },
      );
      return response.data.checkout_url;
    } catch (error) {
      console.error(
        'Tamara Wallet Top-up Error:',
        error.response?.data || error,
      );
      throw new ConflictException({
        ar: 'فشل في إنشاء جلسة الدفع مع تامارا.',
        en: 'Failed to create Tamara wallet top-up session.',
      });
    }
  }

  async createWalletTabbyTopUp(userId: string, amount: number) {
    const user = await this.getUserById(userId);
    const city = user.location?.subAdministrativeArea?.trim();
    // if (!city) {
    //   throw new BadRequestException({
    //     ar: 'بيانات عنوان المستخدم ناقصة (المدينة).',
    //     en: 'User address is missing a city name.',
    //   });
    // }

    const orderRef = buildTabbyWalletTopUpOrderReferenceId(userId, amount);

    const payload = {
      payment: {
        amount: amount.toFixed(2),
        currency: 'SAR',
        description: `Wallet top-up — ${amount} SAR`,
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
          reference_id: orderRef,
          items: [
            {
              title: 'Wallet top-up',
              reference_id: orderRef,
              quantity: 1,
              unit_price: amount.toFixed(2),
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
        cancel: `wallet?status=cancel`,
        failure: `wallet?status=failure`,
        success: `wallet?status=success`,
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
        ar: 'تابي غير متاح حاليًا.',
        en: 'Tabby is not available at the moment.',
      });
    }

    return webUrl;
  }
}
