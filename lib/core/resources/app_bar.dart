import 'package:flutter/material.dart';
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
    return AppBar(
      systemOverlayStyle:
          AppStyles.lightStatusBarIconsWithTransparentColorStyle,
      backgroundColor: ColorManager.primary,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.08),
      // elevation: 3,
      centerTitle: isTextOnly ? true : isCenter ? true : false,
      automaticallyImplyLeading: false,
      title: Text(
        titleAppBar,
        style: AppStyles.titleWhite16Bold,
      ),
      leading: isTextOnly ? null : InkWell(
        onTap: () {
          pop(context);
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
