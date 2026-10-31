import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/widgets/empty_services_and_addons.dart';
import 'package:thewasher/modules/my_booking/widgets/my_booking_card.dart';
import 'package:thewasher/shared/components/smart_refresh.dart';

/// The pull-to-refresh list of one Bookings segment, or its empty state.
class MyBookingList extends StatelessWidget {
  /// Room for the floating WhatsApp button that sits above the tab bar.
  static const double _floatingButtonClearance = KSpace.xxxl * 2 + KSpace.l;

  final RefreshController refreshController;
  final VoidCallback onRefresh;
  final VoidCallback onLoading;
  final List<OrderModel> orderList;
  final bool isActive;
  final String emptyText;

  const MyBookingList({
    super.key,
    required this.refreshController,
    required this.onRefresh,
    required this.onLoading,
    required this.orderList,
    required this.emptyText,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return SmartRefresherCustomWidget(
      refreshController: refreshController,
      onLoading: onLoading,
      onRefresh: onRefresh,
      // The refresher takes a list as its own slivers, so this stays lazy. It
      // has to be the refresher's direct child for that.
      child: orderList.isNotEmpty
          ? ListView.separated(
              padding: EdgeInsets.fromLTRB(
                KSpace.xl,
                KSpace.s,
                KSpace.xl,
                MediaQuery.paddingOf(context).bottom + _floatingButtonClearance,
              ),
              itemCount: orderList.length,
              separatorBuilder: (BuildContext _, int _) =>
                  const SizedBox(height: KSpace.m),
              itemBuilder: (BuildContext _, int index) =>
                  MyBookingCard(order: orderList[index], isActive: isActive),
            )
          : Center(
              child: EmptyScreen(
                image: AssetsManager.myBookingEmpty,
                text: emptyText,
              ),
            ),
    );
  }
}
