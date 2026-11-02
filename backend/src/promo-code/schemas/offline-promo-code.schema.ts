import { Schema, SchemaFactory } from '@nestjs/mongoose';

export type OfflinePromoCodeModel = OfflinePromoCode & Document;

export const offlinePromoCodeModelName = 'offline-promo-code';

@Schema()
export class OfflinePromoCode {}

export const OfflinePromoCodeSchema =
  SchemaFactory.createForClass(OfflinePromoCode);
