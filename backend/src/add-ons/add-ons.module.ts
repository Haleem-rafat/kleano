import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AreaModule } from 'src/area/area.module';
import { AdminModule } from '../admin/admin.module';
import { CityModule } from '../city/city.module';
import { ServicesIconsModule } from '../services-icons/services-icons.module';
import { UserModule } from '../user/user.module';
import { AddOnsController } from './controllers/add-ons.controller';
import { AddOnsCitiesRepository } from './repositories/add-ons-cities.repository';
import { AddOnsRepository } from './repositories/add-ons.repository';
import {
  addOnsCitiesModelName,
  AddOnsCitiesSchema,
} from './schemas/add-ons-cities.schema';
import { addOnsModelName, AddOnsSchema } from './schemas/add-ons.schema';
import { AddOnsService } from './services/add-ons.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: addOnsModelName, schema: AddOnsSchema },
      { name: addOnsCitiesModelName, schema: AddOnsCitiesSchema },
    ]),
    AdminModule,
    CityModule,
    AreaModule,
    ServicesIconsModule,
    UserModule,
  ],
  providers: [AddOnsService, AddOnsRepository, AddOnsCitiesRepository],
  controllers: [AddOnsController],
  exports: [AddOnsService, AddOnsRepository, MongooseModule],
})
export class AddOnsModule {}
