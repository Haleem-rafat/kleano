import { forwardRef, Inject, Logger } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { UsersOrdersService } from '../services/userOrders.service';
import { EmailService } from 'src/common/services/email.service';
import { UserRepository } from 'src/user/user.repository';

export class OrderEventListener {
  constructor(
    @Inject(forwardRef(() => UsersOrdersService))
    private usersOrdersService: UsersOrdersService,
    private readonly emailService: EmailService,
    private readonly userRepository: UserRepository,
  ) {}

  @OnEvent('order:email')
  async handleOrderEmail({ orderId }: { orderId: string }) {
    const order = await this.usersOrdersService.getOrderById(orderId);

    if ((order as any).isAdminEmailSent) {
      Logger.warn(
        `Skipping admin email for order ${orderId}: already processed`,
      );
      return;
    }

    (order as any).isAdminEmailSent = true;
    await order.save();

    await this.sendAdminEmail({ orderId });
  }

  async sendAdminEmail({ orderId }: { orderId: string }) {
    try {
      // Fetch order details
      const order = await this.usersOrdersService.getOrderByIdPopulated(
        orderId,
      );
      if (!order) {
        Logger.warn(`Order not found for notification: ${orderId}`);
        return;
      }

      // Fetch user details
      const user = await this.userRepository.findUserById(
        String((order.user as any)._id || order.user),
      );
      if (!user) {
        Logger.warn(`User not found for order: ${orderId}`);
        return;
      }

      // Format booking date and time
      const bookingDate = order.bookingDate
        ? new Date(order.bookingDate).toLocaleDateString('en-US', {
            weekday: 'long',
            year: 'numeric',
            month: 'long',
            day: 'numeric',
          })
        : 'N/A';

      const timeSlot = order.timeSlot || 'N/A';

      // Map service items
      const services = order.washingServices.map((ws: any) => ({
        name: ws.service?.name || {
          ar: 'خدمة غير معروفة',
          en: 'Unknown Service',
        },
        price: ws.price * (ws.quantity || 1),
      }));

      // Map add-ons
      const addOns = order.addOns?.map((addon: any) => ({
        name: addon.addOn?.name || {
          ar: 'إضافة غير معروفة',
          en: 'Unknown Add-on',
        },
        price: addon.price * (addon.quantity || 1),
      }));

      // Get vehicle and location details
      const vehicle = order.vehicle as any;
      const vehicleDetails = vehicle
        ? `${vehicle.vehicleType?.nameEn || 'Unknown'} - ${
            vehicle.plateLetters || ''
          } ${vehicle.plateNumber || ''}`
        : 'N/A';

      const location = order.location as any;
      const locationAddress = location?.address || 'N/A';

      // Send email to admin
      await this.emailService.sendEmail('ORDER_CREATED', {
        orderData: {
          orderId: String(order._id),
          orderNumber: `#${orderId}`,
          customerName: user.userName,
          customerPhone: user.phone,
          customerEmail: user.email,
          services,
          addOns: addOns?.length > 0 ? addOns : undefined,
          vehicleDetails,
          locationAddress,
          bookingDate,
          timeSlot,
          totalPrice: order.totalPrice,
          discount: order.discount || 0,
          totalPay: order.totalPay,
          paymentStatus: order.paymentStatus,
          paymentType: order.paymentType,
          orderStatus: order.status,
          createdAt: new Date(order.createdAt).toLocaleString('en-US'),
        },
        email: process.env.NODEMAILER_EMAIL_FROM || 'info@kleanoapp.com',
        senderName: 'Kleano System',
        subject: `New Order Created - ${orderId}`,
      });

      Logger.log(`Admin email sent successfully for order: ${orderId}`);
    } catch (error) {
      Logger.error(
        `Failed to send admin email for order ${orderId}: ${error.message}`,
      );
      // Don't throw - we don't want to break the order flow if email fails
    }
  }
}
