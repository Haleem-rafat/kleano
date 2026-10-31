class ApiPaths {
  static const String auth = "/auth";
  static const String bikers = "/bikers";
  static const String user = "/user";
  static const String guest = "/guest";
  static const String notifications = "/notifications";

  // Auth
  static const String logIn = "$auth$bikers/login";
  static const String logOut = "$auth$bikers/logout";
  static const String checkPhone = "$auth$bikers/check-phone";
  static const String resetPassword = "$auth$bikers/reset-password";
  static const String updatePassword = "$bikers/update-credentials";
  static const String updateInfo = "$bikers/update-info";
  static const String updateStatus = "$bikers/update-status";
  static const String refreshTokens = "$auth/refresh-token";
  static const String updatelanguage = "$bikers/update-language";

  //Orders
  static const String bikerOrder = "/orders/biker?status=";
  static const String bikerOrderAccept = "/orders/biker/accept-order";
  static const String BikerOnTheWayOrder = "/orders/biker/on-the-way";
  static const String BikerArrivedOrder = "/orders/biker/arrived";
  static const String BikerOnWashingOrder = "/orders/biker/on-washing";
  static const String BikerCompleteOrder = "/orders/biker/completed";
  static const String BikerCancelOrder = "/orders/biker/cancel-order";
  static const String bikerOrderDetails = "/orders/user/order-details/";
  static const String bikerOrderRating = "/orders/biker/rate-order";
  static const String bikerTotalCommission = "/orders/biker/total-commission";
  static const String bikerSchedule = "/biker/schedule";
}
