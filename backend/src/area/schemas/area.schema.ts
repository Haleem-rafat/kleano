import { Prop, raw, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';
import { City, cityModelName } from 'src/city/schemas/city.schema';

export type AreaModel = Area & Document;
export const areaModelName = 'area';

@Schema({ timestamps: true })
export class Area {
  @Prop(
    raw({
      ar: { type: String, required: true },
      en: { type: String, required: true },
    }),
  )
  name: { ar: string; en: string };

  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: cityModelName,
    required: true,
  })
  city: City;

  @Prop(
    raw({
      type: {
        type: String,
        enum: ['Polygon'],
        default: 'Polygon',
        required: true,
      },
      coordinates: {
        type: [[[Number]]], // array of array of [lon,lat]
        required: true,
      },
    }),
  )
  boundary: {
    type: 'Polygon';
    coordinates: number[][][];
  };

  @Prop()
  latitude?: number;

  @Prop()
  longitude?: number;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const AreaSchema = SchemaFactory.createForClass(Area);

AreaSchema.index({ boundary: '2dsphere' });
