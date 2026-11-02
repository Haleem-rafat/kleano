import {
  Body,
  Controller,
  Get,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { BookingAvailabilityService } from '../services/booking-availability.service';
import { UserAuthGuard } from 'src/auth/guards';
import { IsAdminGuard } from 'src/admin/guard';
import { CreateBookingAvailabilityDto } from '../dtos/create-booking-availability.dto';
import { Account } from 'src/common/decorators/user.decorator';
import { UpdateBookingAvailabilityTimeSlotDto } from '../dtos/update-time-slot.dto';
import { GetBookingsAvailDto } from '../dtos/get-bookings.dto';
import { query } from 'express';

@Controller('booking-availabilities')
export class BookingAvailabilityController {
  constructor(private bookingAvailabilityService: BookingAvailabilityService) {}

  @Post('admin')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createBookingAvailabilityController(
    @Body() body: CreateBookingAvailabilityDto,
    @Account() account: any,
  ) {
    await this.bookingAvailabilityService.createBookingAvailability(body);

    return {
      success: true,
    };
  }

  @Get('admin')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getBookingAvailabilitiesController(
    @Account() account: any,
    @Query() query: GetBookingsAvailDto,
  ) {
    return {
      success: true,
      data: await this.bookingAvailabilityService.getAdminBookingAvailabilities(
        query,
      ),
    };
  }

  @Patch('admin')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async updateBookingAvailabilityController(
    @Body() body: UpdateBookingAvailabilityTimeSlotDto,
    @Account() account: any,
  ) {
    await this.bookingAvailabilityService.updateBookingAvailabilityTimeSlot(
      body,
    );

    return {
      success: true,
    };
  }

  @Get('user')
  @UseGuards(UserAuthGuard)
  async getBookingAvailabilitiesUserController(@Account() account: any) {
    return {
      success: true,
      data: await this.bookingAvailabilityService.getUserBookingAvailabilities(),
    };
  }
}
