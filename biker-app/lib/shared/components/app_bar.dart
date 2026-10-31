import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class AppBarWhiteShared extends StatelessWidget {
  final String titleText;
  const AppBarWhiteShared({
    super.key,
    required this.titleText,
  });
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => pop(context),
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.arrow_back_ios,
              size: 24.r,
              color: ColorManager.black,
            ),
          ),
          SizedBox(
            width: 6.w,
          ),
          Text(
            titleText,
            //  translate(AppStrings.account),
            style: AppStyles.title16Bold.copyWith(
              color: ColorManager.darkGrey,
            ),
          ),
        ],
      ),
      backgroundColor: ColorManager.white,
      elevation: 0,
    );
  }
}
