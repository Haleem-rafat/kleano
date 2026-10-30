import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class AppBarShared extends StatelessWidget {
  final String titleAppBar;
  final bool isTextOnly;
  final bool isCenter;
  const AppBarShared({
    super.key,
    required this.titleAppBar,
    this.isCenter = false,
    this.isTextOnly = true,
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
              onPressed: () => pop(context),
            ),
    );
  }
}
