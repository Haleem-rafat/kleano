import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/fonts_manager.dart';

class TabBarSharedWidget extends StatefulWidget {
  final TabController tabController;
  final int currentTabIndex;
  final List<Widget> tabWidget;
  final Function(int index) onTab;
  const TabBarSharedWidget({
    Key? key,
    required this.tabController,
    required this.currentTabIndex,
    required this.tabWidget,
    required this.onTab,
  }) : super(key: key);

  @override
  State<TabBarSharedWidget> createState() => _TabBarSharedWidgetState();
}

class _TabBarSharedWidgetState extends State<TabBarSharedWidget> {
  late int currentTabIndex;

  @override
  void initState() {
    super.initState();
    currentTabIndex = widget.currentTabIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      margin: EdgeInsets.only(bottom: 19.h),
      decoration: BoxDecoration(
        color: ColorManager.divider2,
        borderRadius: BorderRadius.circular(
          8.r,
        ),
      ),
      child: TabBar(
        controller: widget.tabController,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(
            8.r,
          ),
          
          border: Border.all(color: Color.fromRGBO(0, 0, 0, 0.04), width: .5.w),
          boxShadow: <BoxShadow>[
            BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.04), offset: const Offset(0, 3), blurRadius: 3.r),
          ],
          color: ColorManager.white,
        ),
        labelStyle: AppStyles.caption12Medium
            .copyWith(color: ColorManager.darkGrey, fontFamily: FontManager.getFontFamily(Localizations.localeOf(context).languageCode)),
        unselectedLabelStyle: AppStyles.caption12Medium
            .copyWith(color: ColorManager.darkGrey, fontFamily: FontManager.getFontFamily(Localizations.localeOf(context).languageCode)),
        labelColor: ColorManager.black,
        unselectedLabelColor: ColorManager.black,
        onTap: widget.onTab,
        tabs: widget.tabWidget,
      ),
    );
  }
}
