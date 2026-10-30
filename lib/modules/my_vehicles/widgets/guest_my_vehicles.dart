import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/utilties/navigator.dart';

class GuestMyVehicles extends StatelessWidget {
  const GuestMyVehicles({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: 232.w,
            child: Text(
              translate(AppStrings.getStarted),
              textAlign: TextAlign.center,
              style: AppStyles.title16Regular.copyWith(
                color: ColorManager.darkGrey,
              ),
            ),
          ),
          AppPadding.p12.ph,
          ButtonsShared(
            width: 180.w,
            onPressed: () {
              popALlAndPushPage(
                context,
                ChooseRegisterView(),
              );
            },
            text: translate(AppStrings.signUpNow),
          ),
        ],
      ),
    );
  }
}
