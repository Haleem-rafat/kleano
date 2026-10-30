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
import 'package:thewasher/modules/profile/blocs/delete_user_account/delete_user_account_bloc.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/utilties/navigator.dart';

class CancelBooking extends StatefulWidget {
  final String orderId;
  final bool? comeFromWashDetails;
  const CancelBooking({
    super.key,
    required this.orderId,
    this.comeFromWashDetails = false,
  });

  @override
  State<CancelBooking> createState() => _CancelBookingState();
}

class _CancelBookingState extends State<CancelBooking> {
  late DeleteUserAccountBloc deleteUserAccountBloc;
  @override
  void initState() {
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
                12.w,
                59.h,
                12.w,
                29.78.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SvgPicture.asset(AssetsManager.cancelBooking),
                  AppPadding.p14.ph,
                  SizedBox(
                    width: 178.w,
                    child: Text(
                      translate(AppStrings.areYouSureCancelOrder),
                      textAlign: TextAlign.center,
                      style: AppStyles.title16Bold.copyWith(
                        color: ColorManager.darkGrey,
                      ),
                    ),
                  ),
                  AppPadding.p14.ph,
                  SizedBox(
                    width: 292.w,
                    child: Text(
                      translate(AppStrings.onceYourOrderIsCancelled),
                      textAlign: TextAlign.center,
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.darkGrey,
                      ),
                    ),
                  ),
                  AppSize.s40.ph,
                  BlocConsumer<BookingOrderBloc, BookingOrderState>(
                    listener: (BuildContext context, BookingOrderState state) {
                      if (state is CancelOrderSuccess) {
                        if (widget.comeFromWashDetails == true) {
                          pop(context);
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return _buildSuccessDialog(context);
                              });
                        } else {
                          popALlAndPushPage(
                              context,
                              MainNavigationScreen(
                                selectedIndex: 0,
                              ));
                        }
                      } else if (state is CancelOrderFailed) {
                        pop(context);
                        _showErrorDialog(context);
                      }
                    },
                    builder: (context, state) {
                      if (state is CancelOrderLoading) {
                        return Container(
                          height: 50.h,
                          child: Column(
                            children: [
                              const LoadingWidget(),
                              8.verticalSpace,
                              Text(
                                Localizations.localeOf(context).languageCode ==
                                        "en"
                                    ? "Cancelling order..."
                                    : "جاري إلغاء الطلب...",
                                style: AppStyles.subtext14Regular.copyWith(
                                  color: ColorManager.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: ButtonsShared(
                          width: 220,
                          onPressed: () {
                            context.read<BookingOrderBloc>.call()
                                .add(CancelOrder(orderId: widget.orderId));
                          },
                          text: translate(AppStrings.cancelOrder),
                          colorButton: ColorManager.red,
                          colorBorder: ColorManager.red,
                        ),
                      );
                    },
                  ),
                  24.5.verticalSpace,
                  GestureDetector(
                    onTap: () => pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      translate(AppStrings.back),
                      style: AppStyles.title16Regular.copyWith(
                          color: ColorManager.primary,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                          decorationColor: ColorManager.primary),
                    ),
                  )
                ],
              )),
        );
      },
    );
  }

  Widget _buildSuccessDialog(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == "en";

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      elevation: 0.6,
      backgroundColor: Colors.transparent,
      insetAnimationCurve: Curves.elasticOut,
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon with Animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: ColorManager.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      size: 50.w,
                      color: ColorManager.green,
                    ),
                  ),
                );
              },
            ),
            24.verticalSpace,

            // Success Title
            Text(
              isEnglish
                  ? "Order Cancelled Successfully!"
                  : "تم إلغاء الطلب بنجاح!",
              textAlign: TextAlign.center,
              style: AppStyles.title16Bold.copyWith(
                color: ColorManager.darkGrey,
              ),
            ),
            16.verticalSpace,

            // Success Message
            Text(
              isEnglish
                  ? "The order is cancelled and we will refund your money"
                  : "تم إلغاء الطلب وسنقوم بإعادة المال",
              textAlign: TextAlign.center,
              style: AppStyles.subtext14Regular.copyWith(
                color: ColorManager.darkGrey,
                height: 1.5,
              ),
            ),
            32.verticalSpace,

            // OK Button
            ButtonsShared(
              width: 180.w,
              onPressed: () {
                pop(context);
                if (widget.comeFromWashDetails == true) {
                  pop(context); // Close the wash details screen too
                }
              },
              text: isEnglish ? "OK" : "حسناً",
              colorButton: ColorManager.primary,
              colorBorder: ColorManager.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == "en";

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          elevation: 0.6,
          backgroundColor: Colors.transparent,
          insetAnimationCurve: Curves.elasticOut,
          child: Container(
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: ColorManager.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 50.w,
                    color: ColorManager.red,
                  ),
                ),
                24.verticalSpace,

                // Error Title
                Text(
                  isEnglish ? "Failed to Cancel Order" : "فشل إلغاء الطلب",
                  textAlign: TextAlign.center,
                  style: AppStyles.title16Bold.copyWith(
                    color: ColorManager.darkGrey,
                  ),
                ),
                16.verticalSpace,

                // Error Message
                Text(
                  isEnglish
                      ? "Something went wrong while cancelling your order. Please try again or contact support."
                      : "حدث خطأ أثناء إلغاء طلبك. يرجى المحاولة مرة أخرى أو الاتصال بالدعم.",
                  textAlign: TextAlign.center,
                  style: AppStyles.subtext14Regular.copyWith(
                    color: ColorManager.darkGrey,
                    height: 1.5,
                  ),
                ),
                32.verticalSpace,

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ButtonsShared(
                        width: double.infinity,
                        onPressed: () => pop(context),
                        text: isEnglish ? "Try Again" : "حاول مرة أخرى",
                        colorButton: ColorManager.primary,
                        colorBorder: ColorManager.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
