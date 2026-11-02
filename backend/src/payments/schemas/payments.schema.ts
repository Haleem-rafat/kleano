import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { Subscription } from 'src/subscriptions/schemas/subscriptions.schema';
import { User } from 'src/user/schemas/user.schema';
import {
  Order,
  OrderTypes,
  PaymentTypes,
} from '../../orders/schemas/orders.schema';

export type PaymentsModel = Payment & Document;
export const paymentsModelName = 'payment';

export enum MoyasarSupportedCurrency {
  SAR = 'SAR',
}

export enum MoyasarPaymentStatus {
  UNPAID = 'UNPAID',
  PAID = 'PAID',
  FAILED = 'FAILED',
  REFUNDED = 'REFUNDED',
  REFUND_FAILED = 'REFUND_FAILED',
}

@Schema({ timestamps: true })
export class Payment {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: false })
  order?: Order;

  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Subscription',
    required: false,
  })
  subscription?: Subscription;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: 'User', required: false })
  walletPaymentUser?: User;

  @Prop({ type: String, enum: OrderTypes, required: false })
  orderType?: OrderTypes;

  @Prop({ type: Number, required: true, default: 0 })
  totalAmount: number;

  @Prop({ type: String, required: false, default: null })
  transactionId?: string;

  @Prop({
    type: String,
    enum: MoyasarSupportedCurrency,
    default: MoyasarSupportedCurrency.SAR,
  })
  currency: MoyasarSupportedCurrency;

  @Prop({
    type: String,
    enum: MoyasarPaymentStatus,
    default: MoyasarPaymentStatus.UNPAID,
  })
  paymentStatus: MoyasarPaymentStatus;

  @Prop({ type: String, enum: PaymentTypes, required: false })
  paymentType: PaymentTypes;
}
export const PaymentsSchema = SchemaFactory.createForClass(Payment);
