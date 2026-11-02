import { Prop, raw, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
export type PointsModel = Point & Document;

@Schema({ timestamps: true })
export class Point {
  @Prop({ default: 0 })
  totalPayPercentage: number;

  @Prop({ default: 0 })
  exchangePercentage: number;

  @Prop({ default: 0 })
  redeemLimit: number;

  @Prop()
  createAt: Date;
}

export const PointsSchema = SchemaFactory.createForClass(Point);
