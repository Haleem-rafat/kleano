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
import { AddOnsService } from '../services/add-ons.service';
import { UserAuthGuard } from '../../auth/guards/userAuthentication.guard';
import { IsAdminGuard } from '../../admin/guard/isAdmin.guard';
import { CreateAddOnsDTO } from '../dtos/createAddOns.dto';
import { Account } from '../../common/decorators/user.decorator';
import { QueryParamsDTO } from '../dtos/add-ons-queryParams.dto';
import { UpdateAddOnsDTO } from '../dtos/updateAddOns.dto';
import { AddToNewCityDTO } from '../dtos/addToNewCity.dto';

@Controller('add-ons')
export class AddOnsController {
  constructor(private addOnsService: AddOnsService) {}

  @Post()
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createAddOnsController(
    @Body() createAddOnsDTO: CreateAddOnsDTO,
    @Account() account: any,
  ) {
    await this.addOnsService.createAddOns(
      createAddOnsDTO,
      account.id,
      account.role,
    );

    return {
      success: true,
    };
  }

  @Get('/user/all')
  @UseGuards(UserAuthGuard)
  async getAllAddOnsesForUserController(
    @Query() queryParamsDTO: QueryParamsDTO,
    @Account() account: any,
  ) {
    const result = await this.addOnsService.getAllAddOnsForUser(
      account.id,
      queryParamsDTO,
    );

    return {
      success: true,
      message: result.message,
      data: result.addOnses,
    };
  }

  @Get('/guest/all')
  async getAllAddOnsesForGuestController(
    @Query() queryParamsDTO: QueryParamsDTO,
  ) {
    const result = await this.addOnsService.getAllAddOnsForGuest(
      queryParamsDTO,
    );

    return {
      success: true,
      message: result.message,
      data: result.addOnses,
    };
  }

  @Get('admin/all')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getAllAddOnsesForAdminController(@Account() account: any) {
    return {
      success: true,
      data: await this.addOnsService.getAllForAdmin(account.role, account.id),
    };
  }

  @Get('admin/details/:addOnsId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getByIdForAdmin(@Param('addOnsId') addOnsId: string) {
    return {
      success: true,
      data: await this.addOnsService.getByIdOr404(addOnsId),
    };
  }
  @Put(':addOnsId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async updateController(
    @Param('addOnsId') addOnsId: string,
    @Body() updateAddOnsDTO: UpdateAddOnsDTO,
  ) {
    await this.addOnsService.updateAddOns(addOnsId, updateAddOnsDTO);
    return {
      success: true,
    };
  }

  @Post('/add-ons-cities')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async addAddOnsToNewCityController(@Body() addToNewCityDTO: AddToNewCityDTO) {
    await this.addOnsService.addToNewCity(
      addToNewCityDTO.addOns,
      addToNewCityDTO.city,
    );

    return {
      success: true,
    };
  }
  @Delete('/add-ons-cities')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async deleteAddOnsFromCityController(
    @Body() addToNewCityDTO: AddToNewCityDTO,
  ) {
    await this.addOnsService.deleteOneFromCity(
      addToNewCityDTO.addOns,
      addToNewCityDTO.city,
    );

    return {
      success: true,
    };
  }

  @Put('/add-ons-cities/archive')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async archiveAddOnsFromCityController(
    @Body() addToNewCityDTO: AddToNewCityDTO,
  ) {
    await this.addOnsService.archiveOneFromCity(
      addToNewCityDTO.addOns,
      addToNewCityDTO.city,
    );

    return {
      success: true,
    };
  }

  @Put('/add-ons-cities/activate')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async activateAddOnsFromCityController(
    @Body() addToNewCityDTO: AddToNewCityDTO,
  ) {
    await this.addOnsService.activateOneFromCity(
      addToNewCityDTO.addOns,
      addToNewCityDTO.city,
    );

    return {
      success: true,
    };
  }

  @Get('admin/add-ons-report')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getAddOnsReport() {
    const addOn = await this.addOnsService.getAddOnsReport();
    return {
      success: true,
      data: addOn,
    };
  }

  @Put('/add-ons-cities/suspend/:addOnsId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async suspendAddOnsFromCityController(@Param('addOnsId') addOnsId: string) {
    await this.addOnsService.suspendAllFromCities(addOnsId);

    return {
      success: true,
    };
  }
}
