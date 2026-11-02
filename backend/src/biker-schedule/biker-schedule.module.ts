import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AdminModule } from 'src/admin/admin.module';
import { AreaModule } from 'src/area/area.module';
import {
  ordersModelName,
  OrdersSchema,
} from 'src/orders/schemas/orders.schema';
import { AdminBikerScheduleController } from './controllers/admin-biker-schedule.controller';
import { BikerBikerScheduleController } from './controllers/biker-biker-schedule.controller';
import { UserBikerScheduleController } from './controllers/user-biker-schedule.controller';
import {
  bikerScheduleModelName,
  BikerScheduleSchema,
} from './schemas/biker-schedule.schema';
import { AdminBikerScheduleService } from './services/admin-biker-schedule.service';
import { BikerBikerScheduleService } from './services/biker-biker-schedule.service';
import { UserBikerScheduleService } from './services/user-biker-schedule.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: bikerScheduleModelName, schema: BikerScheduleSchema },
      { name: ordersModelName, schema: OrdersSchema },
    ]),
    AdminModule,
    AreaModule,
  ],
  controllers: [
    AdminBikerScheduleController,
    BikerBikerScheduleController,
    UserBikerScheduleController,
  ],
  providers: [
    AdminBikerScheduleService,
    UserBikerScheduleService,
    BikerBikerScheduleService,
  ],
  exports: [AdminBikerScheduleService],
})
export class BikerScheduleModule {}
