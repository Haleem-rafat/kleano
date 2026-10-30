import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/screens/empty_screen.dart';
import 'package:thewhsherbiker/modules/Home/widget/accept_container.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

class AcceptWidget extends StatefulWidget {
  const AcceptWidget({Key? key}) : super(key: key);

  @override
  State<AcceptWidget> createState() => _AcceptWidgetState();
}

class _AcceptWidgetState extends State<AcceptWidget> {
  RefreshController refreshControllers = RefreshController();

  @override
  void initState() {
    super.initState();
    sl<HomeBloc>().add(BikerGetOrdersAccept());
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
        if (state is BikerGetOrdersAcceptSuccess) {
          refreshControllers.loadComplete();
        } else if (state is BikerCancelOrderSuccess) {
          showSnackBar(
            buildContext: context,
            message: translate(AppStrings.cancelOrderSuccess),
          );
        } else if (state is BikerCancelOrderFailed) {
          showSnackBar(
            buildContext: context,
            message: state.error,
          );
        }
      },
      builder: (BuildContext context, HomeState state) {
        if (state is BikerGetOrdersAcceptLoading) {
          return const LoadingWidget();
        } else if (state is BikerGetOrdersAcceptEmpty) {
          return EmptyScreen(
            notification: false,
            text: AppStrings.letYouKnow,
          );
        } else {
          if (sl<HomeBloc>().activeList.isEmpty) {
            return EmptyScreen(
              notification: false,
              text: AppStrings.letYouKnow,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: SmartRefresher(
                  enablePullDown: false,
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
                      return SizedBox(
                        height: 55.0,
                        child: Center(child: body),
                      );
                    },
                  ),
                  onLoading: () {
                    sl<HomeBloc>().add(BikerGetOrdersAcceptPagination());
                  },
                  child: ListView.separated(
                    itemCount: sl<HomeBloc>().activeList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 16.h,
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return AcceptContainer(
                          acceptOrder: sl<HomeBloc>().activeList[index],
                          index: index);
                    },
                  ),
                ),
              )
            ],
          );
        }
      },
    );
  }
}
