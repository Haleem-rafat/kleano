import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/event_stepper.dart';
import 'package:thewhsherbiker/modules/Home/widget/order_user_details.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

/// The panel over the map: order summary, wash progress and the next step.
class StatusOrderBottomSheet extends StatelessWidget {
  final OrderModel order;
  final int index;

  /// Lets the list scroll once the panel is fully open.
  final ScrollController? scrollController;
  const StatusOrderBottomSheet({
    super.key,
    required this.order,
    required this.index,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        KSpace.xl,
        KSpace.s,
        KSpace.xl,
        MediaQuery.paddingOf(context).bottom + KSpace.l,
      ),
      children: <Widget>[
        Center(
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: c.separator,
            ),
            child: const SizedBox(width: KSpace.xxxl, height: KSpace.xs),
          ),
        ),
        const SizedBox(height: KSpace.m),
        BlocBuilder<HomeBloc, HomeState>(
          bloc: sl<HomeBloc>(),
          buildWhen: (HomeState previous, HomeState current) =>
              affectsOrderSteps(current),
          builder: (BuildContext context, HomeState state) =>
              const OrderUserDetails(),
        ),
        const SizedBox(height: KSpace.xl),
        EventsStepper(order: order, orderIndex: index),
      ],
    );
  }
}
