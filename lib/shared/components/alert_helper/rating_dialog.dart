import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/order/bloc/order_bloc.dart';
import 'package:thewhsherbiker/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewhsherbiker/shared/components/buttons.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/components/rating_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class RatingOrderAlert extends StatefulWidget {
  final String? orderId;
  const RatingOrderAlert({
    super.key,
    required this.orderId,
  });

  @override
  State<RatingOrderAlert> createState() => _RatingOrderAlertState();
}

class _RatingOrderAlertState extends State<RatingOrderAlert> {
  double ratingCount = 0.0;

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

  ClipRRect _buildChild(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
          decoration: BoxDecoration(
            color: ColorManager.white,
            border: Border.all(color: ColorManager.darkGrey),
          ),
          padding: EdgeInsets.fromLTRB(
            20.w,
            47.29.h,
            20.w,
            47.29.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                translate(AppStrings.washCompletedSuccessfully),
                style: AppStyles.title16Bold.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
              Text(
                translate(AppStrings.howWasYourClient),
                style: AppStyles.title16Bold.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
              16.verticalSpace,
              SizedBox(
                width: 212.w,
                child: Text(
                  translate(AppStrings.leaveReview),
                  textAlign: TextAlign.center,
                  style: AppStyles.caption12Regular.copyWith(
                    color: ColorManager.darkGrey,
                  ),
                ),
              ),
              32.verticalSpace,
              RatingBarShared(
                ratingCount: ratingCount,
                itemSize: 24.r,
                onRatingUpdate: (double rating) {
                  setState(() {
                    ratingCount = rating;
                  });
                },
              ),
              32.verticalSpace,
              BlocConsumer<OrderBloc, OrderState>(
                listener: (BuildContext context, OrderState state) {
                  if (state is OrderRatingSuccess) {
                    pop(context);
                    AlertHelper.ratingSuccess(context);
                  }
                },
                builder: (BuildContext context, OrderState state) {
                  if (state is OrderRatingLoading) {
                    return LoadingWidget();
                  } else {
                    return ButtonsShared(
                      onPressed: () {
                        if (ratingCount != 0.0) {
                          debugPrint("lllll ${sl<OrderBloc>().starsNum}");
                          sl<OrderBloc>().add(BikerRating(
                            starsNum: ratingCount,
                            orderId: widget.orderId!,
                          ));
                        }
                      },
                      text: translate(AppStrings.submitFeedback),
                      borderRadius: 8,
                      textStyle: AppStyles.titleWhite16Bold,
                    );
                  }
                },
              ),
            ],
          )),
    );
  }
}
