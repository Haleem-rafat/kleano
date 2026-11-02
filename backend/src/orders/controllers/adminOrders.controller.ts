import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Query,
  Res,
  UseGuards,
} from '@nestjs/common';
import { Response } from 'express';
import { IsAdminGuard } from 'src/admin/guard';
import { IsAdminGaurd, UserAuthGuard } from 'src/auth/guards';
import { Account } from 'src/common/decorators/user.decorator';
import { GetOrdersByAdminDTO } from '../dtos';
import { AdminsOrdersService } from '../services/adminOrders.service';

@Controller('orders/admins')
export class AdminsOrdersController {
  constructor(private adminsOrdersService: AdminsOrdersService) {}

  //TODO: Add status[] in query if for listing with more than one status
  @Get('all')
  @UseGuards(UserAuthGuard, IsAdminGaurd)
  async getAllOrdersByAdminController(
    @Account() account: any,
    @Query() getOrdersByAdminQuery: GetOrdersByAdminDTO,
  ) {
    const ordersPagination = await this.adminsOrdersService.getOrdersByAdmin(
      account.id,
      account.role,
      getOrdersByAdminQuery,
    );
    return {
      success: true,
      pagination: ordersPagination.paginationData,
      data: ordersPagination.dataList,
    };
  }

  //TODO: Add bikerId in query if admin list assigned order to biker
  @Get('assigned')
  @UseGuards(UserAuthGuard, IsAdminGaurd)
  async ge(
    @Account() account: any,
    @Query() getOrdersByAdminQuery: GetOrdersByAdminDTO,
  ) {
    const assignedOrdersPagination =
      await this.adminsOrdersService.getAssignedOrdersByAdmin(
        account.id,
        getOrdersByAdminQuery,
      );
    return {
      success: true,
      pagination: assignedOrdersPagination.paginationData,
      data: assignedOrdersPagination.dataList,
    };
  }

  @Get('/order-details/:orderId')
  @UseGuards(UserAuthGuard, IsAdminGaurd)
  async getOrderById(@Param('orderId') orderId: string) {
    const order = await this.adminsOrdersService.getOrderById(orderId);
    return {
      success: true,
      data: order,
    };
  }

  @Patch('/cancel-order')
  @UseGuards(UserAuthGuard, IsAdminGaurd)
  async cancelOrderController(
    @Body('order') order: string,
    @Body('cancellationReason') cancellationReason: string,
    @Body('totalAmount') totalAmount: number,
    @Account() account: any,
  ) {
    await this.adminsOrdersService.cancelOrderByAdmin(
      order,
      account.id,
      totalAmount,
      cancellationReason,
    );
    return {
      success: true,
    };
  }

  @Patch('/:orderId/assign-biker')
  @UseGuards(UserAuthGuard, IsAdminGaurd)
  async assignOrderByAdminController(
    @Account() account: any,
    @Param('orderId') orderId: string,
    @Body('bikerId') bikerId: string,
  ) {
    return {
      success: true,
      data: await this.adminsOrdersService.assignOrderToBikerByAdmin(
        orderId,
        bikerId,
        account.id,
      ),
    };
  }

  @Get('/total-duration-report')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getOrderTotalDurationReport() {
    const totalDuration =
      await this.adminsOrdersService.getOrderDurationReport();
    return {
      success: true,
      data: totalDuration,
    };
  }

  @Get('/export-orders-excel')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async exportOrders(@Res() res: Response) {
    const buffer = await this.adminsOrdersService.exportOrdersToExcel();

    res.setHeader(
      'Content-Type',
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    res.setHeader('Content-Disposition', 'attachment; filename="orders.xlsx"');

    return res.send(buffer);
  }

  @Get('/export-orders-csv')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async exportOrdersToCSV(@Res() res: Response) {
    const csv = await this.adminsOrdersService.exportOrdersToCSV();

    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="orders.csv"');

    return res.send(csv);
  }

  @Get('/revenue-per-month')
  @UseGuards(UserAuthGuard, IsAdminGaurd)
  async getOrdersRevenuePerMonthForCurrentYear() {
    const data =
      await this.adminsOrdersService.getOrdersRevenuePerMonthForCurrentYear();
    return {
      success: true,
      data: data.monthlyReport,
      yearTotalRevenue: data.yearTotalRevenue,
    };
  }

  @Get('/revenue-per-week')
  @UseGuards(UserAuthGuard, IsAdminGaurd)
  async getOrdersRevenuePerWeek() {
    const data = await this.adminsOrdersService.getOrdersRevenuePerWeek();
    return {
      success: true,
      data,
    };
  }

  @Get('/biker/:bikerId/total-commission')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getBikerTotalCommission(@Param('bikerId') bikerId: string) {
    const data = await this.adminsOrdersService.getBikerTotalCommission(
      bikerId,
    );
    return {
      success: true,
      data,
    };
  }
}
