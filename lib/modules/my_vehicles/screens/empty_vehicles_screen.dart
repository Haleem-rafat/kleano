import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/shared/components/buttons.dart';

class EmptyVehiclesScreen extends StatelessWidget {
  final VoidCallback onPressed;
  const EmptyVehiclesScreen({Key? key, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 23.w),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppPadding.p23.ph,
            Text(
              translate(AppStrings.myVehicles),
              style: AppStyles.title16Bold.copyWith(color: ColorManager.black),
            ),
            AppPadding.p8.ph,
            Text(translate(AppStrings.addCarInfo),
                style: AppStyles.subtextGray14Regular
                    .copyWith(color: ColorManager.black)),
            87.ph,
            Center(
              child: SvgPicture.asset(
                AssetsManager.emptyCarSVG,
                color: ColorManager.black,
              ),
            ),
            148.ph,
            Center(
              child: ButtonDottedShared(
                onPressed: onPressed,
                text: translate(AppStrings.addNewVehicles),
              ),
            )
          ]),
    );
  }
}
