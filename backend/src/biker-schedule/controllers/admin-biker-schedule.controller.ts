import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { IsAdminGuard } from 'src/admin/guard';
import { UserAuthGuard } from 'src/auth/guards';
import { Account } from 'src/common/decorators/user.decorator';
import { CreateBikerScheduleDto } from '../dtos/create-biker-schedule.dto';
import { QueryBikerScheduleDto } from '../dtos/query-biker-schedule.dto';
import { UpdateBikerScheduleDto } from '../dtos/update-biker-schedule.dto';
import { AdminBikerScheduleService } from '../services/admin-biker-schedule.service';

/**
 * Admin Biker Schedule Controller
 *
 * Endpoints:
 * - POST /admin/biker-schedules - Create a new biker schedule
 * - GET /admin/biker-schedules - Get all biker schedules (with optional filters)
 * - GET /admin/biker-schedules/biker/:bikerId - Get schedules for a specific biker
 * - GET /admin/biker-schedules/area/:areaId - Get schedules for a specific area
 * - GET /admin/biker-schedules/day/:day - Get schedules for a specific day
 * - GET /admin/biker-schedules/:id - Get a specific biker schedule by ID
 * - PATCH /admin/biker-schedules/:id - Update a biker schedule
 * - DELETE /admin/biker-schedules/:id - Delete a biker schedule
 */
@Controller('admin/biker-schedules')
@UseGuards(UserAuthGuard, IsAdminGuard)
export class AdminBikerScheduleController {
  constructor(
    private readonly adminBikerScheduleService: AdminBikerScheduleService,
  ) {}

  @Post()
  async create(
    @Account() account: any,
    @Body() createBikerScheduleDto: CreateBikerScheduleDto,
  ) {
    const bikerSchedule = await this.adminBikerScheduleService.create(
      account.id,
      createBikerScheduleDto,
    );

    return {
      success: true,
      data: bikerSchedule,
    };
  }

  @Get()
  async findAll(@Query() query: QueryBikerScheduleDto) {
    const bikerSchedules = await this.adminBikerScheduleService.findAll(query);

    return {
      success: true,
      data: bikerSchedules,
    };
  }

  @Get('biker/:bikerId')
  async findByBiker(@Param('bikerId') bikerId: string) {
    const bikerSchedules = await this.adminBikerScheduleService.findByBiker(
      bikerId,
    );

    return {
      success: true,
      data: bikerSchedules,
    };
  }

  @Get('area/:areaId')
  async findByArea(@Param('areaId') areaId: string) {
    const bikerSchedules = await this.adminBikerScheduleService.findByArea(
      areaId,
    );

    return {
      success: true,
      data: bikerSchedules,
    };
  }

  @Get('day/:day')
  async findByDay(@Param('day') day: string) {
    const bikerSchedules = await this.adminBikerScheduleService.findByDay(day);

    return {
      success: true,
      data: bikerSchedules,
    };
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    const bikerSchedule = await this.adminBikerScheduleService.findOne(id);

    return {
      success: true,
      data: bikerSchedule,
    };
  }

  @Patch('biker/:bikerId')
  async update(
    @Account() account: any,
    @Param('bikerId') bikerId: string,
    @Body() updateBikerScheduleDto: UpdateBikerScheduleDto,
  ) {
    const bikerSchedule = await this.adminBikerScheduleService.update(
      account.id,
      bikerId,
      updateBikerScheduleDto,
    );

    return {
      success: true,
      data: bikerSchedule,
    };
  }

  @Delete('biker/:bikerId')
  async remove(@Param('bikerId') bikerId: string) {
    const result = await this.adminBikerScheduleService.remove(bikerId);

    return {
      success: true,
      message: result.message,
    };
  }
}
