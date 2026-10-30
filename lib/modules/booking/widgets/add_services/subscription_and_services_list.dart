import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/booking/widgets/add_services/plan_notavalible_location.dart';
import 'package:thewasher/modules/booking/widgets/add_services/services_list.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/subscription_model.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/card_plan.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class SubscriptionAndService extends StatelessWidget {
  final Subscription subscription;
  final String message;

  const SubscriptionAndService({
    super.key,
    required this.subscription,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    bool showServicesList =
        sl.call<OffersBloc>.call().cartServicesList.isNotEmpty ? true : false;
    return StatefulBuilder(
      builder: (context, myState) {
        return Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: AppPadding.p16.h,
                left: AppPadding.p24.w,
                right: AppPadding.p24.w,
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    '${subscription.plan!.type} ',
                    style: AppStyles.title16Bold.copyWith(
                      color: ColorManager.darkGrey,
                    ),
                  ),
                  Text(
                    '${translate(AppStrings.remainingWashes)}(${subscription.remainingWashes}/${subscription.washesCount} ${translate(AppStrings.washes)})',
                    style: AppStyles.subtext14Regular.copyWith(
                      color: ColorManager.medGray,
                    ),
                  ),
                ],
              ),
            ),
            CardOfPlan(
                plan: subscription.plan!,
                userHaveAPlan: true,
                showExpandableContent: false,
                comeformBooking: true),
            message.isNotEmpty
                ? const SubscriptionNotAvalibleLocation()
                : const SizedBox(),
            if (!showServicesList)
              SizedBox(height: 100.h), // Replace Spacer with fixed height
            !showServicesList
                ? Column(
                    children: <Widget>[
                      ButtonDottedShared(
                        disable: message.isNotEmpty ? true : false,
                        onPressed: () {
                          message.isEmpty
                              ? myState(() {
                                  showServicesList = true;
                                })
                              : null;
                        },
                        text: translate(AppStrings.addExtraServices),
                      ),
                      SizedBox(
                        height: AppPadding.p16.h,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: AppPadding.p16.h),
                        child: Align(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            textBaseline: TextBaseline.alphabetic,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.info_outline,
                                color: ColorManager.black,
                                size: 15.r,
                              ),
                              SizedBox(
                                width: 5.w,
                              ),
                              SizedBox(
                                width: 296.w,
                                child: Text(
                                  translate(AppStrings
                                      .notAlreadyPartOfYourSubscription),
                                  textAlign: TextAlign.center,
                                  style: AppStyles.caption12Regular.copyWith(
                                    color: ColorManager.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                : const ServicesList()
          ],
        );
      },
    );
  }
}
