import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/screens/empty_screen.dart';
import 'package:thewhsherbiker/modules/Home/widget/order_container.dart';
import 'package:thewhsherbiker/modules/order/screens/order_change_status_screen.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class PendingWidget extends StatefulWidget {
  const PendingWidget({super.key});

  @override
  State<PendingWidget> createState() => _PendingWidgetState();
}

class _PendingWidgetState extends State<PendingWidget> {
  RefreshController refreshControllers = RefreshController();

  @override
  void initState() {
    super.initState();
    sl<HomeBloc>().add(BikerGetOrdersPending());
  }

  @override
  void dispose() {
    refreshControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      bloc: sl<HomeBloc>(),
      listener: (BuildContext context, HomeState state) {
        if (state is BikerGetOrdersSuccess) {
          refreshControllers.loadComplete();
        } else if (state is BikerAcceptOrderFailed) {
          showSnackBar(buildContext: context, message: state.error);
        } else if (state is BikerAcceptOrderSuccess) {
          if (state.details == false) {
            Navigator.of(context).push(
              createRoute(
                OrderChangeStatus(
                  order: sl<HomeBloc>().orderDetails,
                  notification: false,
                ),
              ),
            );
          }
        }
      },
      builder: (BuildContext context, HomeState state) {
        if (state is BikerGetOrdersLoading) {
          return const LoadingWidget();
        } else if (state is BikerGetOrdersEmpty) {
          return EmptyScreen(notification: false, text: AppStrings.letYouKnow);
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "${sl<HomeBloc>().pendingTotalLength} ${translate(AppStrings.requests)}",
                style: AppStyles.body14Medium.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
              SizedBox(height: 7.h),
              Expanded(
                child: SmartRefresher(
                  enablePullDown: true,
                  controller: refreshControllers,
                  enablePullUp: true,
                  header: const ClassicHeader(
                    refreshStyle: RefreshStyle.UnFollow,
                  ),
                  footer: CustomFooter(
                    builder: (BuildContext context, LoadStatus? mode) {
                      Widget body;
                      if (mode == LoadStatus.idle) {
                        body = Container();
                      } else if (mode == LoadStatus.loading) {
                        body = const LoadingWidget();
                      } else if (mode == LoadStatus.failed) {
                        body = const Text("Load Failed!Click retry!");
                      } else if (mode == LoadStatus.canLoading) {
                        body = const Text("release to load more");
                      } else {
                        body = const Text("No more Data");
                      }
                      return SizedBox(height: 55.0, child: Center(child: body));
                    },
                  ),
                  onRefresh: () {
                    sl<HomeBloc>().add(BikerGetOrdersPending());
                  },
                  onLoading: () {
                    sl<HomeBloc>().add(BikerGetOrdersPendingPagination());
                  },
                  child: ListView.separated(
                    itemCount: sl<HomeBloc>().orderList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 16.h);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return OrderContainer(index: index);
                    },
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
