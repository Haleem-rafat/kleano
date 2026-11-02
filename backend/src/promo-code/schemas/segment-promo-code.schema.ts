import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { Segment, segmentModelName } from 'src/segments/schemas/segment.schema';

export type SegmentPromoCodeModel = SegmentPromoCode & Document;

export const segmentPromoCodeModelName = 'segment-promo-code';
@Schema()
export class SegmentPromoCode {
  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: segmentModelName,
  })
  segment: Segment;
}

export const SegmentPromoCodeSchema =
  SchemaFactory.createForClass(SegmentPromoCode);
