import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/screens/wash_details.dart';
import 'package:thewasher/modules/my_booking/widgets/button_shap.dart';
import 'package:thewasher/modules/my_booking/widgets/button_tracking.dart';
import 'package:thewasher/shared/components/vehicle_card_data.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

class MyBookingCard extends StatelessWidget {
  final OrderModel order;
  final bool isActive;
  MyBookingCard({
    super.key,
    required this.order,
    this.isActive = false,
  });
  final GeneralSingleton generalSingleton = GeneralSingleton();
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: ColorManager.black.withValues(alpha: .05),
              blurRadius: 6.r,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          AppPadding.p16.w,
          AppPadding.p10.h,
          AppPadding.p16.w,
          AppPadding.p12.h,
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppPadding.p28.w,
          vertical: 8.5.h,
        ),
        child: Column(
          children: <Widget>[
            if (order.vehicle != null)
              VechicleCardData(
                vehicle: order.vehicle!,
                isScheduled: order.isScheduled ?? false,
                bookingDate: order.createdAt != null
                    ? DateTime.parse(order.createdAt!).toLocal()
                    : DateTime.now(),
                washingDate: order.startTime != null
                    ? DateTime.parse(order.startTime!).toLocal()
                    : null,
              ),
            AppPadding.p8.ph,
            // Status and Payment Type Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Badge
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status ?? ''),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    statusText(order.status ?? ''),
                    style: AppStyles.caption12Regular.copyWith(
                      color: _getStatusTextColor(order.status ?? ''),
                      fontSize: 10.sp,
                    ),
                  ),
                ),
                // Payment Type
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: ColorManager.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    _getPaymentTypeText(order.paymentType ?? ''),
                    style: AppStyles.caption12Regular.copyWith(
                      color: ColorManager.primary,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ),
            AppPadding.p8.ph,
            Row(
              children: <Widget>[
                ButtonShap(
                  onTap: () {
                    if (order.sId != null) {
                      pushPage(
                        context,
                        WashDetailsScreen(
                          orderId: order.sId!,
                        ),
                      );
                    }
                  },
                  text: translate(AppStrings.viewDetails),
                ),
              ],
            ),
            if (isActive) AppPadding.p8.ph,
            if (isActive && order.status == AppConstants.bikerOnTheWay)
              ButtonTrackingOrder(
                orderModel: order,
              )
          ],
        ));
  }

  // Helper methods for status display
  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING_USER_PAYMENT':
        return const Color.fromRGBO(255, 193, 7, 0.1);
      case 'PENDING_USER_REVIEW':
        return const Color.fromRGBO(255, 193, 7, 0.1);
      case 'ACTIVE':
        return const Color.fromRGBO(76, 175, 80, 0.1);
      case 'CANCELLED_BY_USER':
        return Colors.red.withValues(alpha: 0.1);
      case 'CANCELLED_BY_ADMIN':
        return Colors.red.withValues(alpha: 0.1);
      case 'ACCEPTED_BY_BIKER':
        return const Color.fromRGBO(111, 251, 76, 0.1);
      case 'WAITING_FOR_BIKER_BY_ADMIN':
        return const Color.fromRGBO(33, 150, 243, 0.1);
      case 'BIKER_ON_THE_WAY':
        return const Color.fromRGBO(103, 135, 198, 0.1);
      case 'CANCELLED_BY_BIKER':
        return Colors.red.withValues(alpha: 0.1);
      case 'BIKER_ARRIVED':
        return const Color.fromRGBO(251, 174, 76, 0.1);
      case 'ON_WASHING':
        return const Color.fromRGBO(255, 228, 54, 0.1);
      case 'COMPLETED':
        return const Color.fromRGBO(245, 240, 250, 1);
      case 'SCHEDULED':
        return const Color.fromRGBO(156, 39, 176, 0.1);
      default:
        return ColorManager.divider;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'PENDING_USER_PAYMENT':
        return const Color.fromRGBO(255, 152, 0, 1);
      case 'PENDING_USER_REVIEW':
        return const Color.fromRGBO(255, 152, 0, 1);
      case 'ACTIVE':
        return const Color.fromRGBO(76, 175, 80, 1);
      case 'CANCELLED_BY_USER':
        return Colors.red;
      case 'CANCELLED_BY_ADMIN':
        return Colors.red;
      case 'ACCEPTED_BY_BIKER':
        return const Color.fromRGBO(28, 127, 84, 1);
      case 'WAITING_FOR_BIKER_BY_ADMIN':
        return const Color.fromRGBO(33, 150, 243, 1);
      case 'BIKER_ON_THE_WAY':
        return const Color.fromRGBO(225, 111, 0, 1);
      case 'CANCELLED_BY_BIKER':
        return Colors.red;
      case 'BIKER_ARRIVED':
        return ColorManager.darkGrey;
      case 'ON_WASHING':
        return ColorManager.darkGrey;
      case 'COMPLETED':
        return ColorManager.primary;
      case 'SCHEDULED':
        return const Color.fromRGBO(156, 39, 176, 1);
      default:
        return ColorManager.divider;
    }
  }

  static String statusText(String status) {
    switch (status) {
      case 'PENDING_USER_PAYMENT':
        return translate(AppStrings.pendingPayment);
      case 'PENDING_USER_REVIEW':
        return translate(AppStrings.pendingReview);
      case 'ACTIVE':
        return translate(AppStrings.active);
      case 'CANCELLED_BY_USER':
        return translate(AppStrings.cancelledByUser);
      case 'CANCELLED_BY_ADMIN':
        return translate(AppStrings.cancelledByAdmin);
      case 'ACCEPTED_BY_BIKER':
        return translate(AppStrings.accepted);
      case 'WAITING_FOR_BIKER_BY_ADMIN':
        return translate(AppStrings.waitingForBiker);
      case 'BIKER_ON_THE_WAY':
        return translate(AppStrings.onTheWay);
      case 'CANCELLED_BY_BIKER':
        return translate(AppStrings.cancelledByBiker);
      case 'BIKER_ARRIVED':
        return translate(AppStrings.arrived);
      case 'ON_WASHING':
        return translate(AppStrings.inProgress);
      case 'COMPLETED':
        return translate(AppStrings.ended);
      case 'SCHEDULED':
        return translate(AppStrings.schedule);
      default:
        return status;
    }
  }

  // Helper method for payment type display
  String _getPaymentTypeText(String paymentType) {
    switch (paymentType) {
      case 'WALLET':
        return translate(AppStrings.wallet);
      case 'CREDIT':
        return translate(AppStrings.creditCards);
      case 'SUBSCRIBED':
        return translate(AppStrings.subscribed);
      case 'APPLE_PAY':
        return translate(AppStrings.applePay);
        case 'FREE':
        return translate(AppStrings.free);
      default:
        return paymentType;
    }
  }
}
