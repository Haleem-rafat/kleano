import { Controller, Get, UseGuards } from '@nestjs/common';
import { UserAuthGuard } from 'src/auth/guards';
import { Account } from 'src/common/decorators/user.decorator';
import { BikerBikerScheduleService } from '../services/biker-biker-schedule.service';

/**
 * Biker Schedule Controller
 *
 * Endpoints:
 * - GET /biker/schedule - Get the authenticated biker's schedule
 */
@Controller('biker/schedule')
@UseGuards(UserAuthGuard)
export class BikerBikerScheduleController {
  constructor(
    private readonly bikerBikerScheduleService: BikerBikerScheduleService,
  ) {}

  @Get()
  @UseGuards(UserAuthGuard)
  async getBikerSchedule(@Account() account: any) {
    const schedule = await this.bikerBikerScheduleService.getBikerSchedule(
      account.id,
    );

    return {
      success: true,
      data: schedule,
    };
  }
}
