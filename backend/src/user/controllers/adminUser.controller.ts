import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { IsAdminGuard } from 'src/admin/guard';
import { UserAuthGuard } from 'src/auth/guards';
import { Account } from 'src/common/decorators/user.decorator';
import { AdminUserService } from '../adminUser.service';
import { ListAllUsers } from '../dto/list-users.dto';

@Controller('users-admin')
export class AdminUserController {
  constructor(private adminUserService: AdminUserService) {}

  @Get()
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async listAllUsers(@Query() query: ListAllUsers) {
    const { dataList, paginationData } =
      await this.adminUserService.listAllUsers(query);
    return {
      success: true,
      data: { dataList, paginationData },
    };
  }

  @Get(':userId')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getUserById(@Param('userId') userId: string) {
    const user = await this.adminUserService.getUserById(userId);

    return {
      success: true,
      data: user,
    };
  }

  @Post(':userId/suspend')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async suspendUser(@Param('userId') userId: string) {
    await this.adminUserService.suspendUser(userId);

    return {
      success: true,
    };
  }

  @Post(':userId/unsuspend')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async unsuspendUser(@Param('userId') userId: string) {
    await this.adminUserService.unsuspendUser(userId);

    return {
      success: true,
    };
  }

  @Post(':userId/add-balance')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async addBalanceToUserWallet(
    @Account() account: any,
    @Param('userId') userId: string,
    @Body('amount') amount: number,
    @Body('notes') notes?: string,
  ) {
    await this.adminUserService.addBalanceToUserWallet(
      account.id,
      userId,
      amount,
      notes,
    );

    return {
      success: true,
    };
  }
}
