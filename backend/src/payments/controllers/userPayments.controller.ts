import {
  Body,
  Controller,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { Account } from 'src/common/decorators/user.decorator';

import { UserAuthGuard } from '../../auth/guards/userAuthentication.guard';
import { UsersPaymentsService } from '../services/userPayments.service';
import { GetPaymentsDTO } from '../dtos';

@Controller('payments/user')
export class UserPaymentsController {
  constructor(private usersPaymentsService: UsersPaymentsService) {}

  @Get('all')
  @UseGuards(UserAuthGuard)
  async getAllUserPaymentsController(
    @Account() account: any,
    @Query() getPaymentsDTO: GetPaymentsDTO,
  ) {
    const paymentsResult = await this.usersPaymentsService.getAllUserPayments(
      account.id,
      getPaymentsDTO,
    );
    return {
      success: true,
      totalPages: paymentsResult.paginationData.totalPages,
      totalItems: paymentsResult.paginationData.totalItems,
      data: paymentsResult.dataList,
    };
  }

  @Get('payment-details/:paymentId')
  @UseGuards(UserAuthGuard)
  async getPaymentByIdController(@Param('paymentId') paymentId: string) {
    return {
      success: true,
      data: await this.usersPaymentsService.getPaymentByIdPopulated(paymentId),
    };
  }

  @Get('payment-details/apple/:paymentId')
  @UseGuards(UserAuthGuard)
  async getApplePaymentByIdController(@Param('paymentId') paymentId: string) {
    return {
      success: true,
      data: await this.usersPaymentsService.getApplePaymentById(paymentId),
    };
  }
}
