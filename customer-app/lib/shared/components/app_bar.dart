import 'package:flutter/material.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
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
    return GlassAppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      leadingWidth: 60,
      leading: GlassBackButton(
        color: ColorManager.primary,
        onPressed: onTap ?? () => pop(context),
      ),
      title: Text(
        titleText,
        style: AppStyles.title16Bold.copyWith(color: ColorManager.black),
      ),
    );
  }
}
