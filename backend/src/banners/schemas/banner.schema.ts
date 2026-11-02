import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

export type BannerModel = Banner & Document;
export const bannerModelName = 'banner';

export enum Resources {
  PROMO_CODE = 'PROMO_CODE',
  PLAN = 'PLAN',
}

@Schema()
export class Banner {
  @Prop()
  title: string;

  @Prop()
  description: string;

  @Prop()
  imageLink: string;

  @Prop()
  imagePath: string;

  @Prop()
  imagePathAr: string;

  @Prop()
  imageLinkAr: string;

  @Prop({ default: false })
  isActive?: boolean;

  @Prop({ required: false })
  externalUrl: string;

  @Prop({
    type: String,
    enum: Resources,
  })
  resource: Resources;

  @Prop({ required: false })
  resourceId: string;
}

export const BannerSchema = SchemaFactory.createForClass(Banner);
