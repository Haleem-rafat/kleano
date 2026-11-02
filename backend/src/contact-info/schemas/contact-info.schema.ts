import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

export type ContactInfoModel = ContactInfo & Document;
export const contactInfoModelName = 'contact-info';

@Schema()
export class ContactInfo {
  @Prop()
  contactTitle?: string;

  @Prop()
  emails: string[];

  @Prop()
  phoneNumbers: string[];

  @Prop()
  whatsAppNumber?: string;

  @Prop()
  facebookLink?: string;

  @Prop()
  instagramLink?: string;

  @Prop()
  twitterLink?: string;

  @Prop()
  youtubeLink?: string;

  @Prop()
  linkedinLink?: string;

  @Prop()
  tiktokLink?: string;

  @Prop()
  website?: string;
}

export const ContactInfoSchema = SchemaFactory.createForClass(ContactInfo);
