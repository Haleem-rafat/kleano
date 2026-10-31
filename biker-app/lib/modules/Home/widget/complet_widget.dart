import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewhsherbiker/core/design/components/k_states.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/screens/empty_screen.dart';
import 'package:thewhsherbiker/modules/Home/widget/completed_card.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

/// The Completed list of the Orders tab (a sliver). Mounting it loads the list,
/// so it reloads when the biker comes back to it.
class CompleteWidget extends StatefulWidget {
  const CompleteWidget({super.key, required this.refreshController});

  /// Told when a page of orders has arrived.
  final RefreshController refreshController;

  @override
  State<CompleteWidget> createState() => _CompleteWidgetState();
}

class _CompleteWidgetState extends State<CompleteWidget> {
  @override
  void initState() {
    super.initState();
    sl<HomeBloc>().add(BikerGetOrdersComplete());
  }

  static bool _affectsCompletedOrders(HomeState state) =>
      state is BikerGetOrdersCompleteLoading ||
      state is BikerGetOrdersCompleteSuccess ||
      state is BikerGetOrdersCompleteEmpty ||
      state is BikerGetOrdersCompleteFailed;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      bloc: sl<HomeBloc>(),
      listener: (BuildContext context, HomeState state) {
        if (state is BikerGetOrdersCompleteSuccess ||
            state is BikerGetOrdersCompleteEmpty) {
          widget.refreshController.loadComplete();
          if (widget.refreshController.isRefresh) {
            widget.refreshController.refreshCompleted();
          }
        } else if (state is BikerGetOrdersCompleteFailed) {
          if (widget.refreshController.isLoading) {
            widget.refreshController.loadFailed();
          }
          if (widget.refreshController.isRefresh) {
            widget.refreshController.refreshFailed();
          }
        }
      },
      buildWhen: (HomeState previous, HomeState current) =>
          _affectsCompletedOrders(current),
      builder: (BuildContext context, HomeState state) {
        final KColors c = KColors.of(context);
        final List<OrderModel> orders = sl<HomeBloc>().completeList;
        if (orders.isEmpty) {
          if (state is BikerGetOrdersCompleteLoading) {
            return const SliverToBoxAdapter(child: KLoadingState());
          }
          if (state is BikerGetOrdersCompleteFailed) {
            return SliverToBoxAdapter(
              child: KErrorState(
                message: translate('defaultError'),
                onRetry: () => sl<HomeBloc>().add(BikerGetOrdersComplete()),
              ),
            );
          }
          return SliverToBoxAdapter(
            child: EmptyScreen(
              notification: false,
              text: AppStrings.letYouKnow,
            ),
          );
        }
        return SliverMainAxisGroup(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(bottom: KSpace.s),
                child: Text(
                  '${sl<HomeBloc>().completeTotalLength} '
                  '${tr(context, AppStrings.requests)}',
                  style: KType.footnote.copyWith(color: c.textSecondary),
                ),
              ),
            ),
            SliverList.separated(
              itemCount: orders.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: KSpace.l),
              itemBuilder: (BuildContext context, int index) => CompletedCard(
                key: ValueKey<String?>(orders[index].sId),
                order: orders[index],
              ),
            ),
          ],
        );
      },
    );
  }
}
