import { Injectable } from '@nestjs/common';
import { OrderStatus, Order } from '../schemas/orders.schema';
import { MethodNotAllowedResponse } from '../../common/errors/MethodNotAllowedResponse';

@Injectable()
export class OrderStatusValidator {
  private StatusHirarchy = {
    '': [
      OrderStatus.PENDING_USER_PAYMENT,
      OrderStatus.PENDING_USER_REVIEW,
      OrderStatus.ACTIVE,
    ],
    [OrderStatus.PENDING_USER_PAYMENT]: [
      OrderStatus.ACTIVE,
      OrderStatus.CANCELLED_BY_USER,
    ],
    [OrderStatus.PENDING_USER_REVIEW]: [
      OrderStatus.ACTIVE,
      OrderStatus.CANCELLED_BY_USER,
    ],
    [OrderStatus.ACTIVE]: [
      OrderStatus.CANCELLED_BY_USER,
      OrderStatus.ACCEPTED_BY_BIKER,
      OrderStatus.WAITING_FOR_BIKER_BY_ADMIN,
      OrderStatus.CANCELLED_BY_ADMIN,
    ],
    [OrderStatus.CANCELLED_BY_ADMIN]: [],
    [OrderStatus.CANCELLED_BY_USER]: [],
    [OrderStatus.ACCEPTED_BY_BIKER]: [
      OrderStatus.BIKER_ON_THE_WAY,
      OrderStatus.CANCELLED_BY_BIKER,
      OrderStatus.CANCELLED_BY_ADMIN,
    ],
    [OrderStatus.WAITING_FOR_BIKER_BY_ADMIN]: [
      OrderStatus.ACCEPTED_BY_BIKER,
      OrderStatus.CANCELLED_BY_ADMIN,
    ],
    [OrderStatus.BIKER_ON_THE_WAY]: [
      OrderStatus.BIKER_ARRIVED,
      OrderStatus.CANCELLED_BY_ADMIN,
    ],
    [OrderStatus.CANCELLED_BY_BIKER]: [],
    [OrderStatus.BIKER_ARRIVED]: [OrderStatus.ON_WASHING],
    [OrderStatus.ON_WASHING]: [OrderStatus.COMPLETED],
    [OrderStatus.COMPLETED]: [],
  };

  constructor() {
    /* TODO document why this constructor is empty */
  }

  isStatusValidForOrder(order: Order, newStatus: OrderStatus) {
    if (this.StatusHirarchy[order.status].includes(newStatus)) return true;

    throw new MethodNotAllowedResponse({
      ar: 'حالة الطلب المدخلة غير مناسبة',
      en: 'Not valid OrderStatus for the current status',
    });
  }
}
