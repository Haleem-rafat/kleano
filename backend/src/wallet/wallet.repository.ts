import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { adminModelName } from '../admin/schemas/admin.schema';
import { NotFoundResponse } from '../common/errors/NotFoundResponse';
import { userModelName } from '../user/schemas/user.schema';
import { CreateWalletTransactionDto } from './dtos';
import {
  Wallet,
  WalletModel,
  walletModelName,
  WalletTransactionType,
} from './schemas/wallet.schema';

@Injectable()
export class WalletRepository {
  populatedPaths = [
    { path: 'user', model: userModelName, select: 'userName phone' },
    { path: 'paidByAdmin', model: adminModelName, select: 'userName' },
  ];

  constructor(
    @InjectModel(walletModelName)
    private readonly walletModel: Model<WalletModel>,
  ) {}

  async create(
    createWalletTransactionDto: CreateWalletTransactionDto,
  ): Promise<Wallet> {
    const transaction = await this.walletModel.create(
      createWalletTransactionDto,
    );
    return transaction;
  }

  async findById(id: string): Promise<Wallet | null> {
    const transaction = await this.walletModel
      .findById(id)
      .populate(this.populatedPaths);

    if (!transaction) {
      throw new NotFoundResponse({
        ar: 'العملية غير موجودة',
        en: 'Transaction not found',
      });
    }

    return transaction;
  }

  async findByUser(
    userId: string,
    page = 1,
    limit = 10,
    transactionType?: WalletTransactionType,
  ): Promise<{ transactions: Wallet[]; total: number }> {
    const skip = (page - 1) * limit;
    const query: any = { user: userId };

    if (transactionType) {
      query.transactionType = transactionType;
    }

    const [transactions, total] = await Promise.all([
      this.walletModel
        .find(query)
        .populate(this.populatedPaths)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      this.walletModel.countDocuments(query),
    ]);

    return { transactions, total };
  }

  async getUserWalletBalance(userId: string): Promise<number> {
    const result = await this.walletModel.aggregate([
      { $match: { user: userId } },
      {
        $group: {
          _id: '$transactionType',
          total: { $sum: '$amount' },
        },
      },
    ]);

    let topUpTotal = 0;
    let payTotal = 0;

    result.forEach((item) => {
      if (item._id === WalletTransactionType.TOP_UP) {
        topUpTotal = item.total;
      } else if (item._id === WalletTransactionType.PAY) {
        payTotal = item.total;
      }
    });

    return topUpTotal - payTotal;
  }

  async findAll(
    page = 1,
    limit = 10,
    transactionType?: WalletTransactionType,
  ): Promise<{ transactions: Wallet[]; total: number }> {
    const skip = (page - 1) * limit;
    const query: any = {};

    if (transactionType) {
      query.transactionType = transactionType;
    }

    const [transactions, total] = await Promise.all([
      this.walletModel
        .find(query)
        .populate(this.populatedPaths)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean(),
      this.walletModel.countDocuments(query),
    ]);

    return { transactions, total };
  }
}
