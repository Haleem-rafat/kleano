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
import { PromoCodesService } from '../../promo-code/services/promo-code.service';
import { OrderCreationDTO } from '../dtos';
import { GetOrdersDTO } from '../dtos/getOrders.dto';
import { GetTotalAfterCodeDTO } from '../dtos/getTotalAfterCode.dto';
import { UsersOrdersService } from '../services/userOrders.service';

@Controller('orders/user')
export class UserOrdersController {
  constructor(
    private usersOrdersService: UsersOrdersService,
    private promoCodesService: PromoCodesService,
  ) {}

  @Post('create-order')
  @UseGuards(UserAuthGuard)
  async createServicesOrderController(
    @Account() account: any,
    @Body() orderCreationDTO: OrderCreationDTO,
  ) {
    return {
      success: true,
      data: await this.usersOrdersService.createOrder(
        account.id,
        orderCreationDTO,
      ),
    };
  }

  @Patch('pay-order')
  @UseGuards(UserAuthGuard)
  async setOrderActiveController(
    @Account() account: any,
    @Body('order') order: string,
    @Body('paymentDetails')
    paymentDetails?: {
      name: string;
      number: string;
      cvc: string;
      month: string;
      year: string;
    },
    @Body('applePaymentId') paymentId?: string, // Optional
  ) {
    // // Set default values if paymentDetails is not provided
    // paymentDetails = paymentDetails ?? {
    //   name: 'Hadeer Hesham',
    //   number: '4111111111111111',
    //   cvc: '123',
    //   month: '12',
    //   year: '2025',
    // };

    const result = await this.usersOrdersService.payOrder(
      account.id,
      order,
      paymentDetails,
      paymentId,
    );

    // Start the timer for change status
    setTimeout(async () => {
      console.log('Check Order Status Timer Run');

      await this.usersOrdersService.checkOrderAfterMins(order, account.id);
    }, 5 * 60 * 1000);
    return {
      success: true,
      data: result,
    };
  }

  @Patch('cancel-order')
  @UseGuards(UserAuthGuard)
  async cancelOrderController(
    @Body('order') order: string,
    @Account() account: any,
  ) {
    const result = await this.usersOrdersService.cancelOrderByUser(
      order,
      account.id,
    );
    return {
      success: true,
      message: result.message,
    };
  }

  @Patch('apply-points')
  @UseGuards(UserAuthGuard)
  async applyPointsController(
    @Account() account: any,
    @Body('order') order: string,
  ) {
    return {
      success: true,
      data: await this.usersOrdersService.applyUserPoints(account.id, order),
    };
  }

  @Patch('apply-promo-code')
  @UseGuards(UserAuthGuard)
  async applyPromoCodeController(
    @Account() account: any,
    @Body('order') order: string,
    @Body('code') code: string,
  ) {
    return {
      success: true,
      data: await this.usersOrdersService.applyPromoCodeForOrder(
        account.id,
        order,
        code,
      ),
    };
  }

  @Patch('rate-order')
  @UseGuards(UserAuthGuard)
  async rateOrderByUser(
    @Account() account: any,
    @Body('order') order: string,
    @Body('starsNum', ParseIntPipe) starsNum: number,
  ) {
    await this.usersOrdersService.rateBiker(account.id, order, starsNum);

    return {
      success: true,
    };
  }

  @Get('all')
  @UseGuards(UserAuthGuard)
  async getAllUserOrdersController(
    @Account() account: any,
    @Query() getOrdersDTO: GetOrdersDTO,
  ) {
    const ordersResult = await this.usersOrdersService.getAllUserOrders(
      account.id,
      getOrdersDTO,
    );
    return {
      success: true,
      totalPages: ordersResult.paginationData.totalPages,
      totalItems: ordersResult.paginationData.totalItems,
      data: ordersResult.dataList,
    };
  }

  @Get('order-details/:orderId')
  @UseGuards(UserAuthGuard)
  async getOrderByIdController(@Param('orderId') orderId: string) {
    return {
      success: true,
      data: await this.usersOrdersService.getOrderByIdPopulated(orderId),
    };
  }

  @Get('promo-code-discount')
  @UseGuards(UserAuthGuard)
  async getTotalPayAfterPromoCode(
    @Query() query: GetTotalAfterCodeDTO,
    @Account() account: any,
  ) {
    return {
      success: true,
      data: await this.usersOrdersService.getTotalPayAfterPromoCode(
        query.promoCode,
        query.totalPrice,
        account.id,
      ),
    };
  }
}
