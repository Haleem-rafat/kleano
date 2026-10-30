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
import 'package:thewasher/modules/profile/widgets/button_use_promo.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/utilties/order_utils.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class OrderSuccess extends StatefulWidget {
  const OrderSuccess({super.key});

  @override
  State<OrderSuccess> createState() => _OrderSuccessState();
}

class _OrderSuccessState extends State<OrderSuccess> {
  @override
  void initState() {
    sl<GetUserProfileBloc>().add(GetUserProfileEvent());
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
                AppPadding.p12.w,
                44.99.h,
                AppPadding.p12.w,
                35.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      width: 85.5.w,
                      height: 90.01.h,
                      child: SvgPicture.asset(
                        AssetsManager.paymentSuccess,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(ColorManager.black, BlendMode.srcIn),
                      )),
                  AppPadding.p16.ph,
                  Text(
                    translate(AppStrings.weAreOnIt),
                    style: AppStyles.title16Bold
                        .copyWith(color: ColorManager.black),
                  ),
                  AppPadding.p12.ph,
                  SizedBox(
                    width: 284.w,
                    child: Text(
                      translate(AppStrings.yourOderConfirmedTakYourOder),
                      textAlign: TextAlign.center,
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.black,
                      ),
                    ),
                  ),
                  AppPadding.p32.ph,
                  ButtonsShared(
                      onPressed: () {
                        // Clear all order details after payment completion
                        clearAllOrderDetails();
                        copiedPromoCode = null;
                        popALlAndPushPage(
                            context,
                            MainNavigationScreen(
                              selectedIndex: 2,
                            ));
                      },
                      text: translate(AppStrings.goToOrders)),
                ],
              )),
        );
      },
    );
  }
}
