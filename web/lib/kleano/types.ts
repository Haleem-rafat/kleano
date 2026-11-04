/**
 * Shapes of the Kleano API replies the customer web app reads. Field names follow the backend
 * schemas (backend/src/**\/schemas) and the customer app's models.
 */

/** Backend LocalizedText: every name comes in both languages. */
export type LocalizedText = { ar?: string; en?: string };

export type Wrapped<T> = { success: boolean; data: T };
export type Paged<T> = { success: boolean; totalPages: number; totalItems: number; data: T[] };

export type City = { _id: string; name?: LocalizedText };

export type Location = {
  _id: string;
  latitude: number;
  longitude: number;
  streetName?: string;
  subAdministrativeArea?: string;
  /** Saved places carry the city and area ids that the free-time lookup needs. */
  city?: City | string;
  area?: { _id: string } | string;
  country?: string;
  isSaved?: boolean;
  savedName?: string;
  isDefault?: boolean;
};

export type Profile = {
  _id: string;
  userName: string;
  phone: string;
  email?: string;
  points?: number;
  walletBalance?: number;
  imageLink?: string;
  gender?: string;
  isSubscribed?: boolean;
  isAllowNotification?: boolean;
  dob?: string;
  location?: Location;
};

export type Vehicle = {
  _id: string;
  type?: string;
  brand?: string;
  model?: string;
  plateNumber?: string;
  color?: string;
  imageLink?: string;
};

export type Icon = { iconLink?: string; iconPath?: string };

export type WashingService = {
  _id: string;
  name: LocalizedText;
  description?: LocalizedText[];
  price: number;
  duration?: number;
  icon?: Icon;
  type?: string;
};

export type AddOn = { _id: string; name: LocalizedText; price: number; icon?: Icon };

export type Plan = {
  _id: string;
  type: LocalizedText;
  color?: string;
  price: number;
  duration?: number;
  durationUnit?: string;
  usageCount?: number;
  pointsToPay?: number;
  isSubscribed?: boolean;
  description?: LocalizedText[];
  washingServices?: WashingService[];
  icon?: Icon;
};

/** backend/src/subscriptions/schemas: remainingWashes counts down from plan.usageCount. */
export type Subscription = {
  _id: string;
  plan?: Plan;
  remainingWashes?: number;
  washesCount?: number;
  expiryDate?: string;
  status?: string;
};

/** GET /users/points-system */
export type PointsInfo = { points: number; pointsExchange: number; redeemLimit: number };

export type PromoCode = {
  _id: string;
  code: string;
  expiryDate?: string;
  discountPercentage?: number;
  discountFixedNumber?: number;
  status?: string;
  numberOfUses?: number;
};

export type KleanoNotification = {
  _id: string;
  message?: { arTitle?: string; arBody?: string; enTitle?: string; enBody?: string };
  isRead?: boolean;
  type?: string;
  orderId?: string;
  createdAt?: string;
};

export type ContactInfo = {
  contactTitle?: string;
  emails?: string[];
  phoneNumbers?: string[];
  whatsAppNumber?: string;
  facebookLink?: string;
  instagramLink?: string;
  twitterLink?: string;
  youtubeLink?: string;
  linkedinLink?: string;
  tiktokLink?: string;
  website?: string;
};

export type Banner = {
  _id: string;
  title?: string;
  description?: string;
  imageLink?: string;
  imageLinkAr?: string;
  externalUrl?: string;
};

export type Biker = { _id: string; userName?: string; phone?: string; imageLink?: string; rating?: number; latitude?: number; longitude?: number };

/** backend/src/orders/schemas/orders.schema.ts OrderStatus */
export type OrderStatus =
  | 'PENDING_USER_PAYMENT'
  | 'PENDING_USER_REVIEW'
  | 'ACTIVE'
  | 'CANCELLED_BY_USER'
  | 'CANCELLED_BY_ADMIN'
  | 'ACCEPTED_BY_BIKER'
  | 'WAITING_FOR_BIKER_BY_ADMIN'
  | 'BIKER_ON_THE_WAY'
  | 'CANCELLED_BY_BIKER'
  | 'BIKER_ARRIVED'
  | 'ON_WASHING'
  | 'COMPLETED'
  | 'SCHEDULED'
  | 'PAYMENT_FAILED';

export type Order = {
  _id: string;
  status: OrderStatus;
  washingServices?: WashingService[];
  addOns?: AddOn[];
  vehicle?: Vehicle;
  location?: Location;
  biker?: Biker;
  promoCode?: { code?: string };
  timeSlot?: string;
  bookingDate?: string;
  startTime?: string;
  endTime?: string;
  totalDuration?: number;
  paymentType?: string;
  paymentStatus?: string;
  totalPrice?: number;
  discount?: number;
  totalPay?: number;
  pointsDiscount?: number;
  appliedPoints?: number;
  isPointsApplied?: boolean;
  isCarFreshened?: boolean;
  description?: string;
  type?: string;
  OnTheWayAt?: string;
  onWashingAt?: string;
  carBeforeWashLink?: string;
  carAfterWashLink?: string;
  ratingOfBiker?: number;
  cancellationReason?: string;
  createdAt?: string;
};

/** The three lists the app's Bookings tabs ask for (orders.repository.ts findAllUserOrders). */
export type OrderGroup = 'ACTIVE' | 'SCHEDULED' | 'HISTORY';

export function localized(text: LocalizedText | undefined, locale: string): string {
  if (!text) return '';
  return (locale === 'ar' ? text.ar : text.en) ?? text.en ?? text.ar ?? '';
}

/** An id from a field the backend sends either as an id or as a populated object. */
export function idOf(value: { _id: string } | string | undefined): string {
  if (!value) return '';
  return typeof value === 'string' ? value : value._id;
}

/** One free time from GET /user/biker-schedules (Saudi wall-clock "HH:mm"). */
export type Slot = { timeSlot: string; day?: string; availableBikersCount?: number; isAvailable: boolean };

export function cityName(city: Location['city'], locale: string): string {
  if (!city || typeof city === 'string') return '';
  return localized(city.name, locale);
}
