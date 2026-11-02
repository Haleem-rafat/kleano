import { BadRequestException, Injectable } from '@nestjs/common';
import { OnEvent } from '@nestjs/event-emitter';
import { PaginationService } from '../common/services/pagination/pagination.service';
import { CreateWalletTransactionDto, GetWalletTransactionsDto } from './dtos';
import {
  Wallet,
  WalletPaymentMethod,
  WalletTransactionType,
} from './schemas/wallet.schema';
import { WalletRepository } from './wallet.repository';

@Injectable()
export class WalletService {
  constructor(
    private readonly walletRepository: WalletRepository,
    private readonly paginationService: PaginationService,
  ) {}

  async createTransaction(
    createWalletTransactionDto: CreateWalletTransactionDto,
  ): Promise<Wallet> {
    // Validate that TOP_UP transactions have a payment method
    if (
      createWalletTransactionDto.transactionType ===
      WalletTransactionType.TOP_UP
    ) {
      if (!createWalletTransactionDto.paymentMethod) {
        throw new BadRequestException({
          success: false,
          message: {
            ar: 'طريقة الدفع مطلوبة لعمليات الشحن',
            en: 'Payment method is required for top-up transactions',
          },
        });
      }

      // Validate that ADMIN payment method has paidByAdmin
      if (
        createWalletTransactionDto.paymentMethod ===
          WalletPaymentMethod.ADMIN &&
        !createWalletTransactionDto.paidByAdmin
      ) {
        throw new BadRequestException({
          success: false,
          message: {
            ar: 'يجب تحديد المسؤول عند الدفع من قبل المسؤول',
            en: 'Admin must be specified when payment method is ADMIN',
          },
        });
      }
    }

    const transaction = await this.walletRepository.create(
      createWalletTransactionDto,
    );

    return transaction;
  }

  async getUserTransactions(
    userId: string,
    getWalletTransactionsDto: GetWalletTransactionsDto,
  ): Promise<{ transactions: Wallet[]; total: number; balance: number }> {
    const page = parseInt(getWalletTransactionsDto.page || '1', 10);
    const limit = parseInt(getWalletTransactionsDto.limit || '10', 10);

    const { transactions, total } = await this.walletRepository.findByUser(
      userId,
      page,
      limit,
      getWalletTransactionsDto.transactionType,
    );

    const balance = await this.walletRepository.getUserWalletBalance(userId);

    return { transactions, total, balance };
  }

  async getUserBalance(userId: string): Promise<number> {
    return this.walletRepository.getUserWalletBalance(userId);
  }

  async getAllTransactions(getWalletTransactionsDto: GetWalletTransactionsDto) {
    const page = parseInt(getWalletTransactionsDto.page || '1', 10);
    const limit = parseInt(getWalletTransactionsDto.limit || '10', 10);

    const { transactions, total } = await this.walletRepository.findAll(
      page,
      limit,
      getWalletTransactionsDto.transactionType,
    );

    return this.paginationService.paginate(transactions, total, page, limit);
  }

  async getTransactionById(id: string): Promise<Wallet> {
    return this.walletRepository.findById(id);
  }

  @OnEvent('admin.wallet.topup')
  async handleAdminWalletTopup(payload: {
    adminId: string;
    userId: string;
    amount: number;
    notes?: string;
  }) {
    const { adminId, userId, amount, notes } = payload;

    await this.createTransaction({
      transactionType: WalletTransactionType.TOP_UP,
      user: userId,
      paymentMethod: WalletPaymentMethod.ADMIN,
      paidByAdmin: adminId,
      amount: amount,
      notes: notes,
    });
  }
}
