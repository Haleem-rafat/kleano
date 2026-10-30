import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class AppBarWhiteShared extends StatelessWidget {
  final String titleText;
  final void Function()? onTap;
  const AppBarWhiteShared({
    super.key,
    required this.titleText,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Row(
        children: <Widget>[
          GestureDetector(
            onTap: onTap ?? () => pop(context),
            behavior: HitTestBehavior.opaque,
            child: Icon(
              Icons.arrow_back_ios,
              size: 24.r,
              color: ColorManager.primary,
            ),
          ),
          AppSize.s6.pw,
          Text(
            titleText,
            //  translate(AppStrings.account),
            style: AppStyles.title16Bold.copyWith(
              color: ColorManager.black,
            ),
          ),
        ],
      ),
      backgroundColor: ColorManager.white,
      elevation: 0,
    );
  }
}
