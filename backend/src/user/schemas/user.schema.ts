import { Prop, raw, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';
import { cityModelName } from '../../city/schemas/city.schema';

export type UserModel = User & Document;
export const userModelName = 'user';
@Schema({ timestamps: true })
export class User {
  @Prop()
  userName: string;

  @Prop()
  phone: string;

  @Prop()
  email: string;

  @Prop()
  gender: string;

  @Prop()
  imagePath: string;

  @Prop()
  imageLink: string;

  @Prop()
  socketId: string;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;

  @Prop({ type: [{ type: String }], select: false })
  fcmTokens: string[];

  @Prop({ default: false })
  isSuspended: boolean;

  @Prop({ default: false })
  isDeleted: boolean;

  @Prop({ default: 0 })
  points: number;

  @Prop({ default: 0 })
  walletBalance: number;

  @Prop(
    raw({
      latitude: { type: Number, default: 0 },
      longitude: { type: Number, default: 0 },
      streetName: { type: String, default: '' },
      subAdministrativeArea: { type: String, default: '' },
      city: { type: mongoose.Schema.Types.ObjectId, ref: cityModelName },
      country: { type: String, default: '' },
    }),
  )
  location: Record<string, any>;

  @Prop({ default: 'en', trim: true, lowercase: true })
  language: string;

  @Prop({ default: true })
  isAllowNotification: boolean;

  @Prop({ default: 0 })
  rating: number;

  @Prop({ unique: true, sparse: true })
  serialNumber: number;

  @Prop({ required: false })
  dob: string;

  @Prop({ required: false })
  qoyodCustomerId: number | null;

  @Prop({ required: false })
  otp: string;

  @Prop({ required: false })
  otpExpiresAt: Date;

  @Prop({ default: 0 })
  otpAttempts: number;
}

export const UserSchema = SchemaFactory.createForClass(User);

// Add index for serialNumber field
UserSchema.index({ serialNumber: 1 }, { unique: true, sparse: true });
