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
import { IsAdminGaurd, UserAuthGuard } from 'src/auth/guards';
import { Account } from 'src/common/decorators/user.decorator';

import { IsAdminGuard } from 'src/admin/guard';
import { Response } from 'express';
import { AdminsPaymentsService } from '../services/adminPayments.service';
import { GetPaymentsByAdminDTO } from '../dtos';

@Controller('payments/admins')
export class AdminsPaymentsController {
  constructor(private adminsPaymentsService: AdminsPaymentsService) {}

  // //TODO: Add status[] in query if for listing with more than one status
  @Get('all')
  @UseGuards(UserAuthGuard, IsAdminGaurd)
  async getAllPaymentsByAdminController(
    @Account() account: any,
    @Query() getPaymentsByAdminQuery: GetPaymentsByAdminDTO,
  ) {
    const paymentsPagination =
      await this.adminsPaymentsService.getPaymentsByAdmin(
        account.id,
        account.role,
        getPaymentsByAdminQuery,
      );
    return {
      success: true,
      pagination: paymentsPagination.paginationData,
      data: paymentsPagination.dataList,
    };
  }

  @Get('/payment-details/:paymentId')
  @UseGuards(UserAuthGuard, IsAdminGaurd)
  async getPaymentById(@Param('paymentId') paymentId: string) {
    const payment = await this.adminsPaymentsService.getPaymentById(paymentId);
    return {
      success: true,
      data: payment,
    };
  }
}
