import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { UserAuthGuard } from 'src/auth/guards';
import { QueryBikerScheduleDto } from '../dtos/query-biker-schedule.dto';
import { UserBikerScheduleService } from '../services/user-biker-schedule.service';

/**
 * User Biker Schedule Controller
 *
 * Endpoints:
 * - GET /biker-schedules - Get all biker schedules with availability (requires date parameter)
 */
@Controller('user/biker-schedules')
@UseGuards(UserAuthGuard)
export class UserBikerScheduleController {
  constructor(
    private readonly userBikerScheduleService: UserBikerScheduleService,
  ) {}

  @Get()
  async findAll(@Query() query: QueryBikerScheduleDto) {
    const bikerSchedules = await this.userBikerScheduleService.findAll(query);

    return {
      success: true,
      data: bikerSchedules,
    };
  }
}
