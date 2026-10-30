import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/functions/check_step_data.dart';

class StateOfStatusOrder extends StatelessWidget {
  final String status;
  const StateOfStatusOrder({
    super.key,
    required this.status,
  });
  @override
  Widget build(BuildContext context) {
   Tuple4 stepData = getStepData(status);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 17.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: stepData.value1,
      ),
      child: Text(
        stepData.value2,
        style: AppStyles.caption12Regular.copyWith(color: stepData.value3, fontSize: 10.sp),
      ),
    );
  }
}
