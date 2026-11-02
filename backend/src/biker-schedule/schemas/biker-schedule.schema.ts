import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import mongoose from 'mongoose';
import { Area, areaModelName } from 'src/area/schemas/area.schema';
import { Biker, bikerModelName } from 'src/bikers/schemas/bikers.schema';
import { City, cityModelName } from 'src/city/schemas/city.schema';

export type BikerScheduleModel = BikerSchedule & Document;
export const bikerScheduleModelName = 'biker-schedule';

export enum Day {
  SATURDAY = 'SATURDAY',
  SUNDAY = 'SUNDAY',
  MONDAY = 'MONDAY',
  TUESDAY = 'TUESDAY',
  WEDNESDAY = 'WEDNESDAY',
  THURSDAY = 'THURSDAY',
  FRIDAY = 'FRIDAY',
}

@Schema()
export class Shift {
  @Prop({})
  timeSlot: string;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: cityModelName })
  city: City;

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: areaModelName })
  area: Area;

  @Prop({ enum: Day, required: true })
  day: Day;

  @Prop({ default: 1, min: 1, max: 3 })
  priorityLevel: number;
}
const ShiftSchema = SchemaFactory.createForClass(Shift);

@Schema({ timestamps: true })
export class BikerSchedule {
  @Prop({ type: [ShiftSchema], required: true, default: [], _id: false })
  shifts: Shift[];

  @Prop({
    type: [{ type: String, enum: Day }],
    required: false,
    default: [],
  })
  weekends: string[];

  @Prop({ type: mongoose.Schema.Types.ObjectId, ref: bikerModelName })
  biker: Biker;
}

export const BikerScheduleSchema = SchemaFactory.createForClass(BikerSchedule);

// Indexes for performance optimization
BikerScheduleSchema.index({ biker: 1 });
BikerScheduleSchema.index({
  'shifts.city': 1,
  'shifts.area': 1,
  'shifts.day': 1,
});
BikerScheduleSchema.index({ 'shifts.timeSlot': 1 });
BikerScheduleSchema.index({ biker: 1, 'shifts.day': 1 });
