import { Injectable } from '@nestjs/common';
import { ordersModelName } from '../../orders/schemas/orders.schema';
export type Notification = {
  ar: {
    title: string;
    body: string;
  };
  en: {
    title: string;
    body: string;
  };
  data: {
    clickableItem?: string;
    clickItemModel?: string;
    receiverId?: string;
    receiverModel?: string;
    role?: string;
  };
};
@Injectable()
export class NotificationsMessages {
  constructor() {
    /* TODO document why this constructor is empty */
  }

  static newPromoCodePublished(
    code: string,
    discountPercentage?: number,
    discountFixedNumber?: number,
  ): Notification {
    const arDiscountText =
      discountPercentage != null
        ? `${discountPercentage}%`
        : discountFixedNumber != null
        ? `${discountFixedNumber} ريال سعودي`
        : '';
    const enDiscountText =
      discountPercentage != null
        ? `${discountPercentage}%`
        : discountFixedNumber != null
        ? `${discountFixedNumber} SAR`
        : '';

    return {
      ar: {
        title: `رمز ترويجي جديد متاح`,
        body: `استخدم الرمز ${code} لتحصل على خصم ${arDiscountText}`,
      },
      en: {
        title: 'A small gift awaits you',
        body: `Use code ${code} to get a ${enDiscountText} discount`,
      },
      data: {
        role: 'user',
      },
    };
  }

  static orderAssignedByAdminMessage(
    bikerName: string,
    orderId: string,
    receiverId: string,
  ): Notification {
    return {
      ar: {
        title: `تم تعيين بايكر لطلبك`,
        body: `قام المشرف بتعيين بايكر ${bikerName} لطلبك`,
      },
      en: {
        title: 'Your request has been confirmed',
        body: `${bikerName} accepts your request`,
      },
      data: {
        clickableItem: orderId.toString(),
        clickItemModel: ordersModelName,
        receiverId: receiverId.toString(),
        receiverModel: 'user',
        role: 'user',
      },
    };
  }

  static orderAcceptedByBikerMessage(
    bikerName: string,
    orderId: string,
    receiverId: string,
  ): Notification {
    return {
      ar: {
        title: `تم قبول طلبك`,
        body: `بايكر ${bikerName} سيقوم بتنفيذ طلبك`,
      },
      en: {
        title: 'Your request has been confirmed',
        body: `${bikerName} accepts your request`,
      },
      data: {
        clickableItem: orderId.toString(),
        clickItemModel: ordersModelName,
        receiverId: receiverId.toString(),
        receiverModel: 'user',
        role: 'user',
      },
    };
  }

  static bikerOntheWayMessage(
    orderId: string,
    receiverId: string,
  ): Notification {
    return {
      ar: {
        title: `البايكر في طريقه إليك الان 🏍️`,
        body: `البايكر متجه لموقعك لتنفيذ طلب غسيل سيارتك .. شكرًا لإختيارك خدمتنا`,
      },
      en: {
        title: 'The biker is on the way to you now 🏍️',
        body: `The biker is heading to your location to complete your car wash request.
        Thank you for choosing our service.`,
      },
      data: {
        clickableItem: orderId.toString(),
        clickItemModel: ordersModelName,
        receiverId: receiverId.toString(),
        receiverModel: 'user',
        role: 'user',
      },
    };
  }

  static bikerArrivedMessage(
    orderId: string,
    receiverId: string,
  ): Notification {
    return {
      ar: {
        title: `وصل البايكر إلى موقعك 📍`,
        body: `البايكر وصل وجاهز لبدء غسيل سيارتك`,
      },
      en: {
        title: 'The biker has arrived at your location 📍',
        body: `The biker has arrived and is ready to start washing your car.`,
      },
      data: {
        clickableItem: orderId.toString(),
        clickItemModel: ordersModelName,
        receiverId: receiverId.toString(),
        receiverModel: 'user',
        role: 'user',
      },
    };
  }

  static orderCompletedMessage(
    orderId: string,
    receiverId: string,
  ): Notification {
    return {
      ar: {
        title: `تم اكتمال غسيل سيارتك ✨`,
        body: `نأمل ان تنال الخدمة رضاك.. نتطلع لخدمتك مرة أخرى`,
      },
      en: {
        title: 'Your car wash is complete ✨',
        body: `We hope you are satisfied with the service.
        We look forward to serving you again.`,
      },
      data: {
        clickableItem: orderId.toString(),
        clickItemModel: ordersModelName,
        receiverId: receiverId.toString(),
        receiverModel: 'user',
        role: 'user',
      },
    };
  }

  static orderUnderReviewMessage(
    orderId: string,
    receiverId: string,
  ): Notification {
    return {
      ar: {
        title: `قيد البحث عن بايكر`,
        body: `سيتم تأكيد طلبك خلال ١٠ دقائق`,
      },
      en: {
        title: 'Searching for the biker',
        body: `Your order will be confirmed within 10 minutes`,
      },
      data: {
        clickableItem: orderId.toString(),
        clickItemModel: ordersModelName,
        receiverId: receiverId.toString(),
        receiverModel: 'user',
        role: 'user',
      },
    };
  }

  static orderCancelledMessage(
    orderId: string,
    receiverId: string,
  ): Notification {
    return {
      ar: {
        title: 'تم إلغاء الطلب',
        body: 'تم إلغاء طلبك بنجاح',
      },
      en: {
        title: 'Order Cancelled',
        body: `Your order is Cancelled`,
      },
      data: {
        clickableItem: orderId.toString(),
        clickItemModel: ordersModelName,
        receiverId: receiverId.toString(),
        receiverModel: 'user',
        role: 'user',
      },
    };
  }

  static orderRefundFailedMessage(
    orderId: string,
    receiverId: string,
  ): Notification {
    return {
      ar: {
        title: 'فشل استرداد المبلغ',
        body: `فشل استرداد مبلغ الحجز رقم ${orderId}. يرجى التواصل مع الدعم للمساعدة.`,
      },
      en: {
        title: 'Refund Failed',
        body: `Your refund for booking ID ${orderId} has failed. Please contact support for assistance.`,
      },
      data: {
        clickableItem: orderId.toString(),
        clickItemModel: ordersModelName,
        receiverId: receiverId.toString(),
        receiverModel: 'user',
        role: 'user',
      },
    };
  }

  static assignOrderToBikerByAdminMessage(
    orderId: string,
    receiverId: string,
  ): Notification {
    return {
      ar: {
        title: `تم تعيين طلب جديد`,
        body: `قام المشرف بتعيينك على الطلب. اضغط هنا للاطلاع على التفاصيل.`,
      },
      en: {
        title: 'Assigned order',
        body: `The Admin Assigned you to order, click here to know more details`,
      },
      data: {
        clickableItem: orderId.toString(),
        clickItemModel: ordersModelName,
        receiverId: receiverId.toString(),
        receiverModel: 'biker',
        role: 'biker',
      },
    };
  }

  static newOrderCreated(orderId: string, receiverId: string): Notification {
    return {
      ar: {
        title: `طلب جديد`,
        body: `لديك طلب جديد. اضغط هنا للاطلاع على التفاصيل.`,
      },
      en: {
        title: 'New Order',
        body: `You have a new order. Click here to view details.`,
      },
      data: {
        clickableItem: orderId.toString(),
        clickItemModel: ordersModelName,
        receiverId: receiverId.toString(),
        receiverModel: 'biker',
        role: 'biker',
      },
    };
  }

  static orderPendingAdminAssign(orderId: string): Notification {
    return {
      ar: {
        title: `طلب قيد الانتظار`,
        body: `الطلب ${orderId} في انتظار تعيين المشرف لأكثر من ٥ دقائق`,
      },
      en: {
        title: 'Pending request',
        body: `The request ${orderId.toString()} is pending for more than 5 minutes`,
      },
      data: {
        clickableItem: orderId.toString(),
        clickItemModel: ordersModelName,
        receiverModel: 'admin',
        role: 'admins',
      },
    };
  }

  static orderCancellingAdminAssign(order: any): Notification {
    return {
      ar: {
        title: 'تم إلغاء الطلب',
        body: `تم إلغاء الطلب رقم ${order._id.toString()}.
رقم الحجز: ${order._id.toString()}
تاريخ الحجز ووقته: ${order.bookingDate.toISOString()} عند ${order.startTime.toISOString()}
مبلغ الاسترداد: ${order.totalPay} ريال سعودي.`,
      },
      en: {
        title: 'Cancelling order',
        body: `The request ${order._id.toString()} is cancelled.
Booking ID: ${order._id.toString()}
Booking Date & Time: ${order.bookingDate.toISOString()} at ${order.startTime.toISOString()}
Refund Amount: ${order.totalPay} SAR`,
      },
      data: {
        clickableItem: order._id.toString(),
        clickItemModel: ordersModelName,
        receiverModel: 'admin',
        role: 'admins',
      },
    };
  }
}
