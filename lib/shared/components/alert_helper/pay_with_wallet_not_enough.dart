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
import 'package:thewasher/utilties/navigator.dart';

class PayWithWalletNotEnoughAmount extends StatefulWidget {
  const PayWithWalletNotEnoughAmount({
    super.key,
  });

  @override
  State<PayWithWalletNotEnoughAmount> createState() =>
      _PayWithWalletNotEnoughAmountState();
}

class _PayWithWalletNotEnoughAmountState
    extends State<PayWithWalletNotEnoughAmount> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      elevation: 0.6,
      backgroundColor: Colors.transparent,
      insetAnimationCurve: Curves.easeInOut,
      child: _buildChild(context),
    );
  }

  StatefulBuilder _buildChild(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, Function setState) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
              decoration: BoxDecoration(
                color: ColorManager.white,
                border: Border.all(color: ColorManager.darkGrey),
              ),
              padding: EdgeInsets.fromLTRB(
                14.76.w,
                17.81.h,
                14.76.w,
                41.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                      alignment: Alignment.topLeft,
                      child: SvgPicture.asset(AssetsManager.vectorLayout)),
                  Text(
                    translate(
                        AppStrings.yourWalletNotEnoughRefundYourWalletFirst),
                    textAlign: TextAlign.center,
                    style: AppStyles.titleGray16Regular.copyWith(
                      color: ColorManager.darkGrey,
                    ),
                  ),
                  AppPadding.p24.ph,
                  ButtonsShared(
                    onPressed: () {},
                    text: translate(AppStrings.recharge),
                    width: 164.w,
                  ),
                  AppPadding.p32.ph,
                  GestureDetector(
                    onTap: () => pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      translate(AppStrings.cancel),
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.primary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}
