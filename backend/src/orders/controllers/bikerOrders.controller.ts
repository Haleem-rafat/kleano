import {
  Body,
  Controller,
  Get,
  ParseIntPipe,
  Patch,
  Query,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { Account } from 'src/common/decorators/user.decorator';
import { UserAuthGuard } from '../../auth/guards/userAuthentication.guard';
import { AcceptOrderDTO } from '../dtos/acceptOrder.dto';
import { GetOrdersDTO } from '../dtos/getOrders.dto';
import { GetOrdersCountDTO } from '../dtos/getOrdersCount.dto';
import { BikerOrdersService } from '../services/bikerOrders.service';

@Controller('orders/biker')
export class BikerOrdersController {
  constructor(private bikerOrdersService: BikerOrdersService) {}

  @Get('')
  @UseGuards(UserAuthGuard)
  async getOrdersByStatusController(
    @Account() account: any,
    @Query() getOrdersDTO: GetOrdersDTO,
  ) {
    const result = await this.bikerOrdersService.getAllBikerOrders(
      account.id,
      getOrdersDTO,
    );
    return {
      success: true,
      totalPages: result.paginationData.totalPages,
      totalItems: result.paginationData.totalItems,
      data: result.dataList,
    };
  }

  @Patch('accept-order')
  @UseGuards(UserAuthGuard)
  async acceptOrderController(
    @Account() account: any,
    @Body() acceptOrderDTO: AcceptOrderDTO,
  ) {
    /* TODO document why this async method 'acceptOrderController' is empty */
    await this.bikerOrdersService.acceptOrderByBiker(
      account.id,
      acceptOrderDTO,
    );
    return {
      success: true,
    };
  }
  @Patch('on-the-way')
  @UseGuards(UserAuthGuard)
  async orderOnTheWayController(
    @Account() account: any,
    @Body('order') order: string,
  ) {
    /* TODO document why this async method 'bikerOnTheWayController' is empty */
    await this.bikerOrdersService.orderOnTheWay(account.id, order);
    return {
      success: true,
    };
  }
  @Patch('arrived')
  @UseGuards(UserAuthGuard)
  async bikerArrivedController(
    @Account() account: any,
    @Body('order') order: string,
  ) {
    /* TODO document why this async method 'bikerArrivedController' is empty */
    await this.bikerOrdersService.bikerArrived(account.id, order);

    return {
      success: true,
    };
  }

  @Patch('cancel-order')
  @UseGuards(UserAuthGuard)
  async cancelOrderByBikerController(
    @Account() account: any,
    @Body('order') order: string,
  ) {
    await this.bikerOrdersService.cancelOrderByBiker(account.id, order);

    return {
      success: true,
    };
  }

  @Patch('on-washing')
  @UseGuards(UserAuthGuard)
  @UseInterceptors(FileInterceptor('image', { dest: 'uploads/' }))
  async orderOnWashingController(
    @Account() account: any,
    @Body('order') order: string,
    @UploadedFile() image: Express.Multer.File,
  ) {
    /* TODO document why this async method 'bikerOnWashingController' is empty */
    await this.bikerOrdersService.orderOnWashing(account.id, order, image);

    return {
      success: true,
    };
  }
  @Patch('completed')
  @UseGuards(UserAuthGuard)
  @UseInterceptors(FileInterceptor('image', { dest: 'uploads/' }))
  async orderCompletedController(
    @Account() account: any,
    @Body('order') order: string,
    @UploadedFile() image: Express.Multer.File,
  ) {
    /* TODO document why this async method 'bikerCompleteOrderController' is empty */
    await this.bikerOrdersService.orderCompleted(account.id, order, image);

    return {
      success: true,
    };
  }

  @Patch('rate-order')
  @UseGuards(UserAuthGuard)
  async rateOrderByUser(
    @Account() account: any,
    @Body('order') order: string,
    @Body('starsNum', ParseIntPipe) starsNum: number,
  ) {
    await this.bikerOrdersService.rateUser(account.id, order, starsNum);

    return {
      success: true,
    };
  }

  @Get('total-orders')
  @UseGuards(UserAuthGuard)
  async getBikerTotalOrdersController(
    @Account() account: any,
    @Query() getOrdersCountDTO: GetOrdersCountDTO,
  ) {
    const data = await this.bikerOrdersService.getBikerTotalOrders(
      account.id,
      getOrdersCountDTO.status,
    );
    return {
      success: true,
      data: data,
    };
  }

  @Get('total-commission')
  @UseGuards(UserAuthGuard)
  async getBikerTotalCommissionController(@Account() account: any) {
    const data = await this.bikerOrdersService.getBikerTotalCommission(
      account.id,
    );
    return {
      success: true,
      data: data,
    };
  }
}
