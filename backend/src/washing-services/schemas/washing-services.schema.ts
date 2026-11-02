import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { LocalizedText } from '../../common/types/localized-text.type';
import {
  ServiceIcon,
  servicesIconModelName,
} from '../../services-icons/schemas/services-icons.schema';

export type WashingServicesModel = WashingService & Document;
export const WashingServicesModelName = 'washing-service';

export enum ServiceType {
  MAIN = 'main',
  EXTRA = 'extra',
}

@Schema({ timestamps: true })
export class WashingService {
  @Prop({ type: LocalizedText })
  name: LocalizedText;

  @Prop([{ type: LocalizedText }])
  description: LocalizedText[];

  @Prop()
  duration: number;

  @Prop()
  durationUnit: string;

  @Prop({ default: 0 })
  price: number;

  @Prop({
    type: String,
    required: true,
    enum: Object.values(ServiceType),
  })
  type: ServiceType;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: servicesIconModelName })
  icon: ServiceIcon;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;

  @Prop({ required: false })
  qoyodProductId: number | null;
}

export const WashingServicesSchema =
  SchemaFactory.createForClass(WashingService);
