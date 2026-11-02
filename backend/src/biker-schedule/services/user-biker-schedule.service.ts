import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { BikerStatus } from 'src/bikers/schemas/bikers.schema';
import {
  BIKER_TIMESLOT_OCCUPIED_ORDER_STATUSES,
  OrdersModel,
  ordersModelName,
} from 'src/orders/schemas/orders.schema';
import { QueryBikerScheduleDto } from '../dtos/query-biker-schedule.dto';
import { getAssignmentDayFromDateAndTimeSlot } from '../utils/saudi-assignment-day.util';
import {
  BikerScheduleModel,
  bikerScheduleModelName,
} from '../schemas/biker-schedule.schema';

@Injectable()
export class UserBikerScheduleService {
  constructor(
    @InjectModel(bikerScheduleModelName)
    private readonly bikerScheduleModel: Model<BikerScheduleModel>,
    @InjectModel(ordersModelName)
    private readonly ordersModel: Model<OrdersModel>,
  ) {}

  async findAll(query: QueryBikerScheduleDto) {
    // Build filters
    const scheduleFilter: any = {};
    if (query.biker) {
      scheduleFilter.biker = new Types.ObjectId(query.biker);
    }

    const shiftMatch: any = {};
    if (query.city) {
      shiftMatch['shifts.city'] = new Types.ObjectId(query.city);
    }
    if (query.area) {
      shiftMatch['shifts.area'] = new Types.ObjectId(query.area);
    }
    if (query.day) {
      shiftMatch['shifts.day'] = query.day;
    }

    // Get all shifts with their bikers
    const schedulePipeline: any[] = [
      { $match: scheduleFilter },
      {
        $lookup: {
          from: 'bikers',
          localField: 'biker',
          foreignField: '_id',
          as: 'bikerDetails',
          pipeline: [
            {
              $match: {
                isDeleted: false,
                status: { $ne: BikerStatus.SUSPENDED },
              },
            },
            { $project: { _id: 1 } },
          ],
        },
      },
      { $match: { bikerDetails: { $ne: [] } } },
      { $unwind: '$shifts' },
    ];

    if (Object.keys(shiftMatch).length > 0) {
      schedulePipeline.push({ $match: shiftMatch });
    }

    // Group by shift to get bikers per shift
    schedulePipeline.push(
      {
        $group: {
          _id: {
            timeSlot: '$shifts.timeSlot',
            city: '$shifts.city',
            area: '$shifts.area',
            day: '$shifts.day',
          },
          bikerIds: { $addToSet: '$biker' },
        },
      },
      {
        $addFields: {
          totalBikers: { $size: '$bikerIds' },
        },
      },
    );

    const scheduleResults = await this.bikerScheduleModel.aggregate(
      schedulePipeline,
    );

    // Calculate available bikers for each shift
    const results = [];
    const dateYmd = query.date
      ? new Date(query.date).toISOString().slice(0, 10)
      : null;

    for (const shift of scheduleResults) {
      const { timeSlot, city, area, day } = shift._id;
      if (dateYmd) {
        const expectedDay = getAssignmentDayFromDateAndTimeSlot(
          dateYmd,
          timeSlot,
        );
        if (day !== expectedDay) {
          continue;
        }
      }
      const bikerIds: Types.ObjectId[] = shift.bikerIds;
      const totalBikers = shift.totalBikers;

      let availableBikersCount = totalBikers;

      // If date is provided, check which bikers are busy
      if (dateYmd) {
        // Count bikers who have orders at this timeSlot and date (regardless of area)
        for (const bikerId of bikerIds) {
          const busyOrder = await this.ordersModel.aggregate([
            {
              $match: {
                biker: bikerId,
                timeSlot: timeSlot,
                status: { $in: BIKER_TIMESLOT_OCCUPIED_ORDER_STATUSES },
              },
            },
            {
              $addFields: {
                bookingDateStr: {
                  $dateToString: { format: '%Y-%m-%d', date: '$bookingDate' },
                },
              },
            },
            {
              $match: {
                bookingDateStr: dateYmd,
              },
            },
            { $limit: 1 },
          ]);

          if (busyOrder.length > 0) {
            availableBikersCount--;
          }
        }
      }

      results.push({
        timeSlot,
        city,
        area,
        day,
        availableBikersCount: Math.max(availableBikersCount, 0),
        isAvailable: availableBikersCount > 0,
      });
    }

    // Sort by day and timeSlot
    results.sort((a, b) => {
      if (a.day !== b.day) {
        return a.day.localeCompare(b.day);
      }
      return a.timeSlot.localeCompare(b.timeSlot);
    });

    return results;
  }
}
