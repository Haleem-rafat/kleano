import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { plansModelName, Plan } from './plans.schema';
import { cityModelName, City } from '../../city/schemas/city.schema';

export type PlansModel = PlanCity & Document;
export const plansCitiesModelName = 'plans-city';

@Schema({ timestamps: true })
export class PlanCity {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: plansModelName })
  plan: Plan;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: cityModelName })
  city: City;

  @Prop({ default: false })
  isArchived: boolean;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const PlansCitiesSchema = SchemaFactory.createForClass(PlanCity);
