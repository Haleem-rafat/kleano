import { HttpModule } from '@nestjs/axios';
import { forwardRef, Module } from '@nestjs/common';
import { AddOnsModule } from 'src/add-ons/add-ons.module';
import { PaymentsModule } from 'src/payments/payments.module';
import { PointsModule } from 'src/points/points.module';
import { PromoCodeModule } from 'src/promo-code/promo-code.module';
import { UserModule } from 'src/user/user.module';
import { TabbyService } from '../common/services/tabby.service';

@Module({
  imports: [
    HttpModule,
    forwardRef(() => AddOnsModule),
    forwardRef(() => UserModule),
    PromoCodeModule,
    PointsModule,
    forwardRef(() => PaymentsModule),
  ],
  providers: [TabbyService],
  exports: [TabbyService],
})
export class TabbyModule {}
