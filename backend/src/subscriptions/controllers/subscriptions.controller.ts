import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { SubscriptionsService } from '../services/subscriptions.service';
import { UserAuthGuard } from '../../auth/guards/userAuthentication.guard';
import { Account } from 'src/common/decorators/user.decorator';
import { GetSubscriptionByLocationDTO } from '../dtos/subscriptionByLocation.dto';
import { GetSubscriptionsDTO } from '../dtos/getSubscriptions.dto';

@Controller('subscriptions')
export class SubscriptionsController {
  constructor(private subscriptionsService: SubscriptionsService) {}

  @Post()
  @UseGuards(UserAuthGuard)
  async createSubscriptionsController(
    @Body('plan') plan: string,
    @Body('paymentType') paymentType: string,
    @Account() account: any,
  ) {
    return {
      success: true,
      data: await this.subscriptionsService.createUserSubscription(
        account.id,
        plan,
        paymentType,
      ),
    };
  }

  @Delete()
  @UseGuards(UserAuthGuard)
  async unsubscribeUserController(@Account() account: any) {
    await this.subscriptionsService.unsubscribeUser(account.id);

    return {
      success: true,
      message: {
        ar: 'تم إلغاء الاشتراك بنجاح.',
        en: 'Subscription cancelled successfully.',
      },
    };
  }

  @Get('/user')
  @UseGuards(UserAuthGuard)
  async getUserSubscriptionsController(
    @Account() account: any,
    @Query() getSubscriptionsDTO?: GetSubscriptionsDTO,
  ) {
    const subscription =
      await this.subscriptionsService.getUserSubscriptionWithStatusFilter(
        account.id,
        getSubscriptionsDTO,
      );
    return {
      success: true,
      data: subscription ? subscription : {},
    };
  }

  @Get('/user/location')
  @UseGuards(UserAuthGuard)
  async getUserSubscriptionsByLocationController(
    @Account() account: any,
    @Query() getSubscriptionByLocationDTO: GetSubscriptionByLocationDTO,
  ) {
    const result =
      await this.subscriptionsService.getUserSubscriptionByLocation(
        account.id,
        getSubscriptionByLocationDTO,
      );
    return {
      success: true,
      message: result.message,
      data: result.subscription,
    };
  }

  @Post('/user/:planId')
  @UseGuards(UserAuthGuard)
  async cancelUserSubscription(
    @Account() account: any,
    @Param('planId') planId: string,
  ) {
    await this.subscriptionsService.cancelUserSubscription(account.id, planId);

    return {
      success: true,
      message: 'Subscription cancelled Successfully',
    };
  }

  @Patch('/user/pay-subscription')
  @UseGuards(UserAuthGuard)
  async setSubscriptionActiveController(
    @Account() account: any,
    @Body('subscription') subscription: string,
    @Body('paymentDetails')
    paymentDetails?: {
      name: string;
      number: string;
      cvc: string;
      month: string;
      year: string;
    }, // Optional
  ) {
    const result = await this.subscriptionsService.paySubscription(
      account.id,
      subscription,
      paymentDetails,
    );

    return {
      success: true,
      result,
    };
  }
}
