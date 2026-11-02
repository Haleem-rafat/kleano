import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';
import { Admin, adminModelName } from 'src/admin/schemas/admin.schema';
import { AddOns, addOnsModelName } from '../../add-ons/schemas/add-ons.schema';
import { Biker, bikerModelName } from '../../bikers/schemas/bikers.schema';
import {
  Location,
  locationModelName,
} from '../../locations/schemas/location.schema';
import {
  PromoCode,
  promoCodeModelName,
} from '../../promo-code/schemas/promo-code.schema';
import {
  Subscription,
  subscriptionsModelName,
} from '../../subscriptions/schemas/subscriptions.schema';
import { User, userModelName } from '../../user/schemas/user.schema';
import {
  Vehicle,
  vehicleModelName,
} from '../../vehicles/schemas/vehicles.schema';
import {
  WashingService,
  WashingServicesModelName,
} from '../../washing-services/schemas/washing-services.schema';

export type OrdersModel = Order & Document;
export const ordersModelName = 'order';

export enum OrderStatus {
  PENDING_USER_PAYMENT = 'PENDING_USER_PAYMENT',
  PENDING_USER_REVIEW = 'PENDING_USER_REVIEW',
  ACTIVE = 'ACTIVE',
  CANCELLED_BY_USER = 'CANCELLED_BY_USER',
  CANCELLED_BY_ADMIN = 'CANCELLED_BY_ADMIN',
  ACCEPTED_BY_BIKER = 'ACCEPTED_BY_BIKER',
  WAITING_FOR_BIKER_BY_ADMIN = 'WAITING_FOR_BIKER_BY_ADMIN',
  BIKER_ON_THE_WAY = 'BIKER_ON_THE_WAY',
  CANCELLED_BY_BIKER = 'CANCELLED_BY_BIKER',
  BIKER_ARRIVED = 'BIKER_ARRIVED',
  ON_WASHING = 'ON_WASHING',
  COMPLETED = 'COMPLETED',
  SCHEDULED = 'SCHEDULED',
  PAYMENT_FAILED = 'PAYMENT_FAILED',
}

/** Same list as biker auto-assignment: biker is not free for this (date, timeSlot). */
export const BIKER_TIMESLOT_OCCUPIED_ORDER_STATUSES: ReadonlyArray<OrderStatus> =
  [
    OrderStatus.PENDING_USER_PAYMENT,
    OrderStatus.ACTIVE,
    OrderStatus.WAITING_FOR_BIKER_BY_ADMIN,
    OrderStatus.ACCEPTED_BY_BIKER,
    OrderStatus.BIKER_ON_THE_WAY,
    OrderStatus.BIKER_ARRIVED,
    OrderStatus.ON_WASHING,
  ];

export enum OrderTypes {
  SUBSCRIPTION_BOOKING = 'SUBSCRIPTION_BOOKING',
  SERVICE_BOOKING = 'SERVICE_BOOKING',
}

export enum PaymentTypes {
  WALLET = 'WALLET',
  CREDIT = 'CREDIT',
  SUBSCRIBED = 'SUBSCRIBED',
  APPLE_PAY = 'APPLE_PAY',
  FREE = 'FREE',
  TAMARA = 'TAMARA',
  TABBY = 'TABBY',
}

export enum UserOS {
  ANDROID = 'ANDROID',
  IOS = 'IOS',
}

/*
    TODO:-(PromoCode) as a foriegn-key
  */

@Schema({ timestamps: true })
export class Order {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: userModelName })
  user: User;

  @Prop({
    type: [
      { type: mongoose.Schema.Types.ObjectId, ref: WashingServicesModelName },
    ],
  })
  washingServices: WashingService[];

  @Prop({
    type: [{ type: mongoose.Schema.Types.ObjectId, ref: addOnsModelName }],
  })
  addOns: AddOns[];

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: vehicleModelName })
  vehicle: Vehicle;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: locationModelName })
  location: Location;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: bikerModelName })
  biker: Biker; // Setted when biker Accept Order

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: subscriptionsModelName })
  subscription: Subscription;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: promoCodeModelName })
  promoCode: PromoCode;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: adminModelName })
  assignedBy: Admin;

  @Prop({ default: false })
  isAssigned: boolean;

  @Prop()
  timeSlot: string;

  @Prop()
  bookingDate: Date;

  @Prop()
  startTime: Date;

  @Prop()
  cancellationDate: Date;

  @Prop()
  endTime: Date; // Setted From Biker when Update Order status TO "COMPLETED"

  @Prop()
  totalDuration: number; // Setted From WashingServices Durations while placing order

  @Prop({})
  status: string;

  @Prop({})
  cancellationReason: string;

  @Prop()
  description: string;

  @Prop()
  type: string;

  @Prop()
  paymentType: string;

  @Prop()
  paymentStatus: string;

  @Prop({ default: 0 })
  totalPrice: number;

  @Prop({ default: 0 })
  discount: number;

  @Prop({ default: 0 })
  totalPay: number;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;

  @Prop()
  OnTheWayAt: Date;

  @Prop()
  onWashingAt: Date;

  @Prop()
  carBeforeWashPath: string;

  @Prop()
  carBeforeWashLink: string;

  @Prop()
  carAfterWashPath: string;

  @Prop()
  carAfterWashLink: string;

  @Prop()
  ratingOfBiker: number;

  @Prop()
  ratingOfUser: number;

  @Prop({ default: false })
  isPointsApplied: boolean;

  @Prop({ default: false })
  isAdminEmailSent: boolean;

  @Prop({ default: 0 }) // 🔹 Added appliedPoints field
  appliedPoints: number;

  @Prop({ default: 0 }) // 🔹 Added discountAmount field
  pointsDiscount: number;

  @Prop({ default: 0 }) // 🔹 Added refundAmount field
  refundAmount: number;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: adminModelName })
  cancelledByAdmin: Admin;

  @Prop({ default: false })
  isCarFreshened: boolean;

  @Prop()
  userOS: UserOS;

  @Prop({ default: 0 })
  bikerCommission: number;

  @Prop({ default: false })
  isWeekendForBiker: boolean;

  @Prop({ required: false })
  qoyodInvoiceId: number;
}

export const OrdersSchema = SchemaFactory.createForClass(Order);

// Indexes for performance optimization
OrdersSchema.index({ status: 1, timeSlot: 1, bookingDate: 1 });
OrdersSchema.index({ biker: 1 });
OrdersSchema.index({ location: 1 });
