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
import { IsAdminGuard } from '../../admin/guard/isAdmin.guard';
import { UserAuthGuard } from '../../auth/guards/userAuthentication.guard';
import { Account } from '../../common/decorators/user.decorator';
import { UpdatePlanDTO } from '../dtos';
import { CreatePlanDTO } from '../dtos/createPlan.dto';
import { QueryParamsDTO } from '../dtos/queryParams.dto';
import { UpdatePlanCitiesDTO } from '../dtos/updatePlanCities.dto';
import { PlansService } from '../services/plans.service';

@Controller('plans')
export class PlansController {
  constructor(private plansService: PlansService) {}

  @Post()
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createPlanController(
    @Body() createPlanDTO: CreatePlanDTO,
    @Account() account: any,
  ) {
    await this.plansService.createPlan(createPlanDTO, account.id, account.role);

    return {
      success: true,
    };
  }

  @Get('user/all')
  @UseGuards(UserAuthGuard)
  async getAllPlansForUserController(
    @Account() account: any,
    @Query() queryParamsDTO: QueryParamsDTO,
  ) {
    const result = await this.plansService.getAllForUser(
      account.id,
      queryParamsDTO,
    );
    return {
      success: true,
      message: result.message,
      data: result.plans,
    };
  }

  @Get('guest/all')
  async getAllPlansForGuestController(@Query() queryParamsDTO: QueryParamsDTO) {
    const result = await this.plansService.getAllForGuest(queryParamsDTO);
    return {
      success: true,
      message: result.message,
      data: result.plans,
    };
  }

  @Get('admin/all')
  @UseGuards(UserAuthGuard)
  async getAllPlansForAdminController(@Account() account: any) {
    return {
      success: true,
      data: await this.plansService.getAllForAdmin(account.id, account.role),
    };
  }

  @Get('admin/dropdown')
  @UseGuards(UserAuthGuard)
  async getAllForAdminDropdown(@Account() account: any) {
    return {
      success: true,
      data: await this.plansService.getAllForAdminDropdown(
        account.id,
        account.role,
      ),
    };
  }

  @Get('/user/details/:planId')
  @UseGuards(UserAuthGuard)
  async getPlanByIdForUserController(@Param('planId') planId: string) {
    return {
      success: true,
      data: await this.plansService.getById(planId),
    };
  }
  @Get('/admin/details/:planId')
  @UseGuards(UserAuthGuard)
  async getPlanByIdForAdminController(@Param('planId') planId: string) {
    return {
      success: true,
      data: await this.plansService.getPlanByIdForAdmin(planId),
    };
  }
  @Get('/guest/details/:planId')
  async getPlanByIdForGuestController(@Param('planId') planId: string) {
    return {
      success: true,
      data: await this.plansService.getById(planId),
    };
  }

  @Put(':planId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async updatePlanController(
    @Param('planId') planId: string,
    @Body() updatePlanDTO: UpdatePlanDTO,
  ) {
    return {
      success: true,
      data: await this.plansService.updatePlan(planId, updatePlanDTO),
    };
  }

  @Post('/plans-cities')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async addPlanToCityController(
    @Body() updatePlanCitiesDTO: UpdatePlanCitiesDTO,
    @Account() account: any,
  ) {
    await this.plansService.addPlanToNewCity(
      updatePlanCitiesDTO.plan,
      updatePlanCitiesDTO.city,
      account.id,
    );

    return {
      success: true,
    };
  }

  @Delete('/plans-cities')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async deletePlanFromCityController(
    @Body() updatePlanCitiesDTO: UpdatePlanCitiesDTO,
  ) {
    await this.plansService.deletePlanFromCity(
      updatePlanCitiesDTO.plan,
      updatePlanCitiesDTO.city,
    );

    return {
      success: true,
    };
  }

  @Put('/plans-cities/archive')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async archivePlanFromCityController(
    @Body() updatePlanCitiesDTO: UpdatePlanCitiesDTO,
  ) {
    // TODO:
    await this.plansService.archivePlanFromCity(
      updatePlanCitiesDTO.plan,
      updatePlanCitiesDTO.city,
    );

    return {
      success: true,
    };
  }

  @Put('/plans-cities/activate')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async activatePlanFromCityController(
    @Body() updatePlanCitiesDTO: UpdatePlanCitiesDTO,
  ) {
    // TODO:
    await this.plansService.activatePlanFromCity(
      updatePlanCitiesDTO.plan,
      updatePlanCitiesDTO.city,
    );

    return {
      success: true,
    };
  }
  @Get('/admin/plan-subscriber-report')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getSubscriptionsReport(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('planType') planType?: string,
  ) {
    const report = await this.plansService.getPlanReport(
      startDate,
      endDate,
      planType,
    );

    return {
      success: true,
      data: report,
    };
  }

  @Get('/admin/plan-subscribers/:planId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getSubscribersForPlan(@Param('planId') planId: string) {
    const subscribers = await this.plansService.getSubscribersForPlan(planId);
    return {
      success: true,
      data: subscribers,
    };
  }
}
