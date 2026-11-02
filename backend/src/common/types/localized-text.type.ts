import { Prop } from '@nestjs/mongoose';

export class LocalizedText {
  @Prop({ required: true })
  ar: string;
  @Prop({ required: true })
  en: string;
}
