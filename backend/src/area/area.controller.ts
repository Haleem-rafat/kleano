import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Patch,
  UseGuards,
  BadRequestException,
  Query,
} from '@nestjs/common';
import { AreasService } from './area.service';
import { UserAuthGuard } from '../auth/guards';
import { IsAdminGuard } from '../admin/guard/isAdmin.guard';
import { SuperAdminGuard } from '../auth/guards/superAdmin.guard';
import { CreateAreaDto } from './dto/createArea.dto';
import { UpdateAreaDto } from './dto/updateArea.dto';

@Controller('areas')
export class AreasController {
  constructor(private readonly areasService: AreasService) {}

  @Get('/city/:cityId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getAllAreasInCity(@Param('cityId') cityId: string) {
    const areas = await this.areasService.getAreasByCity(cityId);
    if (!areas) {
      throw new BadRequestException('City not found or no areas available.');
    }
    return {
      success: true,
      data: areas,
    };
  }

  @Get('/location')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getAreaByLocation(
    @Query('longitude') longitude: string,
    @Query('latitude') latitude: string,
  ) {
    if (!longitude || !latitude) {
      throw new BadRequestException('Longitude and Latitude are required.');
    }

    const area = await this.areasService.getAreaByCoordinates(
      parseFloat(longitude),
      parseFloat(latitude),
    );

    if (!area) {
      throw new BadRequestException(
        'No area found near the provided location.',
      );
    }

    return {
      success: true,
      data: area,
    };
  }

  @Post('newArea')
  @UseGuards(UserAuthGuard, SuperAdminGuard)
  async createArea(@Body() createAreaDto: CreateAreaDto) {
    const newArea = await this.areasService.createArea(createAreaDto);
    return {
      success: true,
      data: newArea,
    };
  }

  @Patch('/:areaId')
  @UseGuards(UserAuthGuard, SuperAdminGuard)
  async updateArea(
    @Param('areaId') areaId: string,
    @Body() updateAreaDto: UpdateAreaDto,
  ) {
    const updatedArea = await this.areasService.updateArea(
      areaId,
      updateAreaDto,
    );
    return {
      success: true,
      data: updatedArea,
    };
  }
}
