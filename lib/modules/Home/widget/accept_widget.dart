import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewhsherbiker/core/design/components/k_states.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/screens/empty_screen.dart';
import 'package:thewhsherbiker/modules/Home/widget/accept_container.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

/// The states after which `HomeBloc.activeList` may have changed. Order steps
/// taken on other screens change the list too, so they have to rebuild it;
/// everything else the bloc emits leaves this part of Home alone.
bool affectsActiveOrders(HomeState state) =>
    state is BikerGetOrdersAcceptLoading ||
    state is BikerGetOrdersAcceptSuccess ||
    state is BikerGetOrdersAcceptEmpty ||
    state is BikerGetOrdersAcceptFailed ||
    state is BikerAcceptOrderSuccess ||
    state is BikerOnTheWayOrderSuccess ||
    state is BikerArrivedOrderSuccess ||
    state is BikerOnWashingOrderSuccess ||
    state is BikerCompleteOrderSuccess ||
    state is BikerCancelOrderSuccess;

/// The order to deal with now, shown above everything else (a sliver).
class ActiveOrderFocus extends StatelessWidget {
  const ActiveOrderFocus({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: sl<HomeBloc>(),
      buildWhen: (HomeState previous, HomeState current) =>
          affectsActiveOrders(current),
      builder: (BuildContext context, HomeState state) {
        final List<OrderModel> orders = sl<HomeBloc>().activeList;
        if (orders.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(bottom: KSpace.l),
            child: AcceptContainer(
              key: ValueKey<String?>(orders.first.sId),
              acceptOrder: orders.first,
              index: 0,
            ),
          ),
        );
      },
    );
  }
}

/// The Active tab (a sliver): the orders after [ActiveOrderFocus]. Mounting it
/// loads the list, so it reloads when the biker comes back to this tab.
class AcceptWidget extends StatefulWidget {
  const AcceptWidget({super.key, required this.refreshController});

  /// Told when a page of orders has arrived.
  final RefreshController refreshController;

  @override
  State<AcceptWidget> createState() => _AcceptWidgetState();
}

class _AcceptWidgetState extends State<AcceptWidget> {
  @override
  void initState() {
    super.initState();
    sl<HomeBloc>().add(BikerGetOrdersAccept());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      bloc: sl<HomeBloc>(),
      listener: (BuildContext context, HomeState state) {
        if (state is BikerGetOrdersAcceptSuccess ||
            state is BikerGetOrdersAcceptEmpty) {
          widget.refreshController.loadComplete();
        } else if (state is BikerGetOrdersAcceptFailed) {
          if (widget.refreshController.isLoading) {
            widget.refreshController.loadFailed();
          }
        } else if (state is BikerCancelOrderSuccess) {
          showSnackBar(
            buildContext: context,
            message: translate(AppStrings.cancelOrderSuccess),
          );
        } else if (state is BikerCancelOrderFailed) {
          showSnackBar(buildContext: context, message: state.error);
        }
      },
      buildWhen: (HomeState previous, HomeState current) =>
          affectsActiveOrders(current),
      builder: (BuildContext context, HomeState state) {
        final List<OrderModel> orders = sl<HomeBloc>().activeList;
        if (orders.isEmpty) {
          if (state is BikerGetOrdersAcceptLoading) {
            return const SliverToBoxAdapter(child: KLoadingState());
          }
          if (state is BikerGetOrdersAcceptFailed) {
            return SliverToBoxAdapter(
              child: KErrorState(
                message: translate('defaultError'),
                onRetry: () => sl<HomeBloc>().add(BikerGetOrdersAccept()),
              ),
            );
          }
        }
        // The first order is already on screen in ActiveOrderFocus.
        if (orders.length <= 1) {
          return SliverToBoxAdapter(
            child: EmptyScreen(
              notification: false,
              text: AppStrings.letYouKnow,
            ),
          );
        }
        return SliverList.separated(
          itemCount: orders.length - 1,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: KSpace.l),
          itemBuilder: (BuildContext context, int index) {
            final OrderModel order = orders[index + 1];
            return AcceptContainer(
              key: ValueKey<String?>(order.sId),
              acceptOrder: order,
              index: index + 1,
            );
          },
        );
      },
    );
  }
}
