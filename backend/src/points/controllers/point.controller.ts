import {
  Body,
  Controller,
  Get,
  ParseIntPipe,
  Post,
  Put,
  UseGuards,
} from '@nestjs/common';
import { IsAdminGaurd, UserAuthGuard } from 'src/auth/guards';
import { PointService } from '../services/point.service';

@Controller('points')
export class PointController {
  constructor(private pointService: PointService) {}

  @Post()
  @UseGuards(UserAuthGuard, IsAdminGaurd)
  async createPointsSystem(
    @Body('totalPayPercentage', ParseIntPipe) totalPayPercentage: number,
    @Body('exchangePercentage', ParseIntPipe) exchangePercentage: number,
    @Body('redeemLimit', ParseIntPipe) redeemLimit: number,
  ) {
    return {
      success: true,
      data: await this.pointService.createPointsPercentages(
        totalPayPercentage,
        exchangePercentage,
        redeemLimit,
      ),
    };
  }

  @Put('')
  @UseGuards(UserAuthGuard, IsAdminGaurd)
  async updatePointsSystem(
    @Body('totalPayPercentage', ParseIntPipe) totalPayPercentage: number,
    @Body('exchangePercentage', ParseIntPipe) exchangePercentage: number,
    @Body('redeemLimit', ParseIntPipe) redeemLimit: number,
  ) {
    return {
      success: true,
      data: await this.pointService.updatePointsPercentage(
        totalPayPercentage,
        exchangePercentage,
        redeemLimit,
      ),
    };
  }

  @Get('admin/points-system')
  @UseGuards(UserAuthGuard, IsAdminGaurd)
  async getPointSystem() {
    return {
      success: true,
      data: await this.pointService.getPointsSystem(),
    };
  }

  @Post('calculate-discount')
  @UseGuards(UserAuthGuard)
  async calculatePointsDiscountAmount(
    @Body('points', ParseIntPipe) points: number,
  ) {
    return {
      success: true,
      data: await this.pointService.calculatePointsDiscountAmount(points),
    };
  }
}
