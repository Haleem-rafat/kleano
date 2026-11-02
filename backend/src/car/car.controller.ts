import { Controller, Get, Param } from '@nestjs/common';
import { CarsService } from './car.service';

@Controller('cars')
export class CarController {
  constructor(private carsService: CarsService) {}

  // @Post()
  // async seedDbWithCarModels() {
  //   return {
  //     success: true,
  //     data: await this.carsService.seedDbWithCarModels(),
  //   };
  // }

  @Get()
  async getAllCarBrands() {
    return {
      success: true,
      data: await this.carsService.getAllCarBrands(),
    };
  }

  @Get(':brandId')
  async getAllCarModelsByBrandId(@Param('brandId') brandId: string) {
    return {
      success: true,
      data: await this.carsService.getAllCarModelsByBrandId(brandId),
    };
  }
}
