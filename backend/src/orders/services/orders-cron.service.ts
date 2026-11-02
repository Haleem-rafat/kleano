import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { MoyasarPaymentStatus } from 'src/payments/schemas/payments.schema';
import { OrdersRepository } from '../repositories/orders.repository';
import { OrderStatus } from '../schemas/orders.schema';

@Injectable()
export class OrdersCronService {
  private readonly logger = new Logger(OrdersCronService.name);

  constructor(private readonly ordersRepository: OrdersRepository) {}

  /**
   * Cron job that runs every 30 minutes to check for expired pending payments
   * Marks orders as PAYMENT_FAILED if they've been pending for more than 15 minutes
   */
  @Cron('*/30 * * * *') // Runs every 30 minutes
  async handleExpiredPendingPayments() {
    this.logger.log('Running cron job: Check expired pending payments');

    try {
      // Calculate the time threshold (15 minutes ago)
      const twoMinutesAgo = new Date();
      twoMinutesAgo.setMinutes(twoMinutesAgo.getMinutes() - 15);

      // Find orders that are pending payment and created more than 15 minutes ago
      const expiredOrders =
        await this.ordersRepository.findExpiredPendingOrders(
          OrderStatus.PENDING_USER_PAYMENT,
          twoMinutesAgo,
        );

      if (expiredOrders.length === 0) {
        return;
      }

      this.logger.log(
        `Found ${expiredOrders.length} expired pending payment orders`,
      );

      let successCount = 0;
      let failedCount = 0;

      // Update each expired order
      for (const order of expiredOrders) {
        try {
          await this.ordersRepository.updateOrderStatus(order._id.toString(), {
            status: OrderStatus.PAYMENT_FAILED,
            paymentStatus: MoyasarPaymentStatus.FAILED,
          });

          successCount++;
          this.logger.debug(
            `Marked order ${order._id} as PAYMENT_FAILED (created: ${order.createdAt})`,
          );
        } catch (error) {
          failedCount++;
          this.logger.error(
            `Failed to update order ${order._id}: ${error.message}`,
          );
        }
      }

      this.logger.log(
        `Expired pending payments processed - Success: ${successCount}, Failed: ${failedCount}`,
      );
    } catch (error) {
      this.logger.error(
        `Error in handleExpiredPendingPayments cron job: ${error.message}`,
      );
    }
  }
}
