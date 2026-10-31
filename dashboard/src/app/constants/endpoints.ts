/* eslint-disable no-unused-vars */
export enum EAPI {
  // auth
  LOGIN = '/auth/admins/login',
  REFRESH_TOKEN = '/auth/refresh-token',
  //----------------------------------------------------------------------------------------------------------//
  BIKERS = '/bikers',
  BIKERS_BY_AREA_ID = '/bikers/admin/by-area/:areaId',
  BIKERS_LIST = '/bikers/admin/performance-report',
  BIKER_EXCEL = '/bikers/admin/excel',
  BIKER_SCHEDULES = '/admin/biker-schedules',
  BIKER_SCHEDULE_DATA = '/admin/biker-schedules/biker',
  BIKER_TOTAL_COMMISSION = '/orders/admins/biker/:bikerId/total-commission',
  // washing services
  WASHING_SERVICE = '/washing-services',
  WASHING_SERVICE_LIST = '/washing-services/admin/all',
  WASHING_SERVICE_DETAILS = '/washing-services/admin/details',
  WASHING_SERVICE_CITY = '/washing-services/services-cities',
  WASHING_SERVICE_CITY_ACTIVATE = '/washing-services/services-cities/activate',
  WASHING_SERVICE_CITY_ARCHIVE = '/washing-services/services-cities/archive',
  //----------------------------------------------------------------------------------------------------------//
  // plans
  PLANS = '/plans',
  PLANS_LIST = '/plans/admin/all',
  PLANS_LIST_DETAILS = '/plans/admin/details',
  PLANS_LIST_CITY = '/plans/plans-cities',
  PLANS_LIST_CITY_ACTIVATE = '/plans/plans-cities/activate',
  PLANS_LIST_CITY_ARCHIVE = '/plans/plans-cities/archive',
  //----------------------------------------------------------------------------------------------------------//
  // add ons
  ADD_ONS = '/add-ons',
  ADD_ONS_LIST = '/add-ons/admin/all',
  ADD_ONS_DETAILS = '/add-ons/admin/details',
  ADD_ONS_CITY = '/add-ons/add-ons-cities',
  ADD_ONS_CITY_ACTIVATE = '/add-ons/add-ons-cities/activate',
  ADD_ONS_CITY_ARCHIVE = '/add-ons/add-ons-cities/archive',
  //----------------------------------------------------------------------------------------------------------//
  // Prmo codes
  PROMO_CODE = '/promo-codes/admin',
  EDIT_CODE_NAME = '/promo-codes/:id',
  PROMO_CODE_ALL_USERS = '/promo-codes/all-users',
  PROMO_CODE_SEGMENT = '/promo-codes/segment',
  PROMO_CODE_NEW_COMERS = '/promo-codes/new-comers',
  PROMO_CODE_AGGREGATOR = '/promo-codes/aggregator',
  PROMO_CODE_OFFLINE = '/promo-codes/offline',
  PROMO_CODE_B2B = '/promo-codes/b2b',
  //----------------------------------------------------------------------------------------------------------//
  // segments
  SEGMENTS_LIST = '/segments',
  //----------------------------------------------------------------------------------------------------------//
  // orders
  ORDER = '/orders/admins',
  ORDERS_LIST = '/orders/admins/all',
  ORDERS_ASSIGNED = '/orders/admins/assigned',
  ORDER_DETAILS = '/orders/admins/order-details',
  ORDER_EXPORT_EXCEL = '/orders/admins/export-orders-excel',
  ORDER_CANCEL_BY_ADMIN = '/orders/admins/cancel-order',
  //----------------------------------------------------------------------------------------------------------//
  // points
  POINTS = '/points',
  POINTS_LIST = '/points/admin/points-system',
  //----------------------------------------------------------------------------------------------------------//
  //  static
  CITIES = '/cities',
  AREAS = '/areas/city',
  MAP_AREAS = '/areas/location',
  ICONS = '/services-icons',
  PROMO_CODE_ALL = '/promo-codes/admin/dropdown',
  PLANS_ALL = '/plans/admin/dropdown',
  //
  REVENUE_PER_WEEK = '/orders/admins/revenue-per-week',
  REVENUE_PER_MONTH = '/orders/admins/revenue-per-month',
  //
  USERS = '/users/admin',
  USERS_EXPORT_EXCEL = '/users/export-users-excel',
  SUSPEND_USER = '/users-admin',
  USERS_ADD_BALANCE = '/users-admin/:userId/add-balance',
  //----------------------------------------------------------------------------------------------------------//
  //admins
  ADMIN_LIST = '/admins/all',
  ADMIN_EDIT = '/admins/:id/update-info',
  ADMIN_CREATE = '/admins',
  ADMIN_DETAILS = '/admins/:id/details',
  ADMIN_DELETE = '/admins/:id',
  ADMIN_TOGGLE = '/admins/:id',
  //----------------------------------------------------------------------------------------------------------//
  //assigned orders
  ASSIGNED_ORDERS_lIST = '/orders/admins/assigned',
  //----------------------------------------------------------------------------------------------------------//
  //notifications
  NOTIFICATIONS = '/notifications',
  READ_NOTIFICATION = '/notifications/:id/set-read',
  //----------------------------------------------------------------------------------------------------------//
  //----------------------------------------------------------------------------------------------------------//
  // TERMS
  TERMS = '/terms',

  // banners

  BANNERS = '/banners',

  // CONTACT INFO
  CONTACT_INFO = '/contact-info',

  // profile
  ADMIN_PROFILE = '/admins',
  UPDATE_MY_PASSWORD = '/admins/update-credentials',
  UPDATE_ADMIN_PASSWORD = 'admins/:id/update-credentials',
  UPDATE_BIKER_PASSWORD = 'bikers/:id/admin/change-password',

  // BOOKING
  BOOKING_DAYS = '/booking-availabilities/admin',
  BOOKING_ALL = '/admin/biker-schedules',
  // Transactions
  TRANSACTIONS_LIST = '/payments/admins/all',
  TRANSACTIONS_DETAILS = '/payments/admins/payment-details'
}
