import { Module, forwardRef } from '@nestjs/common';
import { BikersService } from './services/bikers.service';
import { BikersController } from './controllers/bikers.controller';
import { UserModule } from '../user/user.module';
import { BikerCrudValidator } from './services/bikersCrud.validator';
import { FirebaseModule } from '../common/services/firebase/firebase.module';
import { BikersRepository } from './repositories/bikers.repository';
import { bikerModelName, BikersSchema } from './schemas/bikers.schema';
import { MongooseModule } from '@nestjs/mongoose';
import { AdminModule } from '../admin/admin.module';
import { BikerGateway } from './gateway/biker.gateway';
import { OrdersModule } from '../orders/orders.module';
import { AuthModule } from '../auth/auth.module';
import { AreaModule } from 'src/area/area.module';

@Module({
  imports: [
    MongooseModule.forFeature([{ name: bikerModelName, schema: BikersSchema }]),
    forwardRef(() => UserModule),
    FirebaseModule,
    AdminModule,
    OrdersModule,
    AreaModule,
    forwardRef(() => AuthModule),
  ],
  providers: [
    BikersService,
    BikerCrudValidator,
    BikersRepository,
    BikerGateway,
  ],
  controllers: [BikersController],
  exports: [BikersService],
})
export class BikersModule {}
