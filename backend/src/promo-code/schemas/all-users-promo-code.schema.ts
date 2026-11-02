import { Schema, SchemaFactory } from '@nestjs/mongoose';

export type AllUsersPromoCodeModel = AllUsersPromoCode & Document;

export const allUsersPromoCodeModelName = 'all-users-promo-code';

@Schema()
export class AllUsersPromoCode {}

export const AllUsersPromoCodeSchema =
  SchemaFactory.createForClass(AllUsersPromoCode);
