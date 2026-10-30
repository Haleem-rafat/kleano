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
import 'package:thewasher/modules/booking/screens/payment_screen.dart';
import 'package:thewasher/modules/booking/screens/payment_type.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class CreateSubscription extends StatefulWidget {
  final double price;
  final String planType;
  final String planId;
  final String createdAt;
  const CreateSubscription({
    Key? key,
    required this.price,
    required this.planType,
    required this.createdAt,
    required this.planId,
  }) : super(key: key);

  @override
  State<CreateSubscription> createState() => _CreateSubscriptionState();
}

class _CreateSubscriptionState extends State<CreateSubscription> {
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
                14.76.w,
                17.81.h,
                14.76.w,
                41.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  24.verticalSpace,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${translate(AppStrings.youArePaying)} ${widget.price.toStringAsFixed(0)} ',
                        textAlign: TextAlign.center,
                        style: AppStyles.title16Medium.copyWith(
                          color: ColorManager.black,
                        ),
                      ),
                      SvgPicture.asset(
                        AssetsManager.saudiRiyalSymbol,
                        width: 16.w,
                        height: 16.h,
                      ),
                      Text(
                        ' ${widget.planType}',
                        textAlign: TextAlign.center,
                        style: AppStyles.title16Medium.copyWith(
                          color: ColorManager.black,
                        ),
                      ),
                    ],
                  ),

                  AppPadding.p24.ph,
                  ButtonsShared(
                    onPressed: () {
                      pop(context);
                      pushPage(
                          context,
                          SelectPaymentTypeScreen(
                            amount: widget.price,
                            createdAt: widget.createdAt,
                            planId: widget.planId,
                          ));
                    },
                    text: "Checkout",
                    width: 164.w,
                  ),

                  // BlocConsumer<PlansAndSubscriptionBloc,
                  //     PlansAndSubscriptionState>(
                  //   listener: (context, PlansAndSubscriptionState state) {
                  //     if (state is CreateSubscriptionFailed) {
                  //       pop(context);
                  //       showSnackBar(
                  //           buildContext: context,
                  //           message:
                  //               Localizations.localeOf(context).languageCode ==
                  //                       'ar'
                  //                   ? state.errorModel!.ar!
                  //                   : state.errorModel!.en!);
                  //     } else if (state is CreateSubscriptionSuccess) {
                  //       print('^^^^^^^${state.subscriptionId}');
                  //       pop(context);
                  //       AlertHelper.paymentAddCardSuccess(context);
                  //     }
                  //   },
                  //   builder: (context, state) {
                  //     if (state is CreateSubscriptionLoading) {
                  //       return const LoadingWidget();
                  //     }
                  //     return ButtonsShared(
                  //       onPressed: () {
                  //         pop(context);
                  //         pushPage(context, const SelectPaymentTypeScreen());
                  //         // pushPage(
                  //         //     context, PaymentScreen(planId: widget.planId));
                  //       },
                  //       text: translate(AppStrings.subscriptions),
                  //       width: 164.w,
                  //     );
                  //   },
                  // ),

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
