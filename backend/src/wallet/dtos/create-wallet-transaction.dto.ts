import {
  IsEnum,
  IsMongoId,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateIf,
} from 'class-validator';
import {
  WalletPaymentMethod,
  WalletTransactionType,
} from '../schemas/wallet.schema';

export class CreateWalletTransactionDto {
  @IsNotEmpty()
  @IsEnum(WalletTransactionType)
  transactionType: WalletTransactionType;

  @IsNotEmpty()
  @IsMongoId()
  user: string;

  @ValidateIf((o) => o.transactionType === WalletTransactionType.TOP_UP)
  @IsNotEmpty()
  @IsEnum(WalletPaymentMethod)
  paymentMethod?: WalletPaymentMethod;

  @ValidateIf(
    (o) =>
      o.transactionType === WalletTransactionType.TOP_UP &&
      o.paymentMethod === WalletPaymentMethod.ADMIN,
  )
  @IsNotEmpty()
  @IsMongoId()
  paidByAdmin?: string;

  @IsNotEmpty()
  @IsNumber()
  @Min(0.01)
  amount: number;

  @IsOptional()
  @IsString()
  notes?: string;
}
