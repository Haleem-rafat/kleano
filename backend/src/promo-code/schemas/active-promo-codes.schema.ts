import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { User, userModelName } from '../../user/schemas/user.schema';
import { PromoCode, promoCodeModelName } from './promo-code.schema';

export type ActivePromoCodesModel = ActivePromoCodes & Document;
export const activePromoCodesModelName = 'active-promo-codes';

@Schema({ timestamps: true })
export class ActivePromoCodes {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: userModelName })
  user: User;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: promoCodeModelName })
  promoCode: PromoCode;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const ActivePromoCodesSchema =
  SchemaFactory.createForClass(ActivePromoCodes);
