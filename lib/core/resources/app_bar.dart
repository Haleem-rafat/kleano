import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class AppBarShared extends StatelessWidget {
  final String titleAppBar;
  final bool isTextOnly;
  final bool isCenter;
  final VoidCallback? onTap;
  const AppBarShared({
    super.key,
    required this.titleAppBar,
    this.isCenter = false,
    this.isTextOnly = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: AppStyles.lightStatusBarIconsWithTransparentColorStyle,
      backgroundColor: ColorManager.primary,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.08),
      // elevation: 3,
      centerTitle: isTextOnly
          ? true
          : isCenter
              ? true
              : false,
      automaticallyImplyLeading: false,
      title: Text(
        titleAppBar,
        style: AppStyles.titleWhite16Bold,
      ),
      titleSpacing: 0,
      leadingWidth: 50.w,
      leading: isTextOnly
          ? null
          : InkWell(
              onTap: () {
                if (onTap != null) {
                  onTap!();
                } else {
                  pop(context);
                }
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: ColorManager.white,
                size: AppSize.s24,
              ),
            ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(12),
        ),
      ),
    );
  }
}
