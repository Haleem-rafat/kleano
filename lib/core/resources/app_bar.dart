import 'package:flutter/material.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
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
    // iOS 26/27 navigation bar: no coloured bar; brand colour tints the
    // glass back button instead.
    return GlassAppBar(
      centerTitle: isTextOnly || isCenter,
      automaticallyImplyLeading: false,
      title: Text(
        titleAppBar,
        style: AppStyles.titleWhite16Bold.copyWith(color: ColorManager.black),
      ),
      leadingWidth: 60,
      leading: isTextOnly
          ? null
          : GlassBackButton(
              color: ColorManager.primary,
              onPressed: onTap ?? () => pop(context),
            ),
    );
  }
}
