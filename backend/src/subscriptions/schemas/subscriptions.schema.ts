import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { User, userModelName } from '../../user/schemas/user.schema';
import { Plan, plansModelName } from '../../plans/schemas/plans.schema';

export type SubscriptionsModel = Subscription & Document;
export const subscriptionsModelName = 'subscription';
export enum SubscriptionsStatus {
  ACTIVE = 'ACTIVE',
  PENDING = 'PENDING',
  EXPIRED = 'EXPIRED',
  CANCELLED = 'CANCELLED',
  PAYMENT_FAILED = 'PAYMENT_FAILED',
}

export enum SubscriptionPaymentTypes {
  WALLET = 'WALLET',
  CREDIT = 'CREDIT',
  APPLE_PAY = 'APPLE_PAY',
  TAMARA = 'TAMARA',
  TABBY = 'TABBY',
}

@Schema({ timestamps: true })
export class Subscription {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: userModelName })
  user: User;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: plansModelName })
  plan: Plan;

  @Prop()
  remainingWashes: number;

  @Prop()
  washesCount: number;

  @Prop()
  expiryDate: Date;

  @Prop({ default: SubscriptionsStatus.PENDING })
  status: string;

  @Prop()
  paymentType: string;

  @Prop()
  paymentStatus: string;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const SubscriptionsSchema = SchemaFactory.createForClass(Subscription);
