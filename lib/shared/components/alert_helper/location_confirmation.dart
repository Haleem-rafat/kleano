import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/data/model/piked_model.dart';
import 'package:thewasher/modules/booking/screens/booking_main_screen.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class LocationConfirmation extends StatefulWidget {
  const LocationConfirmation({
    Key? key,
  }) : super(key: key);

  @override
  State<LocationConfirmation> createState() => _LocationConfirmationState();
}

class _LocationConfirmationState extends State<LocationConfirmation> {
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
    PickedLocationModel location = sl<LocationBloc>.call().pickedLocationModel;

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
                16.w,
                16.h,
                16.w,
                32.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Lottie.asset('assets/car_lottie.json',
                      repeat: true, width: 176.w, height: 112.h),
                  AppPadding.p30.ph,
                  SizedBox(
                    width: 266.w,
                    child: Text(
                      translate(AppStrings.yourSureYouLocation),
                      textAlign: TextAlign.center,
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.black,
                      ),
                    ),
                  ),
                  48.verticalSpace,
                  BlocConsumer<PlansAndSubscriptionBloc,
                      PlansAndSubscriptionState>(
                    listener: (context, state) {
                      if (state is SubscriptioByLocationSuccessState) {
                        pushPage(context, const BookingMainScreen());
                      }
                      if (state is SubscriptionByLocationFailed) {
                        pop(context);
                        showSnackBar(
                            buildContext: context, message: state.error);
                      }
                    },
                    builder: (context, state) {
                      if (state is SubscriptionByLocationLoading) {
                        return const LoadingWidget();
                      }
                      // return GestureDetector(
                      //   onTap: () {
                      //     if (sl<GetUserProfileBloc>.call().profile.isSubscribed!) {
                      //       sl<PlansAndSubscriptionBloc>.call().add(GetSubscriptionUserByLocation(
                      //         latitude: location.pickedLocationLat!,
                      //         longitude: location.pickedLocationLng!,
                      //         country: location.pickedLocationCountry!,
                      //       ));
                      //     } else {
                      //       pushPage(context, const BookingMainScreen());
                      //     }
                      //   },
                      //   child: Text(
                      //     translate(AppStrings.continueText),
                      //     style: AppStyles.title16Regular.copyWith(
                      //       color: ColorManager.primary,
                      //       decoration: TextDecoration.underline,
                      //       decorationColor: ColorManager.primary,
                      //       fontWeight: FontWeight.w500,
                      //     ),
                      //   ),
                      // );
                      return ButtonsShared(
                          onPressed: () {
                            print(
                                '________${context.read<GetUserProfileBloc>.call().profile.isSubscribed!}');
                            if (context.read<GetUserProfileBloc>.call()
                                .profile
                                .isSubscribed!) {
                              context.read<PlansAndSubscriptionBloc>.call()
                                  .add(GetSubscriptionUserByLocation(
                                latitude: location.pickedLocationLat!,
                                longitude: location.pickedLocationLng!,
                                country: location.pickedLocationCountry!,
                              ));
                            } else {
                              pushPage(context, const BookingMainScreen());
                            }
                          },
                          width: 220,
                          text: translate(AppStrings.continueText));
                    },
                  ),
                  32.verticalSpace,
                  GestureDetector(
                    onTap: () => pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      translate(AppStrings.changeLocation),
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.primary,
                        decorationColor: ColorManager.primary,
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
