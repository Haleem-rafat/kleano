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
import * as ExcelJS from 'exceljs';
import { parse } from 'json2csv';
import { Connection, Types } from 'mongoose';
import { AdminService } from 'src/admin/admin.service';
import { Admin, Roles } from 'src/admin/schemas/admin.schema';
import { MethodNotAllowedResponse } from 'src/common/errors/MethodNotAllowedResponse';
import { PaginationService } from 'src/common/services/pagination/pagination.service';
import { NotificationsService } from 'src/notifications/services/notifications.service';
import { PaymentsRepository } from 'src/payments/repositories/payments.repository';
import { SubscriptionsService } from 'src/subscriptions/services/subscriptions.service';
import { UserService } from 'src/user/user.service';
import { BikersService } from '../../bikers/services/bikers.service';
import { GetOrdersByAdminDTO } from '../dtos';
import { OrdersRepository } from '../repositories/orders.repository';
import {
  OrderStatus,
  OrderTypes,
  PaymentTypes,
} from '../schemas/orders.schema';
import { OrderStatusValidator } from '../validators/orderStatusValidator';

@Injectable()
export class AdminsOrdersService {
  constructor(
    @InjectConnection() private readonly connection: Connection,
    private ordersRepository: OrdersRepository,
    private adminService: AdminService,
    private paymentsRepository: PaymentsRepository,
    @Inject(forwardRef(() => SubscriptionsService))
    private subscriptionsService: SubscriptionsService,
    private paginationService: PaginationService,
    private orderStatusValidator: OrderStatusValidator,
    @Inject(forwardRef(() => NotificationsService))
    private notificationService: NotificationsService,
    private bikerService: BikersService,
    private userService: UserService,
    private readonly httpService: HttpService,
    private readonly eventEmitter: EventEmitter2,
  ) {}

  /**
   * return -all orders (within cities if sub) /  all if super
   *        - and filter creteria
   */
  async getOrdersByAdmin(
    adminId: string,
    role: string,
    getOrdersByAdminQuery: GetOrdersByAdminDTO,
  ) {
    const { page = 1, perPage = 10, status, search } = getOrdersByAdminQuery;
    const { limit, skip } = this.paginationService.getSkipAndLimit(
      Number(page),
      Number(perPage),
    );
    let admin: Admin;
    if (role === Roles.SubAdmin)
      admin = await this.adminService.getById(adminId);
    const { orders, count } = await this.ordersRepository.findAllByAdmin(
      skip,
      limit,
      role,
      status,
      role === Roles.SubAdmin ? admin.city : [],
      search,
    );
    return this.paginationService.paginate(
      orders,
      count,
      Number(page),
      Number(perPage),
    );
  }

  /**
   *  Set order ACCEPTED_BY_BIKER - assignedBy:adminId - isAssigned:true
   * @param orderId
   * @param bikerId
   * @param adminId
   */
  async assignOrderToBikerByAdmin(
    orderId: string,
    bikerId: string,
    adminId: string,
  ) {
    const order = await this.ordersRepository.findOrderByIdOr404(orderId);
    // Check order status
    if (
      order.status === OrderStatus.WAITING_FOR_BIKER_BY_ADMIN ||
      order.status === OrderStatus.ACCEPTED_BY_BIKER
    ) {
      // Assign Order To Biker
      await this.ordersRepository.update(orderId, {
        assignedBy: adminId,
        isAssigned: true,
        status: OrderStatus.ACCEPTED_BY_BIKER,
        biker: bikerId,
      });

      const biker = await this.bikerService.getByIdOr404(bikerId);

      const userOfOrder = await this.userService.getUser(order.user.toString());

      // TODO: Send Notification to biker and user
      await this.notificationService.sendAdminAssignedOrderToBikerNotification(
        bikerId,
        biker.language,
        biker.fcmTokens,
        orderId,
      );

      await this.notificationService.sendOrderAcceptedByBikerNotificaiton(
        userOfOrder._id.toString(),
        userOfOrder.language || 'en',
        userOfOrder.fcmTokens,
        biker.userName,
        orderId,
        userOfOrder.isAllowNotification,
      );

      return {
        success: true,
        message: 'Order assigned to biker successfully',
      };
    }

    throw new MethodNotAllowedResponse({
      ar: 'لا يمكن تعيين الطلب في هذه المرحلة',
      en: 'Order cannot be assigned at this stage',
    });
  }

  /**
   * return -all orders (within cities if sub) /  all if super
   *        - and filter creteria
   */
  async getAssignedOrdersByAdmin(
    adminId: string,
    getOrdersByAdminQuery: GetOrdersByAdminDTO,
  ) {
    const { page = 1, perPage = 10 } = getOrdersByAdminQuery;

    const { limit, skip } = this.paginationService.getSkipAndLimit(
      Number(page),
      Number(perPage),
    );

    const { orders, count } =
      await this.ordersRepository.findAllAssignedByAdmin(skip, limit, adminId);

    return this.paginationService.paginate(
      orders,
      count,
      Number(page),
      Number(perPage),
    );
  }

  async getOrderById(orderId: string) {
    return await this.ordersRepository.findOrderWithCityByIdPopulatedOr404(
      orderId,
    );
  }

  async findAllUsersWithOrdersAggregator(
    expressionLeftSide: string,
    operator: string,
    expressionRightSide: number,
  ) {
    return await this.ordersRepository.findAllUsersWithOrdersAggregator(
      expressionLeftSide,
      operator,
      expressionRightSide,
    );
  }

  async getOrderDurationReport() {
    return this.ordersRepository.getOrderTotalDurationReport();
  }

  async exportOrdersToExcel() {
    const orders = await this.ordersRepository.getOrdersForExport();

    const workbook = new ExcelJS.Workbook();
    const worksheet = workbook.addWorksheet('Orders');

    worksheet.columns = [
      { header: 'Order ID', key: 'orderID', width: 60 },
      { header: 'Status', key: 'status', width: 30 },
      { header: 'Type', key: 'type', width: 30 },
      { header: 'Payment Type', key: 'paymentType', width: 30 },
      { header: 'Payment Status', key: 'paymentStatus', width: 30 },
      { header: 'Total Price', key: 'totalPrice', width: 20 },
      { header: 'Discount', key: 'discount', width: 20 },
      { header: 'Total Pay', key: 'totalPay', width: 20 },
      { header: 'Start Time', key: 'onWashingAt', width: 30 },
      { header: 'End Time', key: 'endTime', width: 30 },
      { header: 'Duration Time', key: 'durationTime', width: 30 },
      { header: 'Booking Date', key: 'bookingDate', width: 30 },
      { header: 'Time Slot', key: 'timeSlot', width: 30 },
      { header: 'Description', key: 'description', width: 50 },
      { header: 'Cancellation Reason', key: 'cancellationReason', width: 50 },
      { header: 'Cancellation Date', key: 'cancellationDate', width: 30 },
      { header: 'User Name', key: 'userName', width: 50 },
      { header: 'User Phone', key: 'userPhone', width: 60 },
      { header: 'Biker Name', key: 'bikerName', width: 50 },
      { header: 'Biker Phone', key: 'bikerPhone', width: 60 },
      { header: 'Biker Rating', key: 'bikerRating', width: 20 },
      { header: 'Vehicle Type', key: 'vehicleType', width: 30 },
      { header: 'Vehicle Model', key: 'vehicleModel', width: 30 },
      { header: 'Vehicle Brand', key: 'vehicleBrand', width: 30 },
      { header: 'Vehicle Plate Number', key: 'vehiclePlateNumber', width: 30 },
      { header: 'Vehicle Color', key: 'vehicleColor', width: 30 },
      {
        header: 'Vehicle User Serial Number',
        key: 'vehicleUserSerialNumber',
        width: 20,
      },
      { header: 'Vehicle User Name', key: 'vehicleUserName', width: 50 },
      { header: 'Vehicle User Email', key: 'vehicleUserEmail', width: 60 },
      { header: 'Vehicle User Phone', key: 'vehicleUserPhone', width: 60 },
      { header: 'Vehicle User Gender', key: 'vehicleUserGender', width: 30 },
      { header: 'Location Latitude', key: 'locationLatitude', width: 20 },
      { header: 'Location Longitude', key: 'locationLongitude', width: 20 },
      { header: 'Street Name', key: 'streetName', width: 50 },
      {
        header: 'Sub Administrative Area',
        key: 'subAdministrativeArea',
        width: 50,
      },
      { header: 'City Name', key: 'cityName', width: 50 },
      { header: 'Area Name', key: 'areaName', width: 50 },
      { header: 'Location Is Saved', key: 'locationIsSaved', width: 20 },
      { header: 'Location Saved Name', key: 'locationSavedName', width: 50 },
      { header: 'Google Maps Link', key: 'googleMapsLink', width: 80 },
      { header: 'Promo Code', key: 'promoCode', width: 30 },
      {
        header: 'Subscription Plan Type',
        key: 'subscriptionPlanType',
        width: 30,
      },
      {
        header: 'Subscription Plan Color',
        key: 'subscriptionPlanColor',
        width: 30,
      },
      {
        header: 'Subscription Plan Price',
        key: 'subscriptionPlanPrice',
        width: 20,
      },
      {
        header: 'Subscription Remaining Washes',
        key: 'subscriptionRemainingWashes',
        width: 30,
      },
      {
        header: 'Subscription Washes Count',
        key: 'subscriptionWashesCount',
        width: 30,
      },
      {
        header: 'Subscription Plan Services',
        key: 'subscriptionPlanServices',
        width: 60,
      },
      {
        header: 'Washing Services',
        key: 'washingServices',
        width: 60,
      },
      { header: 'Add Ons', key: 'addOns', width: 60 },
      { header: 'Cancelled By Admin', key: 'cancelledByAdmin', width: 50 },
      { header: 'Is Assigned', key: 'isAssigned', width: 20 },
      { header: 'Assigned By', key: 'assignedBy', width: 50 },
      {
        header: 'Rating Of Biker',
        key: 'ratingOfBiker',
        width: 20,
      },
      { header: 'Rating Of User', key: 'ratingOfUser', width: 20 },
      { header: 'Is Points Applied', key: 'isPointsApplied', width: 20 },
      { header: 'Applied Points', key: 'appliedPoints', width: 20 },
      { header: 'Points Discount', key: 'pointsDiscount', width: 20 },
      { header: 'Refund Amount', key: 'refundAmount', width: 20 },
      { header: 'Is Car Freshened', key: 'isCarFreshened', width: 20 },
      { header: 'User OS', key: 'userOS', width: 20 },
      { header: 'Biker Commission', key: 'bikerCommission', width: 20 },
      { header: 'Is Weekend For Biker', key: 'isWeekendForBiker', width: 20 },
      { header: 'Created At', key: 'createdAt', width: 30 },
      { header: 'Updated At', key: 'updatedAt', width: 30 },
    ];

    orders.forEach((order) => {
      const onWashingAtDate = order.onWashingAt
        ? new Date(order.onWashingAt)
        : null;
      const endTimeDate = order.endTime ? new Date(order.endTime) : null;
      const bookingDate = order.bookingDate
        ? new Date(order.bookingDate)
        : null;
      const cancellationDate = order.cancellationDate
        ? new Date(order.cancellationDate)
        : null;
      const createdAt = order.createdAt ? new Date(order.createdAt) : null;
      const updatedAt = order.updatedAt ? new Date(order.updatedAt) : null;

      const isValidDate = (date: Date | null) => date && !isNaN(date.getTime());

      let durationTime = '/';
      if (isValidDate(onWashingAtDate) && isValidDate(endTimeDate)) {
        const durationInMs = endTimeDate.getTime() - onWashingAtDate.getTime();
        if (!isNaN(durationInMs) && durationInMs > 0) {
          const durationInMinutes = Math.floor(durationInMs / 60000);
          const hours = Math.floor(durationInMinutes / 60);
          const minutes = durationInMinutes % 60;
          durationTime = `${hours}h ${minutes}m`;
        }
      }

      const formatDateTime = (date: Date | null) => {
        return isValidDate(date)
          ? `${date.toLocaleDateString()} ${date.toLocaleTimeString()}`
          : '/';
      };

      const startTimeFormatted = formatDateTime(onWashingAtDate);
      const endTimeFormatted = formatDateTime(endTimeDate);
      const bookingDateFormatted = formatDateTime(bookingDate);
      const cancellationDateFormatted = formatDateTime(cancellationDate);
      const createdAtFormatted = formatDateTime(createdAt);
      const updatedAtFormatted = formatDateTime(updatedAt);

      const getNameAsString = (name: any): string => {
        if (!name) return '';
        if (typeof name === 'string') return name;
        if (typeof name === 'object' && name.en) return name.en;
        if (typeof name === 'object' && name.ar) return name.ar;
        return String(name);
      };

      let washingServicesString = '';
      if (order.washingServices && Array.isArray(order.washingServices)) {
        order.washingServices.forEach((service) => {
          const serviceName =
            typeof service === 'object'
              ? getNameAsString(service.name)
              : service;
          washingServicesString = washingServicesString
            .concat(serviceName || '')
            .concat('\n');
        });
      }

      let addOnsString = '';
      if (order.addOns && Array.isArray(order.addOns)) {
        order.addOns.forEach((addOn) => {
          const addOnName =
            typeof addOn === 'object' ? getNameAsString(addOn.name) : addOn;
          addOnsString = addOnsString.concat(addOnName || '').concat('\n');
        });
      }

      const lat = order.location?.latitude;
      const long = order.location?.longitude;
      const googleMapsLink =
        lat && long ? `https://www.google.com/maps?q=${lat},${long}` : null;

      let subscriptionPlanServicesString = '';
      if (
        order.subscription?.plan?.washingServices &&
        Array.isArray(order.subscription.plan.washingServices)
      ) {
        order.subscription.plan.washingServices.forEach((service) => {
          const serviceName =
            typeof service === 'object'
              ? getNameAsString(service.name)
              : service;
          subscriptionPlanServicesString = subscriptionPlanServicesString
            .concat(serviceName || '')
            .concat('\n');
        });
      }

      worksheet.addRow({
        orderID: order._id,
        status: order.status || '/',
        type: order.type || '/',
        paymentType: order.paymentType || '/',
        paymentStatus: order.paymentStatus || '/',
        totalPrice: order.totalPrice || 0,
        discount: order.discount || 0,
        totalPay: order.totalPay || 0,
        onWashingAt: startTimeFormatted,
        endTime: endTimeFormatted,
        durationTime: durationTime,
        bookingDate: bookingDateFormatted,
        timeSlot: order.timeSlot || '/',
        description: order.description || '/',
        cancellationReason: order.cancellationReason || '/',
        cancellationDate: cancellationDateFormatted,
        userName: order.user?.userName || '/',
        userPhone: order.user?.phone || '/',
        bikerName: order.biker?.userName || '/',
        bikerPhone: order.biker?.phone || '/',
        bikerRating: order.biker?.rating || '/',
        vehicleType: order.vehicle?.type || '/',
        vehicleModel: order.vehicle?.model || '/',
        vehicleBrand: order.vehicle?.brand || '/',
        vehiclePlateNumber: order.vehicle?.plateNumber || '/',
        vehicleColor: order.vehicle?.color || '/',
        vehicleUserSerialNumber: order.vehicle?.user?.serialNumber || '/',
        vehicleUserName: order.vehicle?.user?.userName || '/',
        vehicleUserEmail: order.vehicle?.user?.email || '/',
        vehicleUserPhone: order.vehicle?.user?.phone || '/',
        vehicleUserGender: order.vehicle?.user?.gender || '/',
        locationLatitude: lat || '/',
        locationLongitude: long || '/',
        streetName: order.location?.streetName || '/',
        subAdministrativeArea: order.location?.subAdministrativeArea || '/',
        cityName: order.location?.city?.name || '/',
        areaName: order.location?.area?.name || '/',
        locationIsSaved: order.location?.isSaved ? 'Yes' : 'No',
        locationSavedName: order.location?.savedName || '/',
        googleMapsLink: googleMapsLink || '/',
        promoCode: order.promoCode?.code || '/',
        subscriptionPlanType: order.subscription?.plan?.type || '/',
        subscriptionPlanColor: order.subscription?.plan?.color || '/',
        subscriptionPlanPrice: order.subscription?.plan?.price || '/',
        subscriptionRemainingWashes: order.subscription?.remainingWashes ?? '/',
        subscriptionWashesCount: order.subscription?.washesCount ?? '/',
        subscriptionPlanServices: subscriptionPlanServicesString || '/',
        washingServices: washingServicesString || '/',
        addOns: addOnsString || '/',
        cancelledByAdmin: order.cancelledByAdmin?.userName || '/',
        isAssigned: order.isAssigned ? 'Yes' : 'No',
        assignedBy: order.assignedBy?.userName || '/',
        ratingOfBiker: order.ratingOfBiker || '/',
        ratingOfUser: order.ratingOfUser || '/',
        isPointsApplied: order.isPointsApplied ? 'Yes' : 'No',
        appliedPoints: order.appliedPoints || 0,
        pointsDiscount: order.pointsDiscount || 0,
        refundAmount: order.refundAmount || 0,
        isCarFreshened: order.isCarFreshened ? 'Yes' : 'No',
        userOS: order.userOS || '/',
        bikerCommission: order.bikerCommission || 0,
        isWeekendForBiker: order.isWeekendForBiker ? 'Yes' : 'No',
        createdAt: createdAtFormatted,
        updatedAt: updatedAtFormatted,
      });
    });

    const buffer = await workbook.xlsx.writeBuffer();
    return buffer;
  }

  async exportOrdersToCSV() {
    const orders = await this.ordersRepository.getOrdersForExport();

    const calculateDuration = (start: Date, end: Date): string => {
      if (isNaN(start.getTime()) || isNaN(end.getTime())) return '/';
      const durationInMs = end.getTime() - start.getTime();
      if (isNaN(durationInMs) || durationInMs <= 0) return '/';
      const durationInMinutes = Math.floor(durationInMs / 60000);
      const hours = Math.floor(durationInMinutes / 60);
      const minutes = durationInMinutes % 60;
      return `${hours}h ${minutes}m`;
    };

    const formatDateTime = (date: Date) =>
      isNaN(date.getTime())
        ? '/'
        : `${date.toLocaleDateString()} ${date.toLocaleTimeString()}`;

    const transformedOrders = orders.map((order) => {
      const onWashingAtDate = new Date(order.onWashingAt);
      const endTimeDate = new Date(order.endTime);

      return {
        orderID: order._id,
        bikerName: order.biker?.userName || '/',
        vehicleModel: order.vehicle?.model || '/',
        vehicleBrand: order.vehicle?.brand || '/',
        vehiclePlateNumber: order.vehicle?.plateNumber || '/',
        vehicleColor: order.vehicle?.color || '/',
        vehicleUserSerialNumber: order.vehicle?.user?.serialNumber || '/',
        vehicleUserName: order.vehicle?.user?.userName || '/',
        vehicleUserEmail: order.vehicle?.user?.email || '/',
        vehicleUserPhone: order.vehicle?.user?.phone || '/',
        vehicleUserGender: order.vehicle?.user?.gender || '/',
        status: order.status || '/',
        startTime: formatDateTime(onWashingAtDate),
        endTime: formatDateTime(endTimeDate),
        durationTime: calculateDuration(onWashingAtDate, endTimeDate),
      };
    });

    const csvFields = [
      'orderID',
      'bikerName',
      'vehicleModel',
      'vehicleBrand',
      'vehiclePlateNumber',
      'vehicleColor',
      'vehicleUserSerialNumber',
      'vehicleUserName',
      'vehicleUserEmail',
      'vehicleUserPhone',
      'vehicleUserGender',
      'status',
      'startTime',
      'endTime',
      'durationTime',
    ];

    const csv = parse(transformedOrders, { fields: csvFields });

    // fs.writeFileSync('orders.csv', csv);

    return csv;
  }

  async getOrdersRevenuePerMonthForCurrentYear() {
    return await this.ordersRepository.getOrdersRevenuePerMonthForCurrentYear();
  }

  async getOrdersRevenuePerWeek() {
    return await this.ordersRepository.getOrdersRevenuePerWeek();
  }

  async cancelOrderByAdmin(
    orderId: string,
    adminId: string,
    totalAmount: number,
    cancellationReason: string,
  ) {
    const session = await this.connection.startSession();
    try {
      session.startTransaction({ readPreference: 'primary' });

      const order = await this.ordersRepository.findOrderByIdOr404(orderId);
      const orderPopulated =
        await this.ordersRepository.findOrderByIdPopulatedOr404(orderId);

      this.orderStatusValidator.isStatusValidForOrder(
        order,
        OrderStatus.CANCELLED_BY_ADMIN,
      );

      // Fetch admin details to verify city access
      const admin: any = await this.adminService.getById(adminId);
      if (
        !admin ||
        !admin.city.includes(
          (orderPopulated as any)?.location?.city?._id?.toString(),
        )
      ) {
        throw new ConflictException({
          ar: 'المشرف ليس لديه صلاحية الوصول إلى هذه المدينة',
          en: 'Admin does not have access to this city',
        });
      }

      // 🚀 **Process Refund if Paid with Credit Card**
      if (order.paymentType === 'CREDIT' && order.paymentStatus === 'PAID') {
        const payment = await this.paymentsRepository.findOne({
          order: new Types.ObjectId(orderId),
        });

        if (payment && payment.transactionId) {
          await this.processRefund(payment.transactionId, totalAmount, orderId);
        }
      }

      if (
        order.paymentType === PaymentTypes.TAMARA &&
        order.paymentStatus === 'PAID'
      ) {
        const payment = await this.paymentsRepository.findOne({
          order: new Types.ObjectId(orderId),
        });

        if (payment && payment.transactionId) {
          await this.tamaraProcessRefund(
            payment.transactionId,
            totalAmount,
            orderId,
          );
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

      // **Update Order Status & Reason**
      order.status = OrderStatus.CANCELLED_BY_ADMIN;
      order.cancellationDate = new Date();
      order.cancellationReason = cancellationReason;
      order.refundAmount = totalAmount;
      (order as any).cancelledByAdmin = new Types.ObjectId(adminId); // ✅ Store admin ID

      await order.save();

      const user = await this.userService.getUser((order as any).user);

      await this.notificationService.sendOrderCancelledByAdminNotification(
        user._id,
        user.language || 'en',
        user.fcmTokens,
        orderId,
        user.isAllowNotification,
      );
      await session.commitTransaction();
    } catch (error) {
      await session.abortTransaction();
      throw error;
    } finally {
      session.endSession();
    }
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
          comment: 'order cancelled by admin',
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
}
