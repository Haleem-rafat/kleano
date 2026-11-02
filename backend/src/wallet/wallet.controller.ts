import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { IsAdminGuard } from '../admin/guard';
import { UserAuthGuard } from '../auth/guards';
import { Account } from '../common/decorators/user.decorator';
import { CreateWalletTransactionDto, GetWalletTransactionsDto } from './dtos';
import { WalletService } from './wallet.service';

@Controller('wallet')
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  @Post()
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async createTransaction(
    @Body() createWalletTransactionDto: CreateWalletTransactionDto,
  ) {
    return {
      success: true,
      data: await this.walletService.createTransaction(
        createWalletTransactionDto,
      ),
    };
  }

  @Get('user/:userId')
  @UseGuards(UserAuthGuard)
  async getUserTransactions(
    @Param('userId') userId: string,
    @Query() getWalletTransactionsDto: GetWalletTransactionsDto,
    @Account() account: any,
  ) {
    // Users can only view their own transactions unless they're an admin
    if (account.id !== userId && !account.role) {
      throw new Error('Unauthorized');
    }

    return {
      success: true,
      data: await this.walletService.getUserTransactions(
        userId,
        getWalletTransactionsDto,
      ),
    };
  }

  @Get('balance/:userId')
  @UseGuards(UserAuthGuard)
  async getUserBalance(
    @Param('userId') userId: string,
    @Account() account: any,
  ) {
    // Users can only view their own balance unless they're an admin
    if (account.id !== userId && !account.role) {
      throw new Error('Unauthorized');
    }

    return {
      success: true,
      balance: await this.walletService.getUserBalance(userId),
    };
  }

  @Get('admin/all')
  @UseGuards(UserAuthGuard, IsAdminGuard)
  async getAllTransactions(
    @Query() getWalletTransactionsDto: GetWalletTransactionsDto,
  ) {
    const walletPagination = await this.walletService.getAllTransactions(
      getWalletTransactionsDto,
    );
    return {
      success: true,
      pagination: walletPagination.paginationData,
      data: walletPagination.dataList,
    };
  }

  @Get(':id')
  @UseGuards(UserAuthGuard)
  async getTransactionById(@Param('id') id: string) {
    return {
      success: true,
      data: await this.walletService.getTransactionById(id),
    };
  }
}
