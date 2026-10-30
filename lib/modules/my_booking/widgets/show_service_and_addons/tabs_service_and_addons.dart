import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/data/model/add_ons_model.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/modules/my_booking/widgets/show_service_and_addons/add_ons.dart';
import 'package:thewasher/modules/my_booking/widgets/show_service_and_addons/services_expanded.dart';
import 'package:thewasher/shared/components/tab_bar/tab_bar_shared.dart';

class TabsServicesAndAddOns extends StatefulWidget {
  final List<AddOnsModel> addOnsModel;
  final List<ServiceModel> services;
  const TabsServicesAndAddOns({
    super.key,
    required this.addOnsModel,
    required this.services,
  });

  @override
  State<TabsServicesAndAddOns> createState() => _TabsServicesAndAddOnsState();
}

class _TabsServicesAndAddOnsState extends State<TabsServicesAndAddOns>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final List<Widget> tabs;
  late int currentTabIndex;
  @override
  void initState() {
    super.initState();
    currentTabIndex = 0;
    _tabController = TabController(length: 2, vsync: this);
    tabs = <Widget>[
      ServicesExpanded(
        services: widget.services,
      ),
      AddOnsList(
        addOns: widget.addOnsModel,
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding:
              EdgeInsets.only(top: AppPadding.p16.h, bottom: AppPadding.p18.h),
          child: TabBarSharedWidget(
              tabController: _tabController,
              currentTabIndex: currentTabIndex,
              tabWidget: <Widget>[
                Tab(
                  text: translate(AppStrings.services),
                ),
                Tab(
                  text: translate(AppStrings.addOns),
                ),
              ],
              onTab: (int index) {
                setState(() {
                  currentTabIndex = index;
                });
              }),
        ),
        tabs[currentTabIndex],
      ],
    );
  }
}
