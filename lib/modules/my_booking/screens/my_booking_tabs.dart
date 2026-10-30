import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/my_booking/screens/my_booking_active.dart';
import 'package:thewasher/modules/my_booking/screens/my_booking_history.dart';
import 'package:thewasher/modules/my_booking/screens/my_booking_scheduled.dart';
import 'package:thewasher/modules/my_vehicles/widgets/guest_my_vehicles.dart';
import 'package:thewasher/shared/components/tab_bar/tab_bar_shared.dart';

class MyBookingMainTabsScreen extends StatefulWidget {
  const MyBookingMainTabsScreen({super.key});

  @override
  State<MyBookingMainTabsScreen> createState() =>
      _MyBookingMainTabsScreenState();
}

class _MyBookingMainTabsScreenState extends State<MyBookingMainTabsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final List<Widget> _tabs;
  late int currentTabIndex;
  @override
  void initState() {
    super.initState();
    initialTabs();
  }

  initialTabs() {
    currentTabIndex = 0;
    _tabController = TabController(length: 3, vsync: this);
    _tabs = <Widget>[
      const MyBookingActive(),
      const MyBookingHistory(),
      const MyBookingScheduled(),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: AppBarShared(
          titleAppBar: translate(AppStrings.myBookings),
        ),
      ),
      body: isGuestUser
          ? GuestMyVehicles()
          : Column(children: <Widget>[
              AppPadding.p16.ph,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p28.w),
                child: TabBarSharedWidget(
                  tabController: _tabController,
                  currentTabIndex: currentTabIndex,
                  tabWidget: <Widget>[
                    Tab(
                      text: translate(AppStrings.active),
                    ),
                    Tab(
                      text: translate(AppStrings.history),
                    ),
                    Tab(
                      text: translate(AppStrings.schedule),
                    ),
                  ],
                  onTab: (int index) {
                    setState(() {
                      currentTabIndex = index;
                    });
                  },
                ),
              ),
              Expanded(child: _tabs[currentTabIndex]),
            ]),
    );
  }
}
