import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';
import { City, cityModelName } from '../../city/schemas/city.schema';

export type AdminModel = Admin & Document;
export const adminModelName = 'admin';
export enum Roles {
  SuperAdmin = 'superAdmin',
  SubAdmin = 'subAdmin',
  User = 'user',
  Guest = 'guest',
  Biker = 'biker',
}
export enum AdminStatus {
  ACTIVE = 'ACTIVE',
  SUSPENDED = 'SUSPENDED',
}
@Schema({ timestamps: true })
export class Admin {
  @Prop()
  userName: string;

  @Prop()
  phone: string;

  @Prop({ select: false })
  password: string;

  @Prop({ default: false })
  isSuperAdmin: boolean;

  @Prop({ default: AdminStatus.ACTIVE })
  status: string;

  @Prop({ default: false })
  isDeleted: boolean;

  @Prop({ default: '' })
  suspendReason: string;

  @Prop()
  nationalId: string;

  @Prop({
    type: [{ type: mongoose.Schema.Types.ObjectId, ref: cityModelName }],
  })
  city: City[];

  @Prop({ default: 'ar' })
  lang: string;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const AdminSchema = SchemaFactory.createForClass(Admin);
