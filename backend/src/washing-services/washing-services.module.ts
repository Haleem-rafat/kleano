import { forwardRef, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AreaModule } from 'src/area/area.module';
import { BikersRepository } from 'src/bikers/repositories/bikers.repository';
import { bikerModelName, BikersSchema } from 'src/bikers/schemas/bikers.schema';
import { BikersService } from 'src/bikers/services/bikers.service';
import { BikerCrudValidator } from 'src/bikers/services/bikersCrud.validator';
import { FirebaseService } from 'src/common/services/firebase/firebase.service';
import { SubscriptionsModule } from 'src/subscriptions/subscriptions.module';
import { AdminModule } from '../admin/admin.module';
import { CityModule } from '../city/city.module';
import { ServicesIconsModule } from '../services-icons/services-icons.module';
import { UserModule } from '../user/user.module';
import { WashingServicesController } from './controllers/washing-services.controller';
import { ServicesCitiesRepository } from './repositories/services-cities.repository';
import { WashingServicesRepository } from './repositories/washing-services.repository';
import {
  ServicesCitiesModelName,
  ServicesCitiesSchema,
} from './schemas/services-cities.schema';
import {
  WashingServicesModelName,
  WashingServicesSchema,
} from './schemas/washing-services.schema';
import { WashingServicesService } from './services/washing-services.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: WashingServicesModelName, schema: WashingServicesSchema },
      { name: ServicesCitiesModelName, schema: ServicesCitiesSchema },
      { name: bikerModelName, schema: BikersSchema },
    ]),
    ServicesIconsModule,
    CityModule,
    AreaModule,
    forwardRef(() => UserModule),
    AdminModule,
    forwardRef(() => SubscriptionsModule),
  ],
  providers: [
    WashingServicesService,
    WashingServicesRepository,
    ServicesCitiesRepository,
    BikersService,
    BikersRepository,
    BikerCrudValidator,
    FirebaseService,
  ],
  controllers: [WashingServicesController],
  exports: [WashingServicesService, WashingServicesRepository],
})
export class WashingServicesModule {}
