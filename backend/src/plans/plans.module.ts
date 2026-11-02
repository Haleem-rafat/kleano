import { Module, forwardRef } from '@nestjs/common';
import { PlansService } from './services/plans.service';
import { MongooseModule } from '@nestjs/mongoose';
import { plansModelName, PlansSchema } from './schemas/plans.schema';
import { PlansController } from './controllers/plans.controller';
import { PlansRepository } from './repositories/plans.repoistory';
import { PlansCitiesRepository } from './repositories/plans-cities.repository';
import { CityModule } from '../city/city.module';
import { UserModule } from '../user/user.module';
import { AdminModule } from '../admin/admin.module';
import { SubscriptionsModule } from '../subscriptions/subscriptions.module';
import {
  plansCitiesModelName,
  PlansCitiesSchema,
} from './schemas/plans-cities.schema';
import { AreaModule } from 'src/area/area.module';
import { bikerModelName, BikersSchema } from 'src/bikers/schemas/bikers.schema';
import { BikersService } from 'src/bikers/services/bikers.service';
import { BikersRepository } from 'src/bikers/repositories/bikers.repository';
import { BikerCrudValidator } from 'src/bikers/services/bikersCrud.validator';
import { FirebaseService } from 'src/common/services/firebase/firebase.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: plansModelName, schema: PlansSchema },
      { name: plansCitiesModelName, schema: PlansCitiesSchema },
      { name: bikerModelName, schema: BikersSchema },
    ]),
    CityModule,
    AreaModule,
    forwardRef(() => UserModule),
    forwardRef(() => SubscriptionsModule),
    AdminModule,
  ],
  providers: [
    PlansService,
    PlansRepository,
    PlansCitiesRepository,
    BikersRepository,
    BikerCrudValidator,
    FirebaseService,
  ],
  controllers: [PlansController],
  exports: [PlansService, PlansRepository],
})
export class PlansModule {}
