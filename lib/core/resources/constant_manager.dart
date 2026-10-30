class AppConstants {
  static const int splashDelay = 2;
  static const String hintEmail = 'info@kleanoapp.com';
  static const String codeSaudiArabia = '+966';
  static const String subscriptionBooking = 'SUBSCRIPTION_BOOKING';
  static const String serviceBooking = 'SERVICE_BOOKING';
  static const String creadit = 'CREDIT';
  static const String applePay = 'APPLE_PAY';
  static const String wallet = 'WALLET';
  static const String subscribed = 'SUBSCRIBED';

  // Payment type values
  static const int paymentTypeCreditCard = 1;
  static const int paymentTypeWallet = 2;
  static const int paymentTypeApplePay = 3;
  static const String active = 'ACTIVE';
  static const String myBookingHistory = 'HISTORY';
  static const String myBookingScheduled = 'SCHEDULED';
  static const String socketUrl =
      'https://kleano-backend.onrender.com';
  static const String orderAccepted = 'order:accepted';
  static const String orderOnTheWay = 'order:on-the-way';
  static const String bikerMove = 'biker:move';
  static const String orderArrived = 'order:arrived';
  static const String orderOnWashing = 'order:on-washing';
  static const String orderCompleted = 'order:completed';
  static const String acceptedByBiker = 'ACCEPTED_BY_BIKER';
  static const String bikerOnTheWay = 'BIKER_ON_THE_WAY';
  static const String bikerArrived = 'BIKER_ARRIVED';
  static const String onWashing = 'ON_WASHING';
  static const String completed = 'COMPLETED';
  static const String on = 'on';
  static const String off = 'off';
  static const String promoCodeBased = 'NEW_PROMO_CODE';
  static const String orderTracking = 'ORDER_TRACKING';
  static const String completedOrder = 'ORDER_COMPLETED';
  static const String orderWaitingForAdmin = 'ORDER_WAITING_FOR_ADMIN';
  static const String waitingForBikerByAdmin = 'WAITING_FOR_BIKER_BY_ADMIN';

  static const String english = 'English';
  static const String arabic = 'العربية';

  static const String currencySAR = 'SAR';
  static const String paymentUrl = 'https://api.moyasar.com/v1/payments';
  static const String approved = 'APPROVED';
  static const String unspecified = 'UNSPECIFIED_FAILUER';
  static const String insufficient = 'INSUFFICIENT_FUNDS';
  static const String notEnrolled =
      '3-D Secure transaction attempt failed (Not Enrolled)';
  static const String declined = 'DECLINED';
}
