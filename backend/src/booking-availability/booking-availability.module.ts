import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import {
  BookingAvailability,
  BookingAvailabilitySchema,
} from './schemas/booking-availability.schema';
import { BookingAvailabilityController } from './controllers/booking-availability.controller';
import { BookingAvailabilityService } from './services/booking-availability.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: BookingAvailability.name, schema: BookingAvailabilitySchema },
    ]),
  ],
  controllers: [BookingAvailabilityController],
  providers: [BookingAvailabilityService],
})
export class BookingAvailabilityModule {}
