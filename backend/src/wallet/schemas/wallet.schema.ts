import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';
import { Admin, adminModelName } from '../../admin/schemas/admin.schema';
import { User, userModelName } from '../../user/schemas/user.schema';

export type WalletModel = Wallet & Document;
export const walletModelName = 'wallet';

export enum WalletTransactionType {
  TOP_UP = 'TOP_UP',
  PAY = 'PAY',
}

export enum WalletPaymentMethod {
  CREDIT = 'CREDIT',
  APPLE_PAY = 'APPLE_PAY',
  TAMARA = 'TAMARA',
  ADMIN = 'ADMIN',
}

@Schema({ timestamps: true })
export class Wallet {
  @Prop({
    type: String,
    enum: Object.values(WalletTransactionType),
    required: true,
  })
  transactionType: WalletTransactionType;

  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: userModelName,
    required: true,
  })
  user: User;

  @Prop({
    type: String,
    enum: Object.values(WalletPaymentMethod),
    required: false,
  })
  paymentMethod?: WalletPaymentMethod;

  @Prop({ type: String, required: false, default: null })
  transactionId?: string;

  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: adminModelName,
    required: false,
  })
  paidByAdmin?: Admin;

  @Prop({ type: Number, required: true, default: 0 })
  amount: number;

  @Prop({ type: String, required: false, default: null })
  notes?: string;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const WalletSchema = SchemaFactory.createForClass(Wallet);
