import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { City, cityModelName } from '../../city/schemas/city.schema';
import { AddOns, addOnsModelName } from './add-ons.schema';

export type AddOnsCitiesModel = AddOnsCity & Document;
export const addOnsCitiesModelName = 'add-ons-cities';

@Schema({ timestamps: true })
export class AddOnsCity {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: addOnsModelName })
  addOns: AddOns;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: cityModelName })
  city: City;

  @Prop({ default: false })
  isArchived: boolean;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;

  @Prop({ type: Date, default: null })
  suspendedAt: Date;
}

export const AddOnsCitiesSchema = SchemaFactory.createForClass(AddOnsCity);
