import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/components/k_segmented.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/accept_widget.dart';
import 'package:thewhsherbiker/modules/Home/widget/complet_widget.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_status_card.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

enum OrdersSegment { active, completed }

/// The Orders tab: the Active and Completed lists. While the biker is offline it
/// asks them to go online and loads nothing, as Home always did.
class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.segment});

  /// Owned by the shell, so the choice survives leaving the tab.
  final ValueNotifier<OrdersSegment> segment;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final RefreshController _refreshController = RefreshController();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    sl<HomeBloc>().add(
      widget.segment.value == OrdersSegment.active
          ? BikerGetOrdersAccept()
          : BikerGetOrdersComplete(),
    );
  }

  /// Next page of the list on screen. An empty list has no next page: the page
  /// ends right after its empty state, so the footer can be reached there.
  void _onLoadMore() {
    final HomeBloc bloc = sl<HomeBloc>();
    if (widget.segment.value == OrdersSegment.active) {
      if (bloc.activeList.isEmpty) {
        _refreshController.loadComplete();
      } else {
        bloc.add(BikerGetOrdersAcceptPagination());
      }
    } else {
      if (bloc.completeList.isEmpty) {
        _refreshController.loadComplete();
      } else {
        bloc.add(BikerGetOrdersCompletePagination());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        automaticallyImplyLeading: false,
        title: Text(
          tr(context, AppStrings.ordersTab),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: AdaptiveContent(
        child: BlocSelector<ProfileBloc, ProfileState, bool>(
          bloc: sl<ProfileBloc>(),
          selector: (ProfileState state) => bikerIsOnline(),
          builder: (BuildContext context, bool online) => online
              ? _orders(context)
              : const SingleChildScrollView(
                  padding: EdgeInsets.all(KSpace.l),
                  child: HomeOfflinePrompt(),
                ),
        ),
      ),
    );
  }

  Widget _orders(BuildContext context) {
    return SmartRefresher(
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoadMore,
      enablePullDown: true,
      enablePullUp: true,
      header: const CustomHeader(
        builder: orderRefreshHeader,
        height: orderIndicatorHeight,
      ),
      footer: const CustomFooter(
        builder: orderLoadMoreFooter,
        height: orderIndicatorHeight,
      ),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              KSpace.l,
              KSpace.s,
              KSpace.l,
              0,
            ),
            sliver: ValueListenableBuilder<OrdersSegment>(
              valueListenable: widget.segment,
              builder:
                  (BuildContext context, OrdersSegment segment, Widget? child) {
                    return SliverMainAxisGroup(
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: KSegmented<OrdersSegment>(
                            segments: <OrdersSegment, String>{
                              OrdersSegment.active: tr(
                                context,
                                AppStrings.active,
                              ),
                              OrdersSegment.completed: tr(
                                context,
                                AppStrings.completed,
                              ),
                            },
                            selected: segment,
                            onChanged: (OrdersSegment value) =>
                                widget.segment.value = value,
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(height: KSpace.l),
                        ),
                        // Only the selected list is mounted: each loads on mount.
                        if (segment == OrdersSegment.active)
                          AcceptWidget(refreshController: _refreshController)
                        else
                          CompleteWidget(refreshController: _refreshController),
                      ],
                    );
                  },
            ),
          ),
          // Keeps the last card clear of the floating tab bar.
          SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.paddingOf(context).bottom + KSpace.l,
            ),
          ),
        ],
      ),
    );
  }
}
