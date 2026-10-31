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
            refreshController.loadComplete();
          }
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
          return const KLoadingState();
        } else if (state.myBookingStatus == RequestStatus.connectionError) {
          return KErrorState(
            message: translate(AppStrings.yourNotConnected),
            onRetry: _getMyBookingActive,
          );
        }
        return MyBookingList(
          refreshController: refreshController,
          onRefresh: _getMyBookingActive,
          onLoading: _getMyBookingActivePerPage,
          orderList: state.activeList,
          isActive: true,
          emptyText: AppStrings.thereIsNoActiveBookingYet,
        );
      },
    );
  }
}
