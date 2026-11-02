export enum ROUTES {
  MAIN = '/',

  // forbidden
  FORBIDDEN = '/forbidden',

  //----------------- auth------------------//
  LOG_IN = '/auth/log-in',
  //----------------- dashboard------------------//
  DASH_BOARD = '/app/dashboard',
  // users
  USERS = '/app/users',
  USERS_DETAILS = '/app/users/:userId',
  // admin
  ADMIN = '/app/admin',
  ADMIN_DETAILS = '/app/admin/:adminId',
  // bikers
  BIKERS = '/app/bikers',
  BIKERS_DETAILS = '/app/bikers/:bikerId',
  BIKERS_SCHEDULE = '/app/bikers/:bikerId/schedule',
  // washing
  WASHING_SERVICES = '/app/washing-services',
  WASHING_SERVICES_DETAILS = '/app/washing-services/:washingServicesId',
  // plans
  PLANS = '/app/plans',
  PLANS_DETAILS = '/app/plans/:plansId',
  // add ons
  ADD_ONS = '/app/add-ons',
  ADD_ONS_DETAILS = '/app/add-ons/:addOnsId',
  // promo code
  PROMO_CODE = '/app/promo-code',
  // segments
  SEGMENTS = '/app/segments',
  SEGMENTS_DETAILS = '/app/segments/:segmenId',
  // order
  ORDER = '/app/order',
  ORDER_DETAILS = '/app/order/:orderId',
  ASSIGN_ORDER = '/app/assign-order',
  POINTES = '/app/pointes',
  ICONS = '/app/icons',
  NOTIFICATION = '/app/notification',
  TRANSCTION = '/app/transaction',
  TERMS_AND_CONDITIONS = '/app/terms-and-conditions',
  CONTACT_INFO = '/app/contact-info',
  PROFILE = '/app/profile',

  APP_BANNER = '/app/app-banner',
  BOOKING = '/app/booking',
  BOOKING_CALENDAR = '/app/booking-calendar',
  BOOKING_CALENDAR_2 = '/app/booking-calendar-2',
}
