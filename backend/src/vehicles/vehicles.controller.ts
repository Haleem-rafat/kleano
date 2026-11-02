import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Put,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { VehiclesService } from './vehicles.service';
import { CreateVehicleDTO } from './dto/createVehicle.dto';
import { FileInterceptor } from '@nestjs/platform-express';
import { Account } from '../common/decorators/user.decorator';
import { UserAuthGuard } from '../auth/guards';
import { UserAuthorizedGuard } from '../user/guard';
import { IsVehicleOwner, IsVehicleOwnerOrAdmin } from './guard';
import { IsAdminGuard } from '../admin/guard';
import * as fs from 'fs';

@Controller('vehicles')
export class VehiclesController {
  constructor(private vehiclesService: VehiclesService) {}

  @Post('')
  @UseGuards(UserAuthGuard, UserAuthorizedGuard)
  @UseInterceptors(FileInterceptor('image', { dest: 'uploads/' }))
  async createVehicleController(
    @Account() account: any,
    @Body() createVehicleDTO: CreateVehicleDTO,
    @UploadedFile() image: Express.Multer.File,
  ) {
    return {
      success: true,
      data: await this.vehiclesService.createVehicle(
        account.id,
        createVehicleDTO,
        image,
      ),
    };
  }
  @Get('')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getAllController(@Query('userId') userId: string) {
    const vehicles = await this.vehiclesService.getAll(userId);

    return {
      success: true,
      data: vehicles,
    };
  }
  @Get('cars-model')
  @UseGuards(UserAuthGuard, UserAuthorizedGuard)
  getCarModels() {
    try {
      const data = fs.readFileSync(
        `${process.cwd()}/src/vehicles/vehiclesBrands.json`,
        'utf8',
      );

      const jsonData = JSON.parse(data);

      const parsedJsonData = jsonData;

      return {
        success: true,
        data: parsedJsonData.brands,
      };
    } catch (error) {
      console.log(`ERROR: ${error}`);
    }
  }

  @Get(':vehicleId')
  @UseGuards(UserAuthGuard, IsVehicleOwnerOrAdmin)
  async getByIdController(@Param('vehicleId') vehicleId: string) {
    return {
      success: true,
      data: await this.vehiclesService.getByIdOr404(vehicleId),
    };
  }

  @Delete(':vehicleId')
  @UseGuards(UserAuthGuard, IsVehicleOwner)
  async deleteController(@Param('vehicleId') vehicleId: string) {
    await this.vehiclesService.delete(vehicleId);

    return {
      success: true,
    };
  }

  @Put(':vehicleId')
  @UseGuards(UserAuthGuard, IsVehicleOwner)
  @UseInterceptors(FileInterceptor('image', { dest: 'uploads/' }))
  async updateController(
    @Param('vehicleId') vehicleId: string,
    @Body() createVehicleDTO: CreateVehicleDTO,
    @UploadedFile() image: Express.Multer.File,
  ) {
    return {
      success: true,
      data: await this.vehiclesService.update(
        vehicleId,
        createVehicleDTO,
        image,
      ),
    };
  }
}
