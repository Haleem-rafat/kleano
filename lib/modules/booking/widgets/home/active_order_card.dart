import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/screens/wash_details.dart';
import 'package:thewasher/modules/my_booking/widgets/my_booking_card.dart';
import 'package:thewasher/modules/tracking_order/blocs/socket_bloc.dart';
import 'package:thewasher/modules/tracking_order/screens/tracking_order_main_screen.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

/// The wash in progress, at the top of Home: what a returning user wants first.
class ActiveOrderCard extends StatelessWidget {
  const ActiveOrderCard({super.key, required this.order});

  final OrderModel order;

  void _track(BuildContext context) {
    final GeneralSingleton singleton = GeneralSingleton();
    singleton.orderId = order.sId;
    singleton.timeOnTheWay = '';
    singleton.timeArrived = '';
    singleton.timeWashing = '';
    singleton.timeComplete = '';
    BlocProvider.of<SocketBloc>(context).add(OpenSocketIo());
    pushPage(context, TrackingOrderMainScreen(orderModel: order));
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final String vehicle = <String?>[
      order.vehicle?.brand,
      order.vehicle?.model,
    ].where((String? part) => part?.isNotEmpty == true).join(' ');
    final bool onTheWay = order.status == AppConstants.bikerOnTheWay;
    return KCard(
      onTap: order.sId == null
          ? null
          : () => pushPage(context, WashDetailsScreen(orderId: order.sId!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      vehicle.isEmpty ? translate(AppStrings.active) : vehicle,
                      style: KType.headline.copyWith(color: c.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (order.location?.streetName?.isNotEmpty == true)
                      Text(
                        order.location!.streetName!,
                        style: KType.subhead.copyWith(color: c.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: KSpace.m),
              KStatusChip(
                label: MyBookingCard.statusText(order.status ?? ''),
                status: onTheWay ? KStatus.warning : KStatus.brand,
              ),
            ],
          ),
          if (onTheWay) ...<Widget>[
            const SizedBox(height: KSpace.m),
            KButton(
              label: translate(AppStrings.trackYourWash),
              variant: KButtonVariant.secondary,
              onPressed: () => _track(context),
            ),
          ],
        ],
      ),
    );
  }
}
