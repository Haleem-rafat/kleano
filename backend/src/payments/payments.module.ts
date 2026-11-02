import { HttpModule } from '@nestjs/axios';
import { forwardRef, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AddOnsModule } from 'src/add-ons/add-ons.module';
import { AdminModule } from 'src/admin/admin.module';
import { AdminService } from 'src/admin/admin.service';
import { AuthModule } from 'src/auth/auth.module';
import {
  bikerScheduleModelName,
  BikerScheduleSchema,
} from 'src/biker-schedule/schemas/biker-schedule.schema';
import { BikersModule } from 'src/bikers/bikers.module';
import { EmailService } from 'src/common/services/email.service';
import { FirebaseModule } from 'src/common/services/firebase/firebase.module';
import { PaginationModule } from 'src/common/services/pagination/pagination.module';
import { LocationsModule } from 'src/locations/locations.module';
import { NotificationsModule } from 'src/notifications/notifications.module';
import { OrderGateway } from 'src/orders/gateway/order.gateway';
import { OrdersRepository } from 'src/orders/repositories/orders.repository';
import {
  ordersModelName,
  OrdersSchema,
} from 'src/orders/schemas/orders.schema';
import { AdminsOrdersService } from 'src/orders/services/adminOrders.service';
import { BikerOrdersService } from 'src/orders/services/bikerOrders.service';
import { UsersOrdersService } from 'src/orders/services/userOrders.service';
import { OrderStatusValidator } from 'src/orders/validators/orderStatusValidator';
import { PlansModule } from 'src/plans/plans.module';
import { PointsModule } from 'src/points/points.module';
import { PromoCodeModule } from 'src/promo-code/promo-code.module';
import { SubscriptionsModule } from 'src/subscriptions/subscriptions.module';
import { TamaraModule } from 'src/tamara/tamara.module';
import { UserModule } from 'src/user/user.module';
import { UserRepository } from 'src/user/user.repository';
import { WashingServicesModule } from 'src/washing-services/washing-services.module';
import { AdminsPaymentsController } from './controllers/adminPayments.controller';
import { UserPaymentsController } from './controllers/userPayments.controller';
import { PaymentsController } from './payment.controller';
import { PaymentService } from './payment.service';
import { PaymentsRepository } from './repositories/payments.repository';
import { PaymentsSchema } from './schemas/payments.schema';
import { AdminsPaymentsService } from './services/adminPayments.service';
import { UsersPaymentsService } from './services/userPayments.service';
import { TabbyModule } from 'src/tabby/tabby.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: 'payments', schema: PaymentsSchema },
      { name: ordersModelName, schema: OrdersSchema },
      { name: bikerScheduleModelName, schema: BikerScheduleSchema },
    ]),
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
    forwardRef(() => TamaraModule),
    forwardRef(() => TabbyModule),
  ],
  providers: [
    PaymentsRepository,
    OrdersRepository,
    UsersOrdersService,
    PaymentService,
    OrderStatusValidator,
    OrderGateway,
    BikerOrdersService,
    AdminsOrdersService,
    AdminService,
    AdminsPaymentsService,
    UsersPaymentsService,
    EmailService,
    UserRepository,
  ],
  controllers: [
    PaymentsController,
    UserPaymentsController,
    AdminsPaymentsController,
  ],
  exports: [
    PaymentService,
    UsersPaymentsService,
    AdminsPaymentsService,
    MongooseModule,
    PaymentsRepository,
    UsersOrdersService,
  ],
})
export class PaymentsModule {}
