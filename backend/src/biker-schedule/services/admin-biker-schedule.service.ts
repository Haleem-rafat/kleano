import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { AdminService } from 'src/admin/admin.service';
import { AreasService } from 'src/area/area.service';
import {
  OrderStatus,
  OrdersModel,
  ordersModelName,
} from 'src/orders/schemas/orders.schema';
import { CreateBikerScheduleDto } from '../dtos/create-biker-schedule.dto';
import { QueryBikerScheduleDto } from '../dtos/query-biker-schedule.dto';
import { UpdateBikerScheduleDto } from '../dtos/update-biker-schedule.dto';
import {
  BikerScheduleModel,
  bikerScheduleModelName,
} from '../schemas/biker-schedule.schema';

@Injectable()
export class AdminBikerScheduleService {
  constructor(
    @InjectModel(bikerScheduleModelName)
    private readonly bikerScheduleModel: Model<BikerScheduleModel>,
    @InjectModel(ordersModelName)
    private readonly ordersModel: Model<OrdersModel>,
    private adminService: AdminService,
    private areasService: AreasService,
  ) {}

  async create(
    adminId: string,
    createBikerScheduleDto: CreateBikerScheduleDto,
  ) {
    const scheduleExists = await this.bikerScheduleModel.findOne({
      biker: createBikerScheduleDto.biker,
    });

    if (scheduleExists) {
      throw new BadRequestException({
        ar: 'الجدول مسجل من قبل',
        en: 'Schedule already exists',
      });
    }

    // Validate each shift's city and area
    const uniqueCities = new Set<string>();
    const shiftsByCity = new Map<string, string[]>();

    for (const shift of createBikerScheduleDto.shifts) {
      // Collect unique cities
      uniqueCities.add(shift.city);

      // Group areas by city for validation
      if (!shiftsByCity.has(shift.city)) {
        shiftsByCity.set(shift.city, []);
      }
      const cityAreas = shiftsByCity.get(shift.city);
      if (cityAreas && !cityAreas.includes(shift.area)) {
        cityAreas.push(shift.area);
      }
    }

    // Check city permissions for all cities used
    for (const city of uniqueCities) {
      await this.adminService.CityPermissionForCreation(adminId, city as any);
    }

    // Validate areas for each city
    for (const [city, areas] of shiftsByCity.entries()) {
      await this.areasService.validateAreas(city as any, areas as any);
    }

    const bikerSchedule = await this.bikerScheduleModel.create(
      createBikerScheduleDto,
    );
    return bikerSchedule;
  }

  async findAll(query: QueryBikerScheduleDto) {
    const pipeline: any[] = [];

    // Match by biker if provided
    if (query.biker) {
      pipeline.push({
        $match: { biker: new Types.ObjectId(query.biker) },
      });
    }

    // Lookup biker details
    pipeline.push(
      {
        $lookup: {
          from: 'bikers',
          localField: 'biker',
          foreignField: '_id',
          as: 'bikerDetails',
          pipeline: [
            { $match: { isDeleted: false } },
            { $project: { _id: 1, userName: 1, phone: 1, nationalId: 1 } },
          ],
        },
      },
      {
        $match: { bikerDetails: { $ne: [] } },
      },
      {
        $unwind: '$bikerDetails',
      },
    );

    // Unwind shifts
    pipeline.push({ $unwind: '$shifts' });

    // Match shifts by city, area, day
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

    if (Object.keys(shiftMatch).length > 0) {
      pipeline.push({ $match: shiftMatch });
    }

    // Group by timeSlot and collect bikers with shift details
    pipeline.push({
      $group: {
        _id: '$shifts.timeSlot',
        bikers: {
          $addToSet: {
            biker: '$bikerDetails',
            city: '$shifts.city',
            area: '$shifts.area',
            day: '$shifts.day',
          },
        },
      },
    });

    // Project final structure
    pipeline.push({
      $project: {
        _id: 0,
        timeSlot: '$_id',
        bikers: 1,
      },
    });

    // Sort by timeSlot
    pipeline.push({ $sort: { timeSlot: 1 } });

    const results = await this.bikerScheduleModel.aggregate(pipeline);

    // If date is provided, check which bikers have orders
    if (query.date) {
      const dateStr = new Date(query.date).toISOString().slice(0, 10); // YYYY-MM-DD

      for (const result of results) {
        const timeSlot = result.timeSlot;

        // For each biker in this timeSlot, check if they have an order
        for (const bikerShift of result.bikers) {
          const bikerId = bikerShift.biker._id;
          const city = bikerShift.city;
          const area = bikerShift.area;

          // Query orders for this biker on this date/timeSlot/area/city
          const ordersPipeline: any[] = [
            {
              $match: {
                biker: bikerId,
                status: {
                  $in: [
                    OrderStatus.PENDING_USER_PAYMENT,
                    OrderStatus.ACTIVE,
                    OrderStatus.WAITING_FOR_BIKER_BY_ADMIN,
                    OrderStatus.ACCEPTED_BY_BIKER,
                    OrderStatus.BIKER_ON_THE_WAY,
                    OrderStatus.BIKER_ARRIVED,
                    OrderStatus.ON_WASHING,
                  ],
                },
                timeSlot: timeSlot,
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
                bookingDateStr: dateStr,
              },
            },
            // Join with locations to get area and city
            {
              $lookup: {
                from: 'locations',
                localField: 'location',
                foreignField: '_id',
                as: 'locationDetails',
                pipeline: [{ $project: { area: 1, city: 1 } }],
              },
            },
            {
              $unwind: {
                path: '$locationDetails',
                preserveNullAndEmptyArrays: false,
              },
            },
            {
              $match: {
                'locationDetails.area': area,
                'locationDetails.city': city,
              },
            },
            {
              $limit: 1,
            },
          ];

          const orderResult = await this.ordersModel.aggregate(ordersPipeline);
          bikerShift.biker.hasAnOrder = orderResult.length > 0;
        }

        // Flatten the bikers array to only include biker details with hasAnOrder
        result.bikers = result.bikers.map((bs: any) => bs.biker);
      }
    } else {
      // If no date is provided, just flatten the bikers array
      for (const result of results) {
        result.bikers = result.bikers.map((bs: any) => bs.biker);
      }
    }

    return results;
  }

  async findOne(id: string) {
    const bikerSchedule = await this.bikerScheduleModel
      .findById(id, { __v: 0, createdAt: 0, updatedAt: 0 })
      .populate('biker', 'userName phone nationalId')
      .populate('shifts.city', 'name')
      .populate('shifts.area', 'name')
      .lean();

    if (!bikerSchedule) {
      throw new NotFoundException({
        ar: 'الجدول غير موجود',
        en: 'Biker schedule not found',
      });
    }

    return bikerSchedule;
  }

  async update(
    adminId: string,
    bikerId: string,
    updateBikerScheduleDto: UpdateBikerScheduleDto,
  ) {
    // Validate each shift's city and area if shifts are being updated
    if (updateBikerScheduleDto.shifts) {
      const uniqueCities = new Set<string>();
      const shiftsByCity = new Map<string, string[]>();

      for (const shift of updateBikerScheduleDto.shifts) {
        // Collect unique cities
        uniqueCities.add(shift.city);

        // Group areas by city for validation
        if (!shiftsByCity.has(shift.city)) {
          shiftsByCity.set(shift.city, []);
        }
        const cityAreas = shiftsByCity.get(shift.city);
        if (cityAreas && !cityAreas.includes(shift.area)) {
          cityAreas.push(shift.area);
        }
      }

      // Check city permissions for all cities used
      for (const city of uniqueCities) {
        await this.adminService.CityPermissionForCreation(adminId, city as any);
      }

      // Validate areas for each city
      for (const [city, areas] of shiftsByCity.entries()) {
        await this.areasService.validateAreas(city as any, areas as any);
      }
    }

    const bikerSchedule = await this.bikerScheduleModel
      .findOneAndUpdate(
        { biker: new Types.ObjectId(bikerId) },
        updateBikerScheduleDto,
        {
          new: true,
          runValidators: true,
        },
      )
      .populate('biker', 'userName phone nationalId')
      .lean();

    if (!bikerSchedule) {
      throw new NotFoundException({
        ar: 'الجدول غير موجود',
        en: 'Biker schedule not found',
      });
    }

    return bikerSchedule;
  }

  async remove(bikerId: string) {
    const bikerSchedule = await this.bikerScheduleModel.findOneAndDelete({
      biker: new Types.ObjectId(bikerId),
    });

    if (!bikerSchedule) {
      throw new NotFoundException({
        ar: 'الجدول غير موجود',
        en: 'Biker schedule not found',
      });
    }

    return { message: 'Biker schedule deleted successfully' };
  }

  async findByBiker(bikerId: string) {
    const bikerSchedule = await this.bikerScheduleModel
      .findOne({ biker: bikerId }, { __v: 0, createdAt: 0, updatedAt: 0 })
      .populate('biker', 'userName phone nationalId')
      .populate('shifts.city', 'name')
      .populate('shifts.area', 'name')
      .lean();

    return bikerSchedule;
  }

  async findByArea(areaId: string) {
    return await this.bikerScheduleModel
      .find({ area: areaId }, { __v: 0, createdAt: 0, updatedAt: 0 })
      .populate('biker', 'userName phone nationalId')
      .populate('shifts.city', 'name')
      .populate('shifts.area', 'name')
      .lean();
  }

  async findByDay(day: string) {
    return await this.bikerScheduleModel
      .find({ day }, { __v: 0, createdAt: 0, updatedAt: 0 })
      .populate('biker', 'userName phone nationalId')
      .populate('shifts.city', 'name')
      .populate('shifts.area', 'name')
      .lean();
  }
}
