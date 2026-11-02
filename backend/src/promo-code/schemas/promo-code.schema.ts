import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

export type PromoCodesModel = PromoCode & Document;

export const promoCodeModelName = 'promo-code';

export enum PromoCodeStatus {
  ACTIVE = 'ACTIVE',
  EXPIRED = 'EXPIRED',
  DISABLED = 'DISABLED',
}

export enum PromoCodeTargetAudienceEnum {
  ALL_USERS = 'allUsers',
  SEGMENT = 'segment',
  NEW_COMERS = 'newComers',
  AGGREGATOR = 'aggregator',
  OFFLINE = 'offline',
  B2B = 'b2b',
}

export enum PromoCodeUsesTypeEnum {
  PER_USER = 'PER_USER',
  PER_CODE = 'PER_CODE',
}

@Schema({ discriminatorKey: 'targetAudience', timestamps: true })
export class PromoCode {
  @Prop({ type: String, trim: true, required: true })
  code: string;

  @Prop({ required: false })
  expiryDate?: Date;

  @Prop({ min: 1, required: true })
  numberOfUses: number;

  @Prop({
    type: String,
    required: true,
    enum: Object.values(PromoCodeUsesTypeEnum),
  })
  usesType: PromoCodeUsesTypeEnum;

  @Prop({
    min: 0,
    required: false,
  })
  userLimit: number;

  @Prop({ max: 100, min: 0, required: false })
  discountPercentage: number;

  @Prop({ min: 0, required: false })
  discountFixedNumber: number;

  @Prop({ default: PromoCodeStatus.ACTIVE, required: true })
  status: string;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;

  @Prop({
    type: String,
    required: true,
    enum: Object.values(PromoCodeTargetAudienceEnum),
  })
  targetAudience: PromoCodeTargetAudienceEnum;
}

export const PromoCodeSchema = SchemaFactory.createForClass(PromoCode);
