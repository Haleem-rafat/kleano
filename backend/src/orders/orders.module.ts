import { HttpModule } from '@nestjs/axios';
import { forwardRef, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ScheduleModule } from '@nestjs/schedule';
import { AddOnsModule } from 'src/add-ons/add-ons.module';
import { AdminModule } from 'src/admin/admin.module';
import { AdminService } from 'src/admin/admin.service';
import {
  bikerScheduleModelName,
  BikerScheduleSchema,
} from 'src/biker-schedule/schemas/biker-schedule.schema';
import {
  BookingAvailability,
  BookingAvailabilitySchema,
} from 'src/booking-availability/schemas/booking-availability.schema';
import { EmailService } from 'src/common/services/email.service';
import { PaymentsRepository } from 'src/payments/repositories/payments.repository';
import { PaymentsSchema } from 'src/payments/schemas/payments.schema';
import { PointsModule } from 'src/points/points.module';
import { TamaraModule } from 'src/tamara/tamara.module';
import { UserRepository } from 'src/user/user.repository';
import { AuthModule } from '../auth/auth.module';
import { BikersModule } from '../bikers/bikers.module';
import { FirebaseModule } from '../common/services/firebase/firebase.module';
import { PaginationModule } from '../common/services/pagination/pagination.module';
import { LocationsModule } from '../locations/locations.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { PlansModule } from '../plans/plans.module';
import { PromoCodeModule } from '../promo-code/promo-code.module';
import { SubscriptionsModule } from '../subscriptions/subscriptions.module';
import { UserModule } from '../user/user.module';
import { WashingServicesModule } from '../washing-services/washing-services.module';
import { AdminsOrdersController } from './controllers/adminOrders.controller';
import { BikerOrdersController } from './controllers/bikerOrders.controller';
import { UserOrdersController } from './controllers/userOrders.controller';
import { OrderGateway } from './gateway/order.gateway';
import { OrdersRepository } from './repositories/orders.repository';
import { ordersModelName, OrdersSchema } from './schemas/orders.schema';
import { AdminsOrdersService } from './services/adminOrders.service';
import { BikerOrdersService } from './services/bikerOrders.service';
import { OrdersCronService } from './services/orders-cron.service';
import { UsersOrdersService } from './services/userOrders.service';
import { OrderStatusValidator } from './validators/orderStatusValidator';
import { OrderEventListener } from './event-listeners/order-event.listener';
import { TabbyModule } from 'src/tabby/tabby.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: ordersModelName, schema: OrdersSchema },
      { name: BookingAvailability.name, schema: BookingAvailabilitySchema },
      { name: 'payments', schema: PaymentsSchema },
      { name: bikerScheduleModelName, schema: BikerScheduleSchema },
    ]),
    ScheduleModule.forRoot(),
    forwardRef(() => UserModule),
    HttpModule,
    FirebaseModule,
    LocationsModule,
    WashingServicesModule,
    forwardRef(() => SubscriptionsModule),
    PlansModule,
    PromoCodeModule,
    PaginationModule,
    forwardRef(() => AuthModule),
    forwardRef(() => BikersModule),
    NotificationsModule,
    AdminModule,
    PointsModule,
    forwardRef(() => AddOnsModule),
    TamaraModule,
    forwardRef(() => TabbyModule),
  ],
  providers: [
    OrdersRepository,
    PaymentsRepository,
    UsersOrdersService,
    OrderStatusValidator,
    OrderGateway,
    BikerOrdersService,
    AdminsOrdersService,
    AdminService,
    OrdersCronService,
    EmailService,
    UserRepository,
    OrderEventListener,
  ],
  controllers: [
    UserOrdersController,
    BikerOrdersController,
    AdminsOrdersController,
  ],
  exports: [UsersOrdersService, AdminsOrdersService, OrdersRepository],
})
export class OrdersModule {}
