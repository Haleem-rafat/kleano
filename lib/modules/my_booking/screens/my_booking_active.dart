import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/utilis/enums.dart';
import 'package:thewasher/modules/my_booking/blocs/my_booking/my_booking_bloc.dart';
import 'package:thewasher/modules/my_booking/widgets/empty_services_and_addons.dart';
import 'package:thewasher/modules/my_booking/widgets/my_booking_list.dart';
import 'package:thewasher/modules/my_booking/widgets/my_booking_shimmer_loading.dart';
import 'package:thewasher/shared/components/connection_error/connection_error_screen.dart';
import 'package:thewasher/shared/components/smart_refresh.dart';
import 'package:thewasher/shared/components/snack_bar.dart';

class MyBookingActive extends StatefulWidget {
  const MyBookingActive({super.key});

  @override
  State<MyBookingActive> createState() => _MyBookingActiveState();
}

class _MyBookingActiveState extends State<MyBookingActive> {
  late MyBookingBloc myBookingBloc;
  late RefreshController refreshController;
  @override
  void initState() {
    super.initState();
    myBookingBloc = context.read<MyBookingBloc>();
    refreshController = RefreshController();
    if (AppShared.token.isNotEmpty) {
      _getMyBookingActive();
    }
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  void _getMyBookingActive() {
    myBookingBloc.add(FetchMyBookingActive());
  }

  void _getMyBookingActivePerPage() {
    myBookingBloc.add(MyBookingActivePerPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyBookingBloc, MyBookingState>(
      listener: (BuildContext context, MyBookingState state) {
        if (state.myBookingStatus == RequestStatus.success) {
          if (myBookingBloc.pageNumber > myBookingBloc.pageTotalCount) {
            refreshController.loadNoData();
          } else {
            refreshController.loadComplete(); // لو لسه في صفحات، أكمل
          }
          // refreshController.loadComplete();
        } else if (state.myBookingStatus == RequestStatus.failure) {
          showSnackBar(
              buildContext: context,
              message: state.error!.en!.isNotEmpty
                  ? state.error!.en!
                  : state.error!.ar!);
        }
      },
      builder: (BuildContext context, MyBookingState state) {
        if (state.myBookingStatus == RequestStatus.loading) {
          return const MyBookingShimmerLoading(showTrackingButton: true);
        } else if (state.myBookingStatus == RequestStatus.connectionError) {
          return Center(
            child: ConnectionErrorSharedScreen(onPressed: _getMyBookingActive),
          );
        }
        return SmartRefresherCustomWidget(
          refreshController: refreshController,
          onLoading: _getMyBookingActivePerPage,
          onRefresh: _getMyBookingActive,
          child: state.activeList.isNotEmpty
              ? MyBookingList(
                  orderList: state.activeList,
                )
              : const Center(
                  child: EmptyScreen(
                    image: AssetsManager.myBookingEmpty,
                    text: AppStrings.thereIsNoActiveBookingYet,
                  ),
                ),
        );
      },
    );
  }
}
