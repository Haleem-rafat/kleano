import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type ServicesIconsModel = ServiceIcon & Document;
export const servicesIconModelName = 'services-icon';

@Schema()
export class ServiceIcon {
  @Prop()
  iconPath: string;

  @Prop()
  iconLink: string;
}

export const ServicesIconsSchema = SchemaFactory.createForClass(ServiceIcon);
