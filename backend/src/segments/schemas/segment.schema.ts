import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { User, userModelName } from 'src/user/schemas/user.schema';

export type SegmentModel = Segment & Document;

export const segmentModelName = 'segment';

@Schema({ timestamps: true })
export class Segment {
  @Prop({ type: String, trim: true, required: true })
  name: string;

  @Prop({
    type: [
      {
        type: mongoose.Schema.Types.ObjectId,
        required: false,
        ref: userModelName,
      },
    ],
  })
  users: User[];
}

export const SegmentSchema = SchemaFactory.createForClass(Segment);
