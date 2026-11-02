import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common';
import { CreateWashingServiceDTO, UpdateWashingServiceDTO } from '../dtos';
import { WashingServicesService } from '../services/washing-services.service';
import { UserAuthGuard } from '../../auth/guards/userAuthentication.guard';
import { IsAdminGuard } from '../../admin/guard/isAdmin.guard';
import { City } from '../../city/schemas/city.schema';
import { WashingService } from '../schemas/washing-services.schema';
import { Account } from '../../common/decorators/user.decorator';
import { QueryParamsDTO } from '../dtos/queryParams.dto';

@Controller('washing-services')
export class WashingServicesController {
  constructor(private washingServicesService: WashingServicesService) {}

  @Post('')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createWashingServiceController(
    @Account() account: any,
    @Body() createWashingServiceDTO: CreateWashingServiceDTO,
  ) {
    await this.washingServicesService.createWashingService(
      createWashingServiceDTO,
      account.id,
      account.role,
    );

    return {
      success: true,
    };
  }

  @Get('user/all')
  @UseGuards(UserAuthGuard)
  async getAllWashingServicesForUserController(
    @Account() account: any,
    @Query() queryParamsDTO: QueryParamsDTO,
  ) {
    const result =
      await this.washingServicesService.getAllWashingServicesForUser(
        account.id,
        queryParamsDTO,
        queryParamsDTO.type,
      );
    return {
      success: true,
      message: result.message,
      data: result.washingServices,
    };
  }

  @Get('guest/all')
  async getAllWashingServicesForGuestController(
    @Query() queryParamsDTO: QueryParamsDTO,
  ) {
    const result =
      await this.washingServicesService.getAllWashingServicesForGuest(
        queryParamsDTO,
        queryParamsDTO.type,
      );
    return {
      success: true,
      message: result.message,
      data: result.washingServices,
    };
  }

  @Get('admin/all')
  @UseGuards(UserAuthGuard)
  async getAllWashingServicesForAdminController(@Account() account: any) {
    return {
      success: true,
      data: await this.washingServicesService.getAllWashingServicesForAdmin(
        account.role,
        account.id,
      ),
    };
  }

  @Get('/user/details/:washingServiceId')
  @UseGuards(UserAuthGuard)
  async getByIdController(@Param('washingServiceId') washingServiceId: string) {
    return {
      success: true,
      data: await this.washingServicesService.getWashingServiceById(
        washingServiceId,
      ),
    };
  }

  @Get('/admin/details/:washingServiceId')
  @UseGuards(UserAuthGuard)
  async getByIdForAdminController(
    @Param('washingServiceId') washingServiceId: string,
  ) {
    return {
      success: true,
      data: await this.washingServicesService.getWashingServiceByIdForAdmin(
        washingServiceId,
      ),
    };
  }

  @Get('/guest/details/:washingServiceId')
  async getByIdForGuestController(
    @Param('washingServiceId') washingServiceId: string,
  ) {
    return {
      success: true,
      data: await this.washingServicesService.getWashingServiceById(
        washingServiceId,
      ),
    };
  }

  @Put(':washingServiceId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async updateController(
    @Param('washingServiceId') washingServiceId: string,
    @Body() updateWashingServiceDTO: UpdateWashingServiceDTO,
  ) {
    return {
      success: true,
      data: await this.washingServicesService.update(
        washingServiceId,
        updateWashingServiceDTO,
      ),
    };
  }

  @Post('/services-cities')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async addWashingServiceToNewCityController(
    @Body('washingService') washingService: WashingService,
    @Body('city') city: City,
    @Account() account: any,
  ) {
    // TODO:
    await this.washingServicesService.addWashingServiceToNewCity(
      washingService,
      city,
      account.id,
    );

    return {
      success: true,
    };
  }
  @Delete('/services-cities')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async deleteWashingServiceFromCityController(
    @Body('washingService') washingService: WashingService,
    @Body('city') city: City,
  ) {
    // TODO:
    await this.washingServicesService.deleteWashingServiceFromCity(
      washingService,
      city,
    );

    return {
      success: true,
    };
  }

  @Put('/services-cities/archive')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async archiveWashingServiceFromCityController(
    @Body('washingService') washingService: WashingService,
    @Body('city') city: City,
  ) {
    // TODO:
    await this.washingServicesService.archiveWashingServiceFromCity(
      washingService,
      city,
    );

    return {
      success: true,
    };
  }

  @Put('/services-cities/activate')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async activateWashingServiceFromCityController(
    @Body('washingService') washingService: WashingService,
    @Body('city') city: City,
  ) {
    // TODO:
    await this.washingServicesService.activateWashingServiceFromCity(
      washingService,
      city,
    );

    return {
      success: true,
    };
  }

  @Get('admin/washing-services-report')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getServicesReport() {
    const service = await this.washingServicesService.getServicesReport();
    return {
      success: true,
      data: service,
    };
  }

  @Put('/services-cities/suspend/:servicesId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async suspendServicesFromCityController(
    @Param('servicesId') servicesId: string,
  ) {
    await this.washingServicesService.suspendAllFromCities(servicesId);

    return {
      success: true,
    };
  }
}
