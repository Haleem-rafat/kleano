import { forwardRef, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { locationModelName, LocationSchema } from './schemas/location.schema';
import { CityModule } from '../city/city.module';
import { UserModule } from '../user/user.module';
import { LocationsRepository } from './repositories/locations.repository';
import { LocationsService } from './services/locations.service';
import { LocationsController } from './controllers/locations.controller';
import { AreaModule } from 'src/area/area.module';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: locationModelName, schema: LocationSchema },
    ]),
    CityModule,
    forwardRef(() => UserModule),
    AreaModule,
  ],
  providers: [LocationsRepository, LocationsService],
  controllers: [LocationsController],
  exports: [LocationsService],
})
export class LocationsModule {}
