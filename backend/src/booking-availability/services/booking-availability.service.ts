import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import {
  BookingAvailability,
  BookingAvailabilityModel,
} from '../schemas/booking-availability.schema';
import { Model } from 'mongoose';
import { CreateBookingAvailabilityDto } from '../dtos/create-booking-availability.dto';
import { UpdateBookingAvailabilityTimeSlotDto } from '../dtos/update-time-slot.dto';
import { GetBookingsAvailDto } from '../dtos/get-bookings.dto';
import { MethodNotAllowedResponse } from 'src/common/errors';

@Injectable()
export class BookingAvailabilityService {
  constructor(
    @InjectModel(BookingAvailability.name)
    private readonly bookingAvailabilityModel: Model<BookingAvailabilityModel>,
  ) {}

  async createBookingAvailability({
    bookingAvailabilityDates,
  }: CreateBookingAvailabilityDto) {
    for (let i = 0; i < bookingAvailabilityDates.length; i++) {
      const { date, isActive, timeSlots } = bookingAvailabilityDates[i];

      const [dateExistence] = await this.bookingAvailabilityModel.aggregate([
        {
          $project: {
            availableDate: {
              $dateToString: { format: '%Y-%m-%d', date: '$date' },
            },
          },
        },
        {
          $match: {
            availableDate: new Date(date).toISOString().slice(0, 10),
          },
        },
      ]);
      if (dateExistence)
        throw new MethodNotAllowedResponse({
          ar: 'تاريخ الحجز المحدد موجود بالفعل',
          en: 'Selected booking date already exists',
        });

      const availableDateInString = date.slice(0, 10);
      const availableDate = new Date(availableDateInString);

      availableDate.setHours(0, 0, 0, 0);

      const bookingAvailability = new this.bookingAvailabilityModel();
      bookingAvailability.set({ date: availableDate, isActive, timeSlots });

      await bookingAvailability.save();
    }
  }

  async getAdminBookingAvailabilities({ from, to }: GetBookingsAvailDto) {
    return await this.bookingAvailabilityModel
      .find({
        date: {
          $lte: new Date(to),
          $gte: new Date(from),
        },
      })
      .lean();
  }

  async getUserBookingAvailabilities() {
    const currentDate = new Date();
    currentDate.setHours(0, 0, 0, 0);
    return await this.bookingAvailabilityModel
      .find({
        date: {
          $gte: currentDate,
        },
      })
      .lean();
  }

  async updateBookingAvailabilityTimeSlot({
    date,
    isActive,
    timeSlots,
  }: UpdateBookingAvailabilityTimeSlotDto) {
    await this.bookingAvailabilityModel.updateOne(
      {
        date,
      },
      {
        $set: { isActive, timeSlots },
      },
    );
  }
}
