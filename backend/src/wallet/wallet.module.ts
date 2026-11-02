import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PaginationModule } from '../common/services/pagination/pagination.module';
import { WalletSchema, walletModelName } from './schemas/wallet.schema';
import { WalletController } from './wallet.controller';
import { WalletRepository } from './wallet.repository';
import { WalletService } from './wallet.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: walletModelName, schema: WalletSchema },
    ]),
    PaginationModule,
  ],
  controllers: [WalletController],
  providers: [WalletService, WalletRepository],
  exports: [WalletService, WalletRepository],
})
export class WalletModule {}
