class ApiPaths {
  static const String auth = "/auth";
  static const String users = "/users";
  static const String user = "/user";

  static const String guest = "/guest";
  static const String register = "$auth$users/register";
  static const String login = "$auth$users/login";
  static const String checkPhone = "$auth$users/check-phone";
  static const String refreshTokens = "$auth/refresh-token";
  static const String logout = "$auth$users/logout";
  static const String updatePhoneNumber = "$users/phone-number";

  //Vehicles
  static const String vehicles = "$users/vehicles";
  static const String createVehicles = "/vehicles";
  static const String carModel = "/vehicles/cars-model";
  static const String cars = "/cars";

  //promo-code
  static const String promoCode = "/promo-codes$user";

  //Home
  static const String userLocation = "$users/user-location";
  static const String savedLocation = "/locations/saved-locations";
  static const String recentLocation = "/locations/recent-locations";
  static const String washingServices = "/washing-services$user";
  static const String washingAddOns = "/add-ons$user";
  static const String washingGuestServices = "/washing-services$guest";
  static const String washingGuestAddOns = "/add-ons$guest";
  // subscription plan
  static const String plansUserAll = "/plans/user/all";
  static const String plansGuestAll = "/plans/guest/all";
  static const String subscriptionUser = "/subscriptions/user";
  static const String subscriptions = "/subscriptions";
  static const String paySubscription = "/subscriptions/user/pay-subscription";
  // create order
  static const String orders = "/orders";

  static const String subscriptionsUserLocation =
      "$subscriptions$user/location";
  static const String createOrder = "$orders$user/create-order";
  static const String setPaymentType = "$orders$user/set-payment-type";
  static const String cancelOrder = "$orders$user/cancel-order";
  static const String applyPromoCode = "$orders$user/apply-promo-code";
  static const String payOrder = "$orders$user/pay-order";
  static const String orderUserAll = "$orders$user/all";
  static const String notifications = "/notifications";
  static const String notification = "/notification";
  static const String notificationPermission = "$users/notification-permission";
  static const String orderDetails = "/order-details";
  static const String userLanguage = "$users/user-language";
  static const String rateOrder = "$orders/$user/rate-order";
  static const String calenderAvalabile = "$user/biker-schedules";

// point
  static const String userPoints = "$users/points-system";
  static const String applyPoints = "$orders/$user/apply-points";
  static const String calculatePointsDiscount = "/points/calculate-discount";

  // wallet
  static const String walletTopup = "$users/wallet/topup";

  // about us
  static const String contactInfo = "/contact-info";
  static const String termsAndConditions = "/terms";

  //Banners
  static const String banners = "/banners/active-banner";
}
