import { IsEnum, IsOptional, IsString } from 'class-validator';
import { WalletTransactionType } from '../schemas/wallet.schema';

export class GetWalletTransactionsDto {
  @IsOptional()
  @IsString()
  page?: string;

  @IsOptional()
  @IsString()
  limit?: string;

  @IsOptional()
  @IsEnum(WalletTransactionType)
  transactionType?: WalletTransactionType;
}
