import { forwardRef, Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { PaginationModule } from 'src/common/services/pagination/pagination.module';
import { NotificationsModule } from 'src/notifications/notifications.module';
import {
  ordersModelName,
  OrdersSchema,
} from 'src/orders/schemas/orders.schema';
import {
  segmentModelName,
  SegmentSchema,
} from 'src/segments/schemas/segment.schema';
import { userModelName, UserSchema } from 'src/user/schemas/user.schema';
import { PromoCodesController } from './controllers/promo-codes.controller';
import { ActivePromoCodesRepository } from './repositories/active-promo-codes.repository';
import { AppliedPromoCodesRepository } from './repositories/applied-promo-codes.repository';
import { PromoCodesRepository } from './repositories/promo-code.repository';
import {
  activePromoCodesModelName,
  ActivePromoCodesSchema,
} from './schemas/active-promo-codes.schema';
import {
  aggregatorPromoCodeModelName,
  AggregatorPromoCodeSchema,
} from './schemas/aggregator-promo-code.schema';
import {
  allUsersPromoCodeModelName,
  AllUsersPromoCodeSchema,
} from './schemas/all-users-promo-code.schema';
import {
  appliedPromoCodeModelName,
  AppliedPromoCodeSchema,
} from './schemas/applied-promo-codes.schema';
import {
  b2bPromoCodeModelName,
  B2bPromoCodeSchema,
} from './schemas/b2b-promo-code.schema';
import {
  newComersPromoCodeModelName,
  NewComersPromoCodeSchema,
} from './schemas/new-comers-promo-code.schema';
import {
  offlinePromoCodeModelName,
  OfflinePromoCodeSchema,
} from './schemas/offline-promo-code.schema';
import {
  promoCodeModelName,
  PromoCodeSchema,
  PromoCodeTargetAudienceEnum,
} from './schemas/promo-code.schema';
import {
  segmentPromoCodeModelName,
  SegmentPromoCodeSchema,
} from './schemas/segment-promo-code.schema';
import { PromoCodesService } from './services/promo-code.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      {
        name: promoCodeModelName,
        schema: PromoCodeSchema,
        discriminators: [
          {
            name: newComersPromoCodeModelName,
            schema: NewComersPromoCodeSchema,
            value: PromoCodeTargetAudienceEnum.NEW_COMERS,
          },
          {
            name: allUsersPromoCodeModelName,
            schema: AllUsersPromoCodeSchema,
            value: PromoCodeTargetAudienceEnum.ALL_USERS,
          },
          {
            name: aggregatorPromoCodeModelName,
            schema: AggregatorPromoCodeSchema,
            value: PromoCodeTargetAudienceEnum.AGGREGATOR,
          },
          {
            name: segmentPromoCodeModelName,
            schema: SegmentPromoCodeSchema,
            value: PromoCodeTargetAudienceEnum.SEGMENT,
          },
          {
            name: offlinePromoCodeModelName,
            schema: OfflinePromoCodeSchema,
            value: PromoCodeTargetAudienceEnum.OFFLINE,
          },
          {
            name: b2bPromoCodeModelName,
            schema: B2bPromoCodeSchema,
            value: PromoCodeTargetAudienceEnum.B2B,
          },
        ],
      },
      { name: appliedPromoCodeModelName, schema: AppliedPromoCodeSchema },
      { name: activePromoCodesModelName, schema: ActivePromoCodesSchema },
    ]),
    forwardRef(() => NotificationsModule),
    PaginationModule,
    MongooseModule.forFeature([
      { name: userModelName, schema: UserSchema },
      { name: segmentModelName, schema: SegmentSchema },
      { name: ordersModelName, schema: OrdersSchema },
    ]),
  ],
  controllers: [PromoCodesController],
  providers: [
    PromoCodesService,
    PromoCodesRepository,
    AppliedPromoCodesRepository,
    ActivePromoCodesRepository,
  ],
  exports: [PromoCodesService],
})
export class PromoCodeModule {}
