import { Module } from '@nestjs/common';
import { EventEmitterModule } from '@nestjs/event-emitter';
import { MongooseModule } from '@nestjs/mongoose';
import { ScheduleModule } from '@nestjs/schedule';
import { AddOnsModule } from './add-ons/add-ons.module';
import { AdminModule } from './admin/admin.module';
import { AreaModule } from './area/area.module';
import { AuthModule } from './auth/auth.module';
import { BannersModule } from './banners/banners.module';
import { BikerScheduleModule } from './biker-schedule/biker-schedule.module';
import { BikersModule } from './bikers/bikers.module';
import { BookingAvailabilityModule } from './booking-availability/booking-availability.module';
import { CarModule } from './car/car.module';
import { CityModule } from './city/city.module';
import { PaginationModule } from './common/services/pagination/pagination.module';
import { ContactInfoModule } from './contact-info/contact-info.module';
import { HealthController } from './health/health.controller';
import { LocationsModule } from './locations/locations.module';
import { OrdersModule } from './orders/orders.module';
import { PaymentsModule } from './payments/payments.module';
import { PlansModule } from './plans/plans.module';
import { PointsModule } from './points/points.module';
import { PromoCodeModule } from './promo-code/promo-code.module';
import { QoyodModule } from './qoyod/qoyod.module';
import { SegmentsModule } from './segments/segments.module';
import { ServicesIconsModule } from './services-icons/services-icons.module';
import { SubscriptionsModule } from './subscriptions/subscriptions.module';
import { TamaraModule } from './tamara/tamara.module';
import { TabbyModule } from './tabby/tabby.module';
import { TermsModule } from './terms-conditions/terms.module';
import { UserModule } from './user/user.module';
import { VehiclesModule } from './vehicles/vehicles.module';
import { WalletModule } from './wallet/wallet.module';
import { WashingServicesModule } from './washing-services/washing-services.module';

@Module({
  imports: [
    MongooseModule.forRoot(process.env.DB),
    ScheduleModule.forRoot(),
    EventEmitterModule.forRoot(),
    UserModule,
    AuthModule,
    AdminModule,
    CityModule,
    AreaModule,
    VehiclesModule,
    BikersModule,
    WashingServicesModule,
    ServicesIconsModule,
    PlansModule,
    LocationsModule,
    SubscriptionsModule,
    AddOnsModule,
    OrdersModule,
    PromoCodeModule,
    PaginationModule,
    PointsModule,
    SegmentsModule,
    CarModule,
    TermsModule,
    BannersModule,
    ContactInfoModule,
    BookingAvailabilityModule,
    PaymentsModule,
    BikerScheduleModule,
    QoyodModule,
    TamaraModule,
    TabbyModule,
    WalletModule,
  ],
  controllers: [HealthController],
  providers: [],
})
export class AppModule {}
