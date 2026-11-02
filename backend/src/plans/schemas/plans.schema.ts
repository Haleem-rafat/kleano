import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { LocalizedText } from '../../common/types/localized-text.type';
import {
  ServiceIcon,
  servicesIconModelName,
} from '../../services-icons/schemas/services-icons.schema';
import {
  WashingService,
  WashingServicesModelName,
} from '../../washing-services/schemas/washing-services.schema';

export type PlansModel = Plan & Document;
export const plansModelName = 'plan';

@Schema({ timestamps: true })
export class Plan {
  @Prop({ type: LocalizedText })
  type: LocalizedText;

  @Prop()
  color: string;

  @Prop({ default: 0 })
  price: number;

  @Prop()
  duration: number;

  @Prop()
  durationUnit: string;

  @Prop({ default: 0 })
  usageCount: number;

  @Prop([
    { type: mongoose.Schema.Types.ObjectId, ref: WashingServicesModelName },
  ])
  washingServices: WashingService[];

  @Prop([{ type: LocalizedText }])
  description: LocalizedText[];

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: servicesIconModelName })
  icon: ServiceIcon;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;

  @Prop({ required: false })
  qoyodProductId: number | null;
}

export const PlansSchema = SchemaFactory.createForClass(Plan);
