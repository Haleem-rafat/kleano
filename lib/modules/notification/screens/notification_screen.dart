import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:thewhsherbiker/core/resources/app_bar.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/screens/empty_screen.dart';
import 'package:thewhsherbiker/modules/Home/screens/home_screen.dart';
import 'package:thewhsherbiker/modules/notification/bloc/notification_bloc.dart';
import 'package:thewhsherbiker/modules/order/screens/order_change_status_screen.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  RefreshController refreshControllers = RefreshController();

  @override
  void initState() {
    super.initState();
    sl<NotificationBloc>().add(GetBikerNotification());
  }

  @override
  void dispose() {
    refreshControllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375.w, AppSize.s60.h),
        child: AppBarShared(
          titleAppBar: translate(AppStrings.notifications),
          isTextOnly: false,
        ),
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (BuildContext context, HomeState state) {
          if (state is BikerOrderSuccess) {
            print("hello");
            if (sl<HomeBloc>().orderDetails.status == "COMPLETED") {
              popALlAndPushPage(context, HomeScreen(initialIndex: 2));
            } else {
              Navigator.of(context).push(createRoute(OrderChangeStatus(
                order: sl<HomeBloc>().orderDetails,
                notification: true,
                markerBikerLocation: state.markerBikerLocation,
                markerUserLocation: state.markerUserLocation,
              )));
            }
          }
        },
        builder: (BuildContext context, HomeState state) {
          return BlocConsumer<NotificationBloc, NotificationState>(
            listener: (BuildContext context, NotificationState state) {
              if (state is BikerNotificationSuccess) {
                refreshControllers.loadComplete();
              }
            },
            bloc: sl<NotificationBloc>(),
            builder: (BuildContext context, NotificationState state) {
              if (state is BikerNotificationLoading) {
                return LoadingWidget();
              } else if (state is BikerNotificationEmpty) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                            height: 150.h,
                            child: EmptyScreen(
                              notification: true,
                              text: AppStrings.letYouKnow,
                            ))
                      ],
                    ),
                  ],
                );
              } else if (state is BikerNotificationFailed) {
                return Container();
              } else {
                return SmartRefresher(
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
                  onRefresh: () {
                    sl<NotificationBloc>().add(GetBikerNotification());
                  },
                  onLoading: () {
                    sl<NotificationBloc>()
                        .add(GetBikerNotificationPagination());
                  },
                  child: ListView.separated(
                    itemCount: sl<NotificationBloc>().notificationList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider(
                        color: ColorManager.divider,
                        thickness: 1,
                        height: 20.h,
                      );
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          sl<NotificationBloc>().notificationList[index].isRead!
                              ? sl<HomeBloc>().add(BikerOrder(
                                  orderId: sl<NotificationBloc>()
                                      .notificationList[index]
                                      .clickableItem!,
                                  context: context,
                                ))
                              : sl<NotificationBloc>().add(
                                  MakeNotificationIsRead(
                                      notificationId: sl<NotificationBloc>()
                                          .notificationList[index]
                                          .sId!,
                                      notificationIndex: index,
                                      context: context));
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 23.w, vertical: 10.h),
                          child: Row(
                            children: <Widget>[
                              sl<NotificationBloc>()
                                      .notificationList[index]
                                      .isRead!
                                  ? Container()
                                  : Container(
                                      width: 6.w,
                                      height: 6.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: ColorManager.primary,
                                      ),
                                    ),
                              SizedBox(
                                width: 8.w,
                              ),
                              SvgPicture.asset(ImageAssets.notificationSvg),
                              SizedBox(
                                width: 11.w,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      Localizations.localeOf(context)
                                                  .languageCode ==
                                              "en"
                                          ? sl<NotificationBloc>()
                                                  .notificationList[index]
                                                  .message!
                                                  .enTitle!
                                                  .isEmpty
                                              ? "Notification Title"
                                              : sl<NotificationBloc>()
                                                  .notificationList[index]
                                                  .message!
                                                  .enTitle!
                                          : sl<NotificationBloc>()
                                                  .notificationList[index]
                                                  .message!
                                                  .arTitle!
                                                  .isEmpty
                                              ? "Notification Title"
                                              : sl<NotificationBloc>()
                                                  .notificationList[index]
                                                  .message!
                                                  .arTitle!,
                                      style: AppStyles.captionGray12Medium
                                          .copyWith(
                                              color: ColorManager.darkGrey),
                                    ),
                                    SizedBox(
                                      height: 2.h,
                                    ),
                                    Text(
                                      Localizations.localeOf(context)
                                                  .languageCode ==
                                              "en"
                                          ? sl<NotificationBloc>()
                                                  .notificationList[index]
                                                  .message!
                                                  .enBody!
                                                  .isEmpty
                                              ? "Notification Body"
                                              : sl<NotificationBloc>()
                                                  .notificationList[index]
                                                  .message!
                                                  .enBody!
                                          : sl<NotificationBloc>()
                                                  .notificationList[index]
                                                  .message!
                                                  .arBody!
                                                  .isEmpty
                                              ? "Notification Body"
                                              : sl<NotificationBloc>()
                                                  .notificationList[index]
                                                  .message!
                                                  .arBody!,
                                      style: AppStyles.caption12Regular
                                          .copyWith(
                                              color: ColorManager.darkGrey),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    Align(
                                      alignment: Localizations.localeOf(context)
                                                  .languageCode ==
                                              "en"
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: Text(
                                        sl<NotificationBloc>()
                                                    .notificationList[index]
                                                    .createdAt! ==
                                                sl<NotificationBloc>()
                                                    .notificationList[index]
                                                    .timeNow
                                            ? sl<NotificationBloc>()
                                                .notificationList[index]
                                                .createdAtTime!
                                            : sl<NotificationBloc>()
                                                .notificationList[index]
                                                .createdAt!,
                                        style: AppStyles.caption12Regular
                                            .copyWith(
                                                color: ColorManager.darkGrey),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
