import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type PendingUserModel = PendingUser & Document;
export const pendingUserModelName = 'pending-user';
@Schema({ timestamps: true })
export class PendingUser {
  @Prop()
  userName: string;

  @Prop()
  phone: string;

  @Prop()
  email: string;

  @Prop({ type: [{ type: String }], select: false })
  fcmTokens: string[];

  @Prop({ required: false })
  otp: string;

  @Prop({ required: false })
  otpExpiresAt: Date;

  @Prop({ default: 0 })
  otpAttempts: number;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const PendingUserSchema = SchemaFactory.createForClass(PendingUser);

// Add index for phone field
PendingUserSchema.index({ phone: 1 });
