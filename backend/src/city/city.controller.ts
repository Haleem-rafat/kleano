import {
  Body,
  Controller,
  Get,
  Param,
  ParseBoolPipe,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { Account } from 'src/common/decorators/user.decorator';
import { UserAuthGuard } from '../auth/guards';
import { CitiesService } from './city.service';
import { IsAdminGuard } from '../admin/guard/isAdmin.guard';
import { SuperAdminGuard } from '../auth/guards/superAdmin.guard';

@Controller('cities')
export class CitiesController {
  constructor(private citiesService: CitiesService) {}

  // @Post('seedData')
  // async seedDbWithCities() {
  //   return {
  //     success: true,
  //     data: await this.citiesService.seedDbWithCities(),
  //   };
  // }

  @Get('')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getAllController(@Account() account: any) {
    return {
      success: true,
      data: await this.citiesService.getAdminCities(account.role, account.id),
    };
  }

  @Get('/archived')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getArchivedCities(@Account() account: any) {
    return {
      success: true,
      data: await this.citiesService.getArchivedCities(
        account.role,
        account.id,
      ),
    };
  }

  @Patch(':cityId/existence')
  @UseGuards(UserAuthGuard, SuperAdminGuard)
  async updateCityExistence(
    @Param('cityId') cityId: string,
    @Body('isExist', ParseBoolPipe) isExist: boolean,
  ) {
    await this.citiesService.updateCityExistence(cityId, isExist);

    return {
      success: true,
    };
  }
}
