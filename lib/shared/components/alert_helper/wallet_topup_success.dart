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
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class WalletTopupSuccess extends StatefulWidget {
  const WalletTopupSuccess({super.key});

  @override
  State<WalletTopupSuccess> createState() => _WalletTopupSuccessState();
}

class _WalletTopupSuccessState extends State<WalletTopupSuccess> {
  @override
  void initState() {
    // Refresh user profile to update wallet balance
    sl<GetUserProfileBloc>().add(GetUserProfileEvent(isRefresh: true));
    super.initState();
  }

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

  _buildChild(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

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
              AppPadding.p12.w,
              44.99.h,
              AppPadding.p12.w,
              44.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  width: 85.5.w,
                  height: 90.01.h,
                  child: SvgPicture.asset(
                    AssetsManager.wallet,
                    fit: BoxFit.contain,
                    color: ColorManager.primary,
                  ),
                ),
                AppPadding.p16.ph,
                Text(
                  translate(AppStrings.paymentSuccessful),
                  style: AppStyles.title16Bold.copyWith(
                    color: ColorManager.black,
                  ),
                ),
                AppPadding.p12.ph,
                SizedBox(
                  width: 292.w,
                  child: Text(
                    isEnglish
                        ? "Your wallet has been topped up successfully"
                        : "تم شحن محفظتك بنجاح",
                    textAlign: TextAlign.center,
                    style: AppStyles.title16Regular.copyWith(
                      color: ColorManager.black,
                    ),
                  ),
                ),
                AppPadding.p32.ph,
                ButtonsShared(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    popALlAndPushPage(
                      context,
                      MainNavigationScreen(selectedIndex: 4),
                    );
                  },
                  text: translate(AppStrings.back),
                  width: 164.w,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
