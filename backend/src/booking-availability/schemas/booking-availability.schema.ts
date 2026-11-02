import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type BookingAvailabilityModel = BookingAvailability & Document;
export const bookingAvailabilityModelName = 'booking-availability';

@Schema()
export class TimeSlot {
  @Prop({ required: false })
  availableTime: Date;

  @Prop({ default: true })
  isActive: boolean;
}

const TimeSlotSchema = SchemaFactory.createForClass(TimeSlot);

@Schema({ timestamps: true })
export class BookingAvailability {
  @Prop({ required: true, unique: true })
  date: Date;

  @Prop({ type: [TimeSlotSchema], required: true, default: [], _id: false })
  timeSlots: TimeSlot[];

  @Prop({ default: true })
  isActive: boolean;

  @Prop()
  createdAt: Date;

  @Prop()
  updatedAt: Date;
}

export const BookingAvailabilitySchema =
  SchemaFactory.createForClass(BookingAvailability);

// Create partial unique index for timeSlots.availableTime
// This allows multiple null values but enforces uniqueness for non-null values
BookingAvailabilitySchema.index(
  { 'timeSlots.availableTime': 1 },
  {
    unique: true,
    partialFilterExpression: { 'timeSlots.availableTime': { $exists: true } },
  },
);
