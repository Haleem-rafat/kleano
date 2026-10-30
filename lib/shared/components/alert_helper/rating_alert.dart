import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/delayed_methods.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/rating_bar.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

class RatingOrderAlert extends StatelessWidget {
  final String? orderId;
  RatingOrderAlert({
    super.key,
    required this.orderId,
  });

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

  GeneralSingleton generalSingleton = GeneralSingleton();

  double ratingCount = 0.0;
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
                8.44.w,
                7.h,
                8.44.w,
                47.29.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 316.w,
                    height: 95.h,
                    child: Stack(alignment: Alignment.bottomCenter, children: [
                      Positioned(
                          top: 0.h,
                          left: 0.w,
                          child: SvgPicture.asset(AssetsManager.layoutAlert)),
                      Text(
                        translate(AppStrings.howWasYourExperience),
                        style: AppStyles.title16Bold.copyWith(
                          color: ColorManager.darkGrey,
                        ),
                      ),
                    ]),
                  ),
                  AppPadding.p16.ph,
                  SizedBox(
                    width: 212.w,
                    child: Text(
                      translate(AppStrings
                          .pleaseLeaveYourReviewWeAppreciateYourFeedback),
                      textAlign: TextAlign.center,
                      style: AppStyles.caption12Regular.copyWith(
                        color: ColorManager.darkGrey,
                      ),
                    ),
                  ),
                  AppPadding.p32.ph,
                  RatingBarShared(
                    ratingCount: 0.0,
                    itemSize: 24.r,
                    onRatingUpdate: (rating) {
                      setState(() {
                        ratingCount = rating;
                      });
                    },
                  ),
                  AppPadding.p32.ph,
                  BlocConsumer<BookingOrderBloc, BookingOrderState>(
                    listener: (context, state) {
                      if (state is RateOrderFailed) {
                        showSnackBar(
                            buildContext: context,
                            message: state.error != null
                                ? state.error!
                                : Localizations.localeOf(context)
                                            .languageCode ==
                                        'en'
                                    ? state.errorModel!.en!
                                    : state.errorModel!.ar!);
                      } else if (state is RateOrderSuccess) {
                        AlertHelper.feedbackSuccess(context);
                        if (generalSingleton.openTracking) {
                          delayedExecution(
                            context,
                            const Duration(milliseconds: 800),
                            () => popALlAndPushPage(context,
                                MainNavigationScreen(selectedIndex: 0)),
                          );
                        } else {
                          sl<BookingOrderBloc>()
                              .add(GetOrderById(orderId: orderId!));
                          delayedExecution(
                            context,
                            const Duration(milliseconds: 800),
                            () => popScreen(context, 2),
                          );
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is RateOrderLoading) {
                        return const LoadingWidget();
                      }
                      return ButtonsShared(
                        onPressed: () {
                          ratingCount != 0.0
                              ? sl.call<BookingOrderBloc>.call().add(RateOrder(
                                  orderId: orderId!, starsNum: ratingCount))
                              : null;
                        },
                        text: translate(AppStrings.submitFeedback),
                      );
                    },
                  ),
                  AppPadding.p24.ph,
                  GestureDetector(
                    onTap: () => pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      translate(AppStrings.skipForNow),
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
