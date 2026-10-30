import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/order_container.dart';
import 'package:thewhsherbiker/modules/order/screens/order_change_status_screen.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) sl<HomeBloc>().dialogCount--;
      },
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        elevation: 0.6,
        backgroundColor: Colors.transparent,
        insetAnimationCurve: Curves.easeInOut,
        child: _buildChild(context),
      ),
    );
  }

  StatefulBuilder _buildChild(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, Function setState) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(15.r),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 10.h,),
                InkWell(
                  onTap: (){
                    pop(context);
                    sl<HomeBloc>().dialogCount--;
                  },
                  child: Icon(
                    Icons.close,
                    color: ColorManager.white,
                    size: 30,
                  ),
                ),
                SizedBox(height: 10.h,),
                Expanded(
                  child: BlocConsumer<HomeBloc, HomeState>(
                    bloc: sl<HomeBloc>(),
                    listener: (BuildContext context, HomeState state) {
                      if (state is BikerGetOrdersSuccess) {
                        refreshControllers.loadComplete();
                      } else if (state is BikerAcceptOrderFailed) {
                        showSnackBar(
                          buildContext: context,
                          message: state.error,
                        );
                      } else if (state is BikerAcceptOrderSuccess) {
                        pop(context);
                        sl<HomeBloc>().dialogCount--;
                       // pushPage(context, OrderChangeStatus(order: sl<HomeBloc>().orderDetails,));
                        Navigator.of(context).push(createRoute(OrderChangeStatus(order: sl<HomeBloc>().orderDetails,notification: false,)));
                      }
                    },
                    builder: (BuildContext context, HomeState state) {
                      if (state is BikerGetOrdersLoading) {
                        return const LoadingWidget();
                      } else if (state is BikerGetOrdersEmpty) {
                        debugPrint("here");
                        return Column(
                          children: <Widget>[
                            Container(
                              color: Colors.red,
                              height: 5.h,
                            ),
                            Expanded(child: SizedBox()),
                          ],
                        );
                      } else {
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
                                  pop(context);
                                  sl<HomeBloc>().dialogCount--;
                                  sl<HomeBloc>().add(BikerGetOrdersPendingPagination());
                                },
                                child: ListView.separated(
                                  itemCount: sl<HomeBloc>().orderList.length,
                                  separatorBuilder: (BuildContext context, int index) {
                                    return SizedBox(
                                      height: 16.h,
                                    );
                                  },
                                  itemBuilder: (BuildContext context, int index) {
                                    return OrderContainer(index: index);
                                  },
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
