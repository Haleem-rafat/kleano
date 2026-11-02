import { forwardRef, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { BikersModule } from 'src/bikers/bikers.module';
import { OrdersModule } from 'src/orders/orders.module';
import { OrdersRepository } from 'src/orders/repositories/orders.repository';
import {
  ordersModelName,
  OrdersSchema,
} from 'src/orders/schemas/orders.schema';
import { PromoCodeModule } from 'src/promo-code/promo-code.module';
import { SegmentsModule } from 'src/segments/segments.module';
import { FirebaseModule } from '../common/services/firebase/firebase.module';
import { PaginationModule } from '../common/services/pagination/pagination.module';
import { UserModule } from '../user/user.module';
import { NotificationsController } from './controllers/notifications.controller';
import {
  notificationsModelName,
  NotificationsSchema,
} from './schemas/notifications.schema';
import { NotificationsService } from './services/notifications.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: notificationsModelName, schema: NotificationsSchema },
      { name: ordersModelName, schema: OrdersSchema },
    ]),
    FirebaseModule,
    forwardRef(() => UserModule),
    forwardRef(() => BikersModule),
    PaginationModule,
    SegmentsModule,
    forwardRef(() => PromoCodeModule),
    forwardRef(() => OrdersModule),
  ],
  controllers: [NotificationsController],
  providers: [NotificationsService, OrdersRepository],
  exports: [NotificationsService],
})
export class NotificationsModule {}
