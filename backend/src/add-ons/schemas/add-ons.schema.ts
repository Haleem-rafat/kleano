import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { LocalizedText } from '../../common/types/localized-text.type';
import {
  ServiceIcon,
  servicesIconModelName,
} from '../../services-icons/schemas/services-icons.schema';

export type AddOnsModel = AddOns & Document;
export const addOnsModelName = 'add-ons';

@Schema({ timestamps: true })
export class AddOns {
  @Prop({ type: LocalizedText })
  name: LocalizedText;

  @Prop({ default: 0 })
  price: number;

  @Prop({ default: 0 })
  stock: number;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: servicesIconModelName })
  icon: ServiceIcon;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;

  @Prop({ required: false })
  qoyodProductId: number | null;
}

export const AddOnsSchema = SchemaFactory.createForClass(AddOns);
