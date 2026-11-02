import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';
import { User, userModelName } from '../../user/schemas/user.schema';

export type VehicleModel = Vehicle & Document;
export const vehicleModelName = 'vehicle';
@Schema({ timestamps: true })
export class Vehicle {
  @Prop()
  type: string;

  @Prop()
  brand: string;

  @Prop()
  model: string;

  @Prop()
  plateNumber: string;

  @Prop()
  color: string;

  @Prop()
  imageLink: string;

  @Prop()
  imagePath: string;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: userModelName })
  user: User;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const VehicleSchema = SchemaFactory.createForClass(Vehicle);
