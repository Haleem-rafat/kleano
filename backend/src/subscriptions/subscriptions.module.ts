import { Module, forwardRef } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { SubscriptionsRepository } from './repositories/subscriptions.repository';
import { SubscriptionsService } from './services/subscriptions.service';
import { SubscriptionsController } from './controllers/subscriptions.controller';
import { PlansModule } from '../plans/plans.module';
import { UserModule } from '../user/user.module';
import { CityModule } from '../city/city.module';
import {
  subscriptionsModelName,
  SubscriptionsSchema,
} from './schemas/subscriptions.schema';
import { PointsModule } from 'src/points/points.module';
import { HttpModule } from '@nestjs/axios';
import { TabbyModule } from 'src/tabby/tabby.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: subscriptionsModelName, schema: SubscriptionsSchema },
    ]),
    forwardRef(() => UserModule),
    forwardRef(() => PlansModule),
    CityModule,
    PointsModule,
    HttpModule,
    forwardRef(() => TabbyModule),
  ],
  providers: [SubscriptionsRepository, SubscriptionsService],
  controllers: [SubscriptionsController],
  exports: [SubscriptionsService],
})
export class SubscriptionsModule {}
