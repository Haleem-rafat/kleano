import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/screens/wash_details.dart';
import 'package:thewasher/modules/my_booking/widgets/button_tracking.dart';
import 'package:thewasher/modules/my_booking/widgets/vechilce_details.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/utilties/app_date_formatter.dart';
import 'package:thewasher/utilties/navigator.dart';

class MyBookingCard extends StatelessWidget {
  final OrderModel order;
  final bool isActive;
  const MyBookingCard({super.key, required this.order, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    final bool canTrack =
        isActive && order.status == AppConstants.bikerOnTheWay;
    final String paymentType = order.paymentType ?? '';
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (order.vehicle != null) ...<Widget>[
            _VehicleSummary(
              vehicle: order.vehicle!,
              bookingDate: order.createdAt != null
                  ? DateTime.parse(order.createdAt!).toLocal()
                  : DateTime.now(),
              washingDate: order.startTime != null
                  ? DateTime.parse(order.startTime!).toLocal()
                  : null,
            ),
            const SizedBox(height: KSpace.m),
          ],
          Wrap(
            spacing: KSpace.s,
            runSpacing: KSpace.xs,
            children: <Widget>[
              KStatusChip(
                label: statusText(order.status ?? ''),
                status: statusKind(order.status ?? ''),
              ),
              if (paymentType.isNotEmpty)
                KStatusChip(
                  label: paymentTypeText(paymentType),
                  status: KStatus.neutral,
                ),
            ],
          ),
          const SizedBox(height: KSpace.m),
          if (canTrack) ...<Widget>[
            ButtonTrackingOrder(orderModel: order),
            const SizedBox(height: KSpace.xs),
          ],
          KButton(
            label: translate(AppStrings.viewDetails),
            variant: canTrack ? KButtonVariant.text : KButtonVariant.secondary,
            onPressed: () {
              if (order.sId != null) {
                pushPage(context, WashDetailsScreen(orderId: order.sId!));
              }
            },
          ),
        ],
      ),
    );
  }

  /// Which colour a booking status shows in, per the design system's status
  /// chip: pending and in progress are warning, accepted and new are brand.
  static KStatus statusKind(String status) {
    switch (status) {
      case 'COMPLETED':
        return KStatus.success;
      case 'ACTIVE':
      case 'ACCEPTED_BY_BIKER':
        return KStatus.brand;
      case 'PENDING_USER_PAYMENT':
      case 'PENDING_USER_REVIEW':
      case 'WAITING_FOR_BIKER_BY_ADMIN':
      case 'ORDER_WAITING_FOR_ADMIN':
      case 'BIKER_ON_THE_WAY':
      case 'BIKER_ARRIVED':
      case 'ON_WASHING':
        return KStatus.warning;
      case 'CANCELLED_BY_USER':
      case 'CANCELLED_BY_ADMIN':
      case 'CANCELLED_BY_BIKER':
        return KStatus.error;
      default:
        return KStatus.neutral;
    }
  }

  static String statusText(String status) {
    switch (status) {
      case 'PENDING_USER_PAYMENT':
        return translate(AppStrings.pendingPayment);
      case 'PENDING_USER_REVIEW':
        return translate(AppStrings.pendingReview);
      case 'ACTIVE':
        return translate(AppStrings.active);
      case 'CANCELLED_BY_USER':
        return translate(AppStrings.cancelledByUser);
      case 'CANCELLED_BY_ADMIN':
        return translate(AppStrings.cancelledByAdmin);
      case 'ACCEPTED_BY_BIKER':
        return translate(AppStrings.accepted);
      case 'WAITING_FOR_BIKER_BY_ADMIN':
        return translate(AppStrings.waitingForBiker);
      case 'BIKER_ON_THE_WAY':
        return translate(AppStrings.onTheWay);
      case 'CANCELLED_BY_BIKER':
        return translate(AppStrings.cancelledByBiker);
      case 'BIKER_ARRIVED':
        return translate(AppStrings.arrived);
      case 'ON_WASHING':
        return translate(AppStrings.inProgress);
      case 'COMPLETED':
        return translate(AppStrings.ended);
      case 'SCHEDULED':
        return translate(AppStrings.schedule);
      default:
        return status;
    }
  }

  static String paymentTypeText(String paymentType) {
    switch (paymentType) {
      case 'WALLET':
        return translate(AppStrings.wallet);
      case 'CREDIT':
        return translate(AppStrings.creditCards);
      case 'SUBSCRIBED':
        return translate(AppStrings.subscribed);
      case 'APPLE_PAY':
        return translate(AppStrings.applePay);
      case 'FREE':
        return translate(AppStrings.free);
      default:
        return paymentType;
    }
  }
}

class _VehicleSummary extends StatelessWidget {
  const _VehicleSummary({
    required this.vehicle,
    required this.bookingDate,
    required this.washingDate,
  });

  static const double _photoWidth = 96;
  static const double _photoHeight = 64;

  final Vehicle vehicle;
  final DateTime bookingDate;
  final DateTime? washingDate;

  String _format(DateTime date) =>
      '${AppDateFormatter.allDate(date)} ${AppDateFormatter.dateToStringHHMMA(date)}';

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          '${vehicle.brand!} ${vehicle.model}',
          style: KType.headline.copyWith(color: c.text),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: KSpace.s),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(KRadius.field),
              child: vehicle.imageLink!.isEmpty
                  ? SizedBox(
                      width: _photoWidth,
                      height: _photoHeight,
                      child: ColoredBox(
                        color: c.fill,
                        child: Icon(Icons.image, color: c.textSecondary),
                      ),
                    )
                  : ImageShared(
                      image: vehicle.imageLink!,
                      width: _photoWidth,
                      height: _photoHeight,
                    ),
            ),
            const SizedBox(width: KSpace.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: KSpace.xs,
                children: <Widget>[
                  VehicleInfoLine(
                    label: translate(AppStrings.plateNo),
                    value: vehicle.plateNumber!,
                  ),
                  VehicleInfoLine(
                    label: translate(AppStrings.bookingDate),
                    value: _format(bookingDate),
                  ),
                  if (washingDate != null)
                    VehicleInfoLine(
                      label: translate(AppStrings.washingDate),
                      value: _format(washingDate!),
                    ),
                  VehicleColorLine(color: vehicle.color!),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
