import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/utilis/enums.dart';
import 'package:thewasher/modules/my_booking/blocs/my_booking/my_booking_bloc.dart';
import 'package:thewasher/modules/my_booking/widgets/my_booking_list.dart';
import 'package:thewasher/shared/components/snack_bar.dart';

class MyBookingHistory extends StatefulWidget {
  const MyBookingHistory({super.key});

  @override
  State<MyBookingHistory> createState() => _MyBookingHistoryState();
}

class _MyBookingHistoryState extends State<MyBookingHistory> {
  late MyBookingBloc myBookingBloc;
  late RefreshController refreshController;
  @override
  void initState() {
    super.initState();
    myBookingBloc = context.read<MyBookingBloc>();
    refreshController = RefreshController();
    if (AppShared.token.isNotEmpty) {
      _getMyBookingHistory();
    }
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  void _getMyBookingHistory() {
    myBookingBloc.add(FetchMyBookingHistory());
  }

  void _getMyBookingHistoryPerPage() {
    myBookingBloc.add(MyBookingHistoryPerPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MyBookingBloc, MyBookingState>(
      listener: (BuildContext context, MyBookingState state) {
        if (state.myBookingStatus == RequestStatus.success) {
          refreshController.loadComplete();
        } else if (state.myBookingStatus == RequestStatus.failure) {
          showSnackBar(
            buildContext: context,
            message: state.error!.en!.isNotEmpty
                ? state.error!.en!
                : state.error!.ar!,
          );
        }
      },
      builder: (BuildContext context, MyBookingState state) {
        if (state.myBookingStatus == RequestStatus.loading) {
          return const KSkeleton.list();
        } else if (state.myBookingStatus == RequestStatus.connectionError) {
          return KErrorState(
            message: translate(AppStrings.yourNotConnected),
            onRetry: _getMyBookingHistory,
          );
        }
        return MyBookingList(
          refreshController: refreshController,
          onRefresh: _getMyBookingHistory,
          onLoading: _getMyBookingHistoryPerPage,
          orderList: state.historyList,
          isActive: false,
          emptyText: AppStrings.thereIsNoHistoryBookingYet,
        );
      },
    );
  }
}
