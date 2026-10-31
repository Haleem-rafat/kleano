import 'package:thewasher/core/design/components/k_stage_bar.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/functions/check_step_data.dart';
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
  const ActiveOrderCard({
    super.key,
    required this.order,
    this.showStages = false,
  });

  final OrderModel order;

  /// Adds the four-stage bar, for the Live status Home.
  final bool showStages;

  void _track(BuildContext context) {
    // Nothing to track until a biker has taken the order.
    if (order.biker == null) {
      pushPage(context, WashDetailsScreen(orderId: order.sId!));
      return;
    }
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
              if (showStages) ...<Widget>[
                OrderStageIcon(step: getStepData(order.status ?? '').step),
                const SizedBox(width: KSpace.m),
              ],
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
          if (showStages) ...<Widget>[
            const SizedBox(height: KSpace.l),
            KStageBar(
              pulse: true,
              step: getStepData(order.status ?? '').step,
              stages: <String>[
                translate(AppStrings.onTheWay),
                translate(AppStrings.arrived),
                translate(AppStrings.washing),
                translate(AppStrings.completed),
              ],
            ),
          ],
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

/// The wash's current stage as a living icon: the bike rides, the pin bounces,
/// the drop pulses. Still when the user asked for reduced motion.
class OrderStageIcon extends StatefulWidget {
  const OrderStageIcon({super.key, required this.step});

  /// Same numbering as the stage bar; -1 means waiting to set off.
  final int step;

  @override
  State<OrderStageIcon> createState() => _OrderStageIconState();
}

class _OrderStageIconState extends State<OrderStageIcon>
    with SingleTickerProviderStateMixin {
  static const double _size = KSpace.xxxl + KSpace.l;
  static const double _travel = KSpace.xs;

  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
    } else if (!_motion.isAnimating) {
      _motion.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  IconData get _icon => switch (widget.step) {
    0 => Icons.two_wheeler_rounded,
    1 => Icons.place_rounded,
    2 => Icons.water_drop_rounded,
    >= 3 => Icons.check_rounded,
    _ => Icons.schedule_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final CurvedAnimation curve = CurvedAnimation(
      parent: _motion,
      curve: Curves.easeInOut,
    );
    final Widget icon = Icon(_icon, color: c.onBrandTint);
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(shape: BoxShape.circle, color: c.brandTint),
        child: SizedBox.square(
          dimension: _size,
          child: Center(
            child: switch (widget.step) {
              0 => AnimatedBuilder(
                animation: curve,
                builder: (BuildContext _, Widget? child) => Transform.translate(
                  offset: Offset((curve.value - 0.5) * _travel * 2, 0),
                  child: child,
                ),
                child: icon,
              ),
              1 => AnimatedBuilder(
                animation: curve,
                builder: (BuildContext _, Widget? child) => Transform.translate(
                  offset: Offset(0, -curve.value * _travel),
                  child: child,
                ),
                child: icon,
              ),
              _ => ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.1).animate(curve),
                child: icon,
              ),
            },
          ),
        ),
      ),
    );
  }
}
