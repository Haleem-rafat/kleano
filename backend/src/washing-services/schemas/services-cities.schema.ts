import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import {
  WashingService,
  WashingServicesModelName,
} from './washing-services.schema';
import { City, cityModelName } from '../../city/schemas/city.schema';

export type ServicesCitiesModel = ServiceCity & Document;
export const ServicesCitiesModelName = 'services-city';

@Schema({ timestamps: true })
export class ServiceCity {
  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: WashingServicesModelName })
  washingService: WashingService;

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

export const ServicesCitiesSchema = SchemaFactory.createForClass(ServiceCity);
