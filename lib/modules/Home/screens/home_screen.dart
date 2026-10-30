import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thewhsherbiker/core/components/circle_image.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/core/utilis/enums.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/Home/widget/accept_widget.dart';
import 'package:thewhsherbiker/modules/Home/widget/complet_widget.dart';
import 'package:thewhsherbiker/modules/notification/bloc/notification_bloc.dart';
import 'package:thewhsherbiker/modules/notification/screens/notification_screen.dart';
import 'package:thewhsherbiker/modules/notification/widget/firebase_notification.dart';
import 'package:thewhsherbiker/modules/notification/widget/local_notification.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';
import 'package:thewhsherbiker/modules/profile/screens/profile_screen.dart';
import 'package:thewhsherbiker/modules/profile/widget/biker_status_switch.dart';
import 'package:thewhsherbiker/shared/components/buttons.dart';
import 'package:thewhsherbiker/shared/components/online_offline.dart';
import 'package:thewhsherbiker/shared/components/shimmering/basic_container_shimmering.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/components/tab_bar_shared.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class HomeScreen extends StatefulWidget {
  int initialIndex;
  HomeScreen({Key? key, required this.initialIndex}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  DateTime preBackPress = DateTime.now();
  // bool _value = true;
  late TabController _tabController;
  late final FirebaseCloudMessagingService firebaseCloudMessagingService;
  bool isFinished = false;
  late int currentTabIndex;
  String whatsappNumber = "+966533720654";
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialIndex);
    currentTabIndex = 0;

    firebaseCloudMessagingService = FirebaseCloudMessagingService();
    // sl<NotificationBloc>().add(MakePushNotification());
    sl<NotificationBloc>().add(GetBikerNotification());
    sl<ProfileBloc>().add(BikerGetTotalWashes(status: "COMPLETED"));
    sl<ProfileBloc>().add(BikerGetTotalCommission());

    if (sl<ProfileBloc>().profile.status == BikerStatus.ONLINE.name) {
      sl<HomeBloc>().add(BikerGetNewOrders());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    try {
      // Refresh user profile
      sl<ProfileBloc>().add(BikerProfile());

      // Refresh total washes
      sl<ProfileBloc>().add(BikerGetTotalWashes(status: "COMPLETED"));

      // Refresh total commission
      sl<ProfileBloc>().add(BikerGetTotalCommission());

      // Refresh active orders if biker is online
      if (sl<ProfileBloc>().profile.status == BikerStatus.ONLINE.name) {
        sl<HomeBloc>().add(BikerGetOrdersAccept());
      }

      // Wait for the requests to complete
      await Future.delayed(const Duration(milliseconds: 1000));

      // Complete the refresh
      if (mounted) {
        _refreshController.refreshCompleted();
      }
    } catch (e) {
      if (mounted) {
        _refreshController.refreshFailed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationBloc, NotificationState>(
      listener: (BuildContext context, NotificationState state) {
        if (state is MakePushNotificationFailed) {
          showSnackBar(
            buildContext: context,
            message: state.error,
          );
        } else if (state is MakePushNotificationSuccess) {
          firebaseCloudMessagingService
              .listenToForegroundNotifications((RemoteMessage message) async {
            sl<NotificationBloc>().totalUnRead++;
            LocalNotificationServices(context: context).notification(
                title: message.notification!.title!,
                body: message.notification!.body!);
          });
          firebaseCloudMessagingService
              .listenToBackgroundNotifications((RemoteMessage message) async {
            pushPage(context, NotificationScreen());
          });
        }
      },
      builder: (BuildContext context, NotificationState state) {
        return WillPopScope(
          onWillPop: () async {
            final Duration timeGap = DateTime.now().difference(preBackPress);
            final bool cantExit = timeGap >= const Duration(seconds: 2);
            preBackPress = DateTime.now();
            if (cantExit) {
              final SnackBar snack = SnackBar(
                content: Text(translate(AppStrings.backButton)),
                duration: const Duration(seconds: 2),
              );
              ScaffoldMessenger.of(context).showSnackBar(snack);
              return false;
            } else {
              SystemNavigator.pop();
              return true;
            }
          },
          child: Scaffold(
            appBar: PreferredSize(
                preferredSize: Size(AppSize.s375, AppSize.s100.h),
                child: HomeAppBar()),
            body: SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              enablePullDown: true,
              enablePullUp: false,
              header: const ClassicHeader(
                refreshStyle: RefreshStyle.Follow,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 25.h,
                    ),
                    _YourAnalyticsSection(),
                    SizedBox(
                      height: 18.h,
                    ),
                    TabsHome(),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final Uri whatsappUri =
                    Uri.parse("https://wa.me/$whatsappNumber");

                if (await canLaunchUrl(whatsappUri)) {
                  await launchUrl(whatsappUri,
                      mode: LaunchMode.externalApplication);
                } else {
                  final Uri whatsappWebUri = Uri.parse(
                      "https://web.whatsapp.com/send?phone=$whatsappNumber");
                  if (await canLaunchUrl(whatsappWebUri)) {
                    await launchUrl(whatsappWebUri,
                        mode: LaunchMode.externalApplication);
                  } else {
                    showSnackBar(
                      buildContext: context,
                      message:
                          'Unable to open WhatsApp. Please install WhatsApp or try again.',
                    );
                  }
                }
              },
              backgroundColor: const Color(0xFF25D366),
              child: SvgPicture.asset(
                "assets/svg/whatsapp_icon.svg",
                height: 24,
                width: 24,
                color: Colors.white,
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          ),
        );
      },
    );
  }

  BlocBuilder<ProfileBloc, ProfileState> TabsHome() {
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: sl<ProfileBloc>(),
      builder: (BuildContext context, ProfileState state) {
        if (sl<ProfileBloc>().profile.status == BikerStatus.ONLINE.name) {
          return Expanded(
            child: Column(
              children: <Widget>[
                TabBarSharedWidget(
                  tabController: _tabController,
                  currentTabIndex: currentTabIndex,
                  tabWidget: <Widget>[
                    // Tab(text: translate(AppStrings.pending)),
                    Tab(text: translate(AppStrings.active)),
                    Tab(text: translate(AppStrings.completed)),
                  ],
                  onTab: (int index) {
                    setState(() {
                      currentTabIndex = index;
                    });
                  },
                ),
                SizedBox(
                  height: 18.h,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: <Widget>[
                      // PendingWidget(),
                      AcceptWidget(),
                      CompleteWidget()
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 50.h, child: SwitchSVGs()),
                Text(
                  translate(AppStrings.startReceivingRequests),
                  textAlign: TextAlign.center,
                  style: AppStyles.title16Regular.copyWith(
                    color: ColorManager.darkGrey,
                  ),
                ),
                SizedBox(
                  height: 38.h,
                ),
                ButtonsShared(
                  onPressed: () {
                    sl<ProfileBloc>().add(
                        BikerUpdateStatus(status: BikerStatus.ONLINE.name));
                  },
                  textStyle: AppStyles.title16Bold,
                  borderRadius: 8,
                  text: AppStrings.goOnlineNow,
                  width: 164.w,
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

class _YourAnalyticsSection extends StatelessWidget {
  const _YourAnalyticsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          translate(AppStrings.yourAnalytics),
          style: AppStyles.body14Medium.copyWith(color: ColorManager.darkGrey),
        ),
        SizedBox(
          height: 14.h,
        ),
        BlocBuilder<ProfileBloc, ProfileState>(
          bloc: sl<ProfileBloc>(),
          builder: (BuildContext context, ProfileState state) {
            // Check if analytics data is loading
            final bool isLoading = state is BikerGetTotalWashesLoading ||
                state is BikerGetTotalCommissionLoading;

            if (isLoading) {
              return _buildAnalyticsLoadingShimmer();
            }

            final ProfileModel profile = sl<ProfileBloc>().profile;
            final num? rating = profile.rating;
            final int? totalWashes = profile.totalWashes;
            final totalCommission = profile.totalCommission;

            print("jnjknnknkjnjknk ${totalCommission}");

            return Container(
              width: 327.w,
              decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: ColorManager.black.withOpacity(.08),
                        blurRadius: 6.r,
                        offset: const Offset(0, 3))
                  ]),
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: <Widget>[
                  // First Row: Total Washes and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      // Total Washes Section
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SvgPicture.asset(
                              "assets/svg/total_washes.svg",
                              height: 32.h,
                              width: 32.w,
                              color: ColorManager.primary,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              '${totalWashes ?? 0}',
                              style: AppStyles.title16Bold.copyWith(
                                fontSize: 20.sp,
                                color: ColorManager.primary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              translate(AppStrings.totalWashes),
                              style: AppStyles.caption12Regular.copyWith(
                                color: ColorManager.darkGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Divider
                      Container(
                        height: 60.h,
                        width: 1.w,
                        color: ColorManager.lightGray,
                      ),

                      // Rating Section
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SvgPicture.asset(
                              "assets/svg/rating.svg",
                              height: 32.h,
                              width: 32.w,
                              color: ColorManager.primary,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              rating != null
                                  ? rating.toStringAsFixed(1)
                                  : '0.0',
                              style: AppStyles.title16Bold.copyWith(
                                fontSize: 20.sp,
                                color: ColorManager.primary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              translate(AppStrings.rating),
                              style: AppStyles.caption12Regular.copyWith(
                                color: ColorManager.darkGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Horizontal Divider between rows
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Container(
                      height: 1.h,
                      width: double.infinity,
                      color: ColorManager.lightGray,
                    ),
                  ),

                  // Second Row: Commission (Today, All Time, All Weekends)
                  if (totalCommission != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        // Today Commission
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SvgPicture.asset(
                                ImageAssets.walletCoin,
                                height: 24.h,
                                width: 24.w,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '${totalCommission.today.totalCommission}',
                                style: AppStyles.title16Bold.copyWith(
                                  fontSize: 16.sp,
                                  color: ColorManager.primary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                translate(AppStrings.today),
                                style: AppStyles.caption12Regular.copyWith(
                                  color: ColorManager.darkGrey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 50.h,
                          width: 1.w,
                          color: ColorManager.lightGray,
                        ),
                        // All Time Commission
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SvgPicture.asset(
                                ImageAssets.walletCoin,
                                height: 24.h,
                                width: 24.w,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '${totalCommission.allTime.totalCommission}',
                                style: AppStyles.title16Bold.copyWith(
                                  fontSize: 16.sp,
                                  color: ColorManager.primary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                translate(AppStrings.allTime),
                                style: AppStyles.caption12Regular.copyWith(
                                  color: ColorManager.darkGrey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 50.h,
                          width: 1.w,
                          color: ColorManager.lightGray,
                        ),
                        // All Weekends Commission
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SvgPicture.asset(
                                ImageAssets.walletCoin,
                                height: 24.h,
                                width: 24.w,
                              ),
                              SizedBox(height: 6.h),
                              Text(
                                '${totalCommission.allWeekends.totalCommission}',
                                style: AppStyles.title16Bold.copyWith(
                                  fontSize: 16.sp,
                                  color: ColorManager.primary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                translate(AppStrings.weekends),
                                style: AppStyles.caption12Regular.copyWith(
                                  color: ColorManager.darkGrey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAnalyticsLoadingShimmer() {
    return Container(
      width: 327.w,
      decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: ColorManager.black.withOpacity(.08),
                blurRadius: 6.r,
                offset: const Offset(0, 3))
          ]),
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: <Widget>[
          // First Row: Total Washes and Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Total Washes Section
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    BasicContainerShemmering(
                      height: 32.h,
                      width: 32.w,
                      radius: 16,
                    ),
                    SizedBox(height: 8.h),
                    BasicContainerShemmering(
                      height: 20.h,
                      width: 40.w,
                      radius: 4,
                    ),
                    SizedBox(height: 4.h),
                    BasicContainerShemmering(
                      height: 12.h,
                      width: 60.w,
                      radius: 4,
                    ),
                  ],
                ),
              ),

              // Divider
              Container(
                height: 60.h,
                width: 1.w,
                color: ColorManager.lightGray,
              ),

              // Rating Section
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    BasicContainerShemmering(
                      height: 32.h,
                      width: 32.w,
                      radius: 16,
                    ),
                    SizedBox(height: 8.h),
                    BasicContainerShemmering(
                      height: 20.h,
                      width: 40.w,
                      radius: 4,
                    ),
                    SizedBox(height: 4.h),
                    BasicContainerShemmering(
                      height: 12.h,
                      width: 50.w,
                      radius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Horizontal Divider between rows
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Container(
              height: 1.h,
              width: double.infinity,
              color: ColorManager.lightGray,
            ),
          ),

          // Second Row: Commission (Today, All Time, All Weekends)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              // Today Commission
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    BasicContainerShemmering(
                      height: 24.h,
                      width: 24.w,
                      radius: 12,
                    ),
                    SizedBox(height: 6.h),
                    BasicContainerShemmering(
                      height: 16.h,
                      width: 35.w,
                      radius: 4,
                    ),
                    SizedBox(height: 2.h),
                    BasicContainerShemmering(
                      height: 12.h,
                      width: 40.w,
                      radius: 4,
                    ),
                  ],
                ),
              ),
              Container(
                height: 50.h,
                width: 1.w,
                color: ColorManager.lightGray,
              ),
              // All Time Commission
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    BasicContainerShemmering(
                      height: 24.h,
                      width: 24.w,
                      radius: 12,
                    ),
                    SizedBox(height: 6.h),
                    BasicContainerShemmering(
                      height: 16.h,
                      width: 35.w,
                      radius: 4,
                    ),
                    SizedBox(height: 2.h),
                    BasicContainerShemmering(
                      height: 12.h,
                      width: 50.w,
                      radius: 4,
                    ),
                  ],
                ),
              ),
              Container(
                height: 50.h,
                width: 1.w,
                color: ColorManager.lightGray,
              ),
              // All Weekends Commission
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    BasicContainerShemmering(
                      height: 24.h,
                      width: 24.w,
                      radius: 12,
                    ),
                    SizedBox(height: 6.h),
                    BasicContainerShemmering(
                      height: 16.h,
                      width: 35.w,
                      radius: 4,
                    ),
                    SizedBox(height: 2.h),
                    BasicContainerShemmering(
                      height: 12.h,
                      width: 50.w,
                      radius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSize.s100.h,
      decoration: BoxDecoration(
          color: ColorManager.primary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12.r),
            bottomRight: Radius.circular(12.r),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: ColorManager.black.withOpacity(.08),
                blurRadius: 6.r,
                offset: const Offset(0, 3))
          ]),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          BlocBuilder<ProfileBloc, ProfileState>(
            bloc: sl<ProfileBloc>(),
            builder: (BuildContext context, ProfileState state) {
              if (state is BikerProfileSuccess ||
                  state is BikerProfileEditSuccess ||
                  state is ChangeBikerLanguageSuccess) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        pushPage(context, ProfileScreen());
                      },
                      child: CircleImageShared(
                        imageUrl: sl<ProfileBloc>().profile.imageLink!,
                        radius: 20.r,
                        name: sl<ProfileBloc>().profile.userName!,
                      ),
                    ),
                    89.horizontalSpace,
                    BikerStatusSwitchWidget(
                      isHome: true,
                    ),
                    96.horizontalSpace,
                    _notificationComponent()
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}

class _notificationComponent extends StatelessWidget {
  const _notificationComponent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (BuildContext context, NotificationState state) {
        return InkWell(
          onTap: () {
            pushPage(context, NotificationScreen());
          },
          child: sl<NotificationBloc>().totalUnRead > 0
              ? SvgPicture.asset(
                  ImageAssets.notificationLogo,
                  height: 24.h,
                  width: 24.w,
                )
              : SvgPicture.asset(
                  ImageAssets.notificationEmptySvg,
                  height: 24.h,
                  width: 24.w,
                ),
        );
      },
    );
  }
}
