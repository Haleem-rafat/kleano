import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { User, userModelName } from '../../user/schemas/user.schema';
import { PromoCode, promoCodeModelName } from './promo-code.schema';

export type AppliedPromoCodeModel = AppliedPromoCode & Document;
export const appliedPromoCodeModelName = 'applied-promo-code';

@Schema({ timestamps: true })
export class AppliedPromoCode {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: userModelName })
  user: User;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: promoCodeModelName })
  promoCode: PromoCode;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const AppliedPromoCodeSchema =
  SchemaFactory.createForClass(AppliedPromoCode);
