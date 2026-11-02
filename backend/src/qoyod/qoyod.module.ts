import { HttpModule } from '@nestjs/axios';
import { Module } from '@nestjs/common';
import { AddOnsModule } from 'src/add-ons/add-ons.module';
import { EmailService } from 'src/common/services/email.service';
import { OrdersModule } from 'src/orders/orders.module';
import { PlansModule } from 'src/plans/plans.module';
import { UserModule } from 'src/user/user.module';
import { WashingServicesModule } from 'src/washing-services/washing-services.module';
import { CustomersQoyodController } from './controllers/customers-qoyod.controller';
import { ProductsQoyodController } from './controllers/products-qoyod.controller';
import { QoyodController } from './controllers/qoyod.controller';
import { CustomersQoyodService } from './services/customers-qoyod.service';
import { InvoicesQoyodService } from './services/invoices-qoyod.service';
import { ProductsQoyodService } from './services/products-qoyod.service';

@Module({
  imports: [
    HttpModule,
    UserModule,
    AddOnsModule,
    WashingServicesModule,
    PlansModule,
    OrdersModule,
  ],
  controllers: [
    QoyodController,
    CustomersQoyodController,
    ProductsQoyodController,
  ],
  providers: [
    InvoicesQoyodService,
    CustomersQoyodService,
    ProductsQoyodService,
    EmailService,
  ],
  exports: [InvoicesQoyodService, CustomersQoyodService, ProductsQoyodService],
})
export class QoyodModule {}
