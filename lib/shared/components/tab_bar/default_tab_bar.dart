import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class DefaultTabBarShared extends StatelessWidget {
  final TabController tabController;
  final List<Widget> tabWidget;
  const DefaultTabBarShared({
    super.key,
    required this.tabController,
    required this.tabWidget,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      indicatorSize: TabBarIndicatorSize.tab,
      controller: tabController,
      unselectedLabelColor: ColorManager.darkGrey,
      labelColor: ColorManager.black,
      indicatorColor: ColorManager.secondary,
      dividerColor: Colors.transparent,
      indicatorWeight: 4.h,
      labelStyle: AppStyles.body14Medium.copyWith(
          color: ColorManager.darkGrey,
          fontFamily: Localizations.localeOf(context).languageCode == 'ar'
              ? 'Cairo'
              : 'Roboto'),
      unselectedLabelStyle: AppStyles.body14Medium.copyWith(
          color: ColorManager.darkGrey,
          fontFamily: Localizations.localeOf(context).languageCode == 'ar'
              ? 'Cairo'
              : 'Roboto'),
      tabs: tabWidget,
    );
  }
}
