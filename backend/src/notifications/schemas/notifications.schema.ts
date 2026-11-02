import { Prop, raw, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose, { Document } from 'mongoose';
import { userModelName } from '../../user/schemas/user.schema';
import { ordersModelName } from '../../orders/schemas/orders.schema';
import { bikerModelName } from 'src/bikers/schemas/bikers.schema';
import { adminModelName } from 'src/admin/schemas/admin.schema';

export type NotificationsModel = Notification & Document;
export const notificationsModelName = 'notifications';

@Schema({ timestamps: true })
export class Notification {
  @Prop({ type: mongoose.Schema.Types.ObjectId, refPath: 'receiverModel' })
  receiver: mongoose.Types.ObjectId;

  @Prop({
    type: String,
    enum: [userModelName, bikerModelName, adminModelName],
  })
  receiverModel: string;

  @Prop({ type: mongoose.Schema.Types.ObjectId, refPath: 'clickableItemModel' })
  clickableItem: mongoose.Types.ObjectId;

  @Prop({
    type: String,
    enum: [ordersModelName],
  })
  clickableItemModel: string;

  @Prop(
    raw({
      arTitle: { type: String },
      arBody: { type: String },
      enTitle: { type: String },
      enBody: { type: String },
    }),
  )
  message: Record<string, any>;

  @Prop({ default: false })
  isRead: boolean;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;

  @Prop()
  type: string;
}

export const NotificationsSchema = SchemaFactory.createForClass(Notification);
