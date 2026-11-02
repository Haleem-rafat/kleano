import { HttpModule } from '@nestjs/axios';
import { forwardRef, Module } from '@nestjs/common';
import { AddOnsModule } from 'src/add-ons/add-ons.module';
import { PaymentsModule } from 'src/payments/payments.module';
import { PointsModule } from 'src/points/points.module';
import { PromoCodeModule } from 'src/promo-code/promo-code.module';
import { UserModule } from 'src/user/user.module';
import { TamaraController } from './controllers/tamara.controller';
import { TamaraService } from './services/tamara.service';

@Module({
  imports: [
    HttpModule,
    forwardRef(() => AddOnsModule),
    forwardRef(() => UserModule),
    PromoCodeModule,
    PointsModule,
    forwardRef(() => PaymentsModule),
  ],
  controllers: [TamaraController],
  providers: [TamaraService],
  exports: [TamaraService],
})
export class TamaraModule {}
