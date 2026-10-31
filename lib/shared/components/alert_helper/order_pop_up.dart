import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_states.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/Home/widget/order_container.dart';
import 'package:thewhsherbiker/modules/order/screens/order_change_status_screen.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

/// New requests, shown over whatever the biker is doing.
class OrderPopUp extends StatefulWidget {
  const OrderPopUp({super.key});

  @override
  State<OrderPopUp> createState() => _OrderPopUpState();
}

class _OrderPopUpState extends State<OrderPopUp> {
  RefreshController refreshControllers = RefreshController();

  @override
  void dispose() {
    refreshControllers.dispose();
    super.dispose();
  }

  static bool _affectsList(HomeState state) =>
      state is BikerGetOrdersLoading ||
      state is BikerGetOrdersSuccess ||
      state is BikerGetOrdersEmpty ||
      state is BikerGetOrdersFailed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) sl<HomeBloc>().dialogCount--;
      },
      child: Dialog(
        insetPadding: const EdgeInsets.all(KSpace.l),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GlassIconButton(
              icon: Icons.close,
              sfSymbol: 'xmark',
              color: KColors.of(context).brand,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: () {
                pop(context);
                sl<HomeBloc>().dialogCount--;
              },
            ),
            const SizedBox(height: KSpace.s),
            Expanded(
              child: BlocConsumer<HomeBloc, HomeState>(
                bloc: sl<HomeBloc>(),
                listener: (BuildContext context, HomeState state) {
                  if (state is BikerGetOrdersSuccess) {
                    refreshControllers.loadComplete();
                  } else if (state is BikerAcceptOrderFailed) {
                    showSnackBar(buildContext: context, message: state.error);
                  } else if (state is BikerAcceptOrderSuccess) {
                    pop(context);
                    sl<HomeBloc>().dialogCount--;
                    Navigator.of(context).push(
                      createRoute(
                        OrderChangeStatus(
                          order: sl<HomeBloc>().orderDetails,
                          notification: false,
                        ),
                      ),
                    );
                  }
                },
                buildWhen: (HomeState previous, HomeState current) =>
                    _affectsList(current),
                builder: (BuildContext context, HomeState state) {
                  if (state is BikerGetOrdersLoading) {
                    return const KCard(child: KLoadingState());
                  }
                  if (state is BikerGetOrdersEmpty) {
                    return KCard(
                      child: KEmptyState(
                        title: tr(context, AppStrings.newRequests),
                        message: tr(context, AppStrings.letYouKnow),
                      ),
                    );
                  }
                  return SmartRefresher(
                    enablePullDown: false,
                    controller: refreshControllers,
                    enablePullUp: true,
                    footer: const CustomFooter(
                      builder: orderLoadMoreFooter,
                      height: orderIndicatorHeight,
                    ),
                    onLoading: () {
                      pop(context);
                      sl<HomeBloc>().dialogCount--;
                      sl<HomeBloc>().add(BikerGetOrdersPendingPagination());
                    },
                    child: ListView.separated(
                      itemCount: sl<HomeBloc>().orderList.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: KSpace.l),
                      itemBuilder: (BuildContext context, int index) =>
                          OrderContainer(index: index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
