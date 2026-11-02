import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { LocalizedText } from '../../common/types/localized-text.type';

export type TermsModel = Terms & Document;
export const termsModelName = 'Terms';

@Schema({ timestamps: true })
export class Terms {
  @Prop({ type: LocalizedText })
  content: LocalizedText;
}

export const TermsSchema = SchemaFactory.createForClass(Terms);
