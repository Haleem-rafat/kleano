import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

export type B2bPromoCodeModel = B2bPromoCode & Document;

export const b2bPromoCodeModelName = 'b2b-promo-code';

@Schema()
export class B2bPromoCode {
  @Prop({
    type: String,
    required: true,
  })
  business: string;
}

export const B2bPromoCodeSchema = SchemaFactory.createForClass(B2bPromoCode);
