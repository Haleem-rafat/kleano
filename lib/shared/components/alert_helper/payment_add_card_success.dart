import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/Home/data/model/piked_model.dart';
import 'package:thewasher/modules/booking/screens/booking_main_screen.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class PaymentAddCardSuccess extends StatefulWidget {
  const PaymentAddCardSuccess({Key? key}) : super(key: key);

  @override
  State<PaymentAddCardSuccess> createState() => _PaymentAddCardSuccessState();
}

class _PaymentAddCardSuccessState extends State<PaymentAddCardSuccess> {
  @override
  void initState() {
    super.initState();
    // sl<GetUserProfileBloc>().add(GetUserProfileEvent());
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
    // PickedLocationModel location = sl<LocationBloc>.call().pickedLocationModel;

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
                        AssetsManager.paymentSuccess,
                        fit: BoxFit.contain,
                      )),
                  AppPadding.p16.ph,
                  Text(
                    translate(AppStrings.paymentSuccessful),
                    style: AppStyles.title16Bold
                        .copyWith(color: ColorManager.darkGrey),
                  ),
                  AppPadding.p12.ph,
                  SizedBox(
                    width: 292.w,
                    child: Text(
                      translate(AppStrings.thankYouForYouSubscribing),
                      textAlign: TextAlign.center,
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.darkGrey,
                      ),
                    ),
                  ),
                  AppPadding.p32.ph,
                  // BlocConsumer<PlansAndSubscriptionBloc,
                  //     PlansAndSubscriptionState>(
                  //   listener: (context, state) {
                  //     if (state is SubscriptioByLocationSuccessState) {
                  //       sl<OffersBloc>().add(GetAddOns(
                  //         lat: location.pickedLocationLat!,
                  //         lng: location.pickedLocationLng!,
                  //         country: location.pickedLocationCountry!,
                  //       ));
                  //       pushPage(context, const BookingMainScreen());
                  //     }
                  //   },
                  //   builder: (context, state) {
                  //     if (state is SubscriptionByLocationLoading) {
                  //       return const LoadingWidget();
                  //     }
                  //     return ButtonsShared(
                  //       onPressed: () {
                  //         print(
                  //             'isSubscribed!!!!!!!: ${profileState.userProfile.data!.isSubscribed}');
                  //         if (profileState.userProfile.data!.isSubscribed!) {
                  //           sl<PlansAndSubscriptionBloc>.call()
                  //               .add(GetSubscriptionUserByLocation(
                  //             latitude: location.pickedLocationLat!,
                  //             longitude: location.pickedLocationLng!,
                  //             country: location.pickedLocationCountry!,
                  //           ));
                  //         } else {
                  //           pushPage(context, const BookingMainScreen());
                  //         }
                  //       },
                  //       text: translate(AppStrings.orderFirstWash),
                  //       width: 164.w,
                  //     );
                  //   },
                  // ),
                  // AppPadding.p16.ph,
                  GestureDetector(
                    onTap: () {
                      popALlAndPushPage(
                          context, MainNavigationScreen(selectedIndex: 3));
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      translate(AppStrings.back),
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.primary,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              )),
        );
      },
    );

    // BlocBuilder<GetUserProfileBloc, GetUserProfileState>(
    //   builder: (context, profileState) {
    //     if (profileState is GetUserProfileLoading) {
    //       return const LoadingWidget();
    //     } else if (profileState is GetUserProfileSuccess) {
    //       return StatefulBuilder(
    //         builder: (BuildContext context, Function setState) {
    //           return ClipRRect(
    //             borderRadius: BorderRadius.circular(24.r),
    //             child: Container(
    //                 decoration: BoxDecoration(
    //                   color: ColorManager.white,
    //                   border: Border.all(color: ColorManager.darkGrey),
    //                 ),
    //                 padding: EdgeInsets.fromLTRB(
    //                   AppPadding.p12.w,
    //                   44.99.h,
    //                   AppPadding.p12.w,
    //                   44.h,
    //                 ),
    //                 child: Column(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: <Widget>[
    //                     SizedBox(
    //                         width: 85.5.w,
    //                         height: 90.01.h,
    //                         child: SvgPicture.asset(
    //                           AssetsManager.paymentSuccess,
    //                           fit: BoxFit.contain,
    //                         )),
    //                     AppPadding.p16.ph,
    //                     Text(
    //                       translate(AppStrings.paymentSuccessful),
    //                       style: AppStyles.title16Bold
    //                           .copyWith(color: ColorManager.darkGrey),
    //                     ),
    //                     AppPadding.p12.ph,
    //                     SizedBox(
    //                       width: 292.w,
    //                       child: Text(
    //                         translate(AppStrings.thankYouForYouSubscribing),
    //                         textAlign: TextAlign.center,
    //                         style: AppStyles.title16Regular.copyWith(
    //                           color: ColorManager.darkGrey,
    //                         ),
    //                       ),
    //                     ),
    //                     AppPadding.p32.ph,
    //                     BlocConsumer<PlansAndSubscriptionBloc,
    //                         PlansAndSubscriptionState>(
    //                       listener: (context, state) {
    //                         if (state is SubscriptioByLocationSuccessState) {
    //                           sl<OffersBloc>().add(GetAddOns(
    //                             lat: location.pickedLocationLat!,
    //                             lng: location.pickedLocationLng!,
    //                             country: location.pickedLocationCountry!,
    //                           ));
    //                           pushPage(context, const BookingMainScreen());
    //                         }
    //                       },
    //                       builder: (context, state) {
    //                         if (state is SubscriptionByLocationLoading) {
    //                           return const LoadingWidget();
    //                         }
    //                         return ButtonsShared(
    //                           onPressed: () {
    //                             print(
    //                                 'isSubscribed!!!!!!!: ${profileState.userProfile.data!.isSubscribed}');
    //                             if (profileState
    //                                 .userProfile.data!.isSubscribed!) {
    //                               sl<PlansAndSubscriptionBloc>.call()
    //                                   .add(GetSubscriptionUserByLocation(
    //                                 latitude: location.pickedLocationLat!,
    //                                 longitude: location.pickedLocationLng!,
    //                                 country: location.pickedLocationCountry!,
    //                               ));
    //                             } else {
    //                               pushPage(context, const BookingMainScreen());
    //                             }
    //                           },
    //                           text: translate(AppStrings.orderFirstWash),
    //                           width: 164.w,
    //                         );
    //                       },
    //                     ),
    //                     AppPadding.p16.ph,
    //                     GestureDetector(
    //                       onTap: () {
    //                         pop(context);
    //                       },
    //                       behavior: HitTestBehavior.opaque,
    //                       child: Text(
    //                         translate(AppStrings.notNow),
    //                         style: AppStyles.title16Regular.copyWith(
    //                           color: ColorManager.primary,
    //                           decoration: TextDecoration.underline,
    //                           fontWeight: FontWeight.w500,
    //                         ),
    //                       ),
    //                     ),
    //                   ],
    //                 )),
    //           );
    //         },
    //       );
    //     } else {
    //       return const SizedBox();
    //     }
    //     return const SizedBox();
    //   },
    // );
  }
}
