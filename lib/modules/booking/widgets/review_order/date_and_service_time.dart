import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/utilties/app_date_formatter.dart';

class DateAndServiceTime extends StatelessWidget {
  final String startTime;
  final String createdAt;
  final int totalDuration;
  final bool isScheduled;
  const DateAndServiceTime({
    super.key,
    required this.startTime,
    required this.createdAt,
    required this.totalDuration,
    required this.isScheduled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppPadding.p18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            translate(AppStrings.dateTime),
            style: AppStyles.title16Bold.copyWith(color: ColorManager.darkGrey),
          ),
          AppPadding.p8.ph,
          Text(_formatDate(), style: AppStyles.subtextGray14Regular),
          AppPadding.p18.ph,
          Text(
            translate(AppStrings.serviceTime),
            style: AppStyles.title16Bold.copyWith(color: ColorManager.darkGrey),
          ),
          AppPadding.p8.ph,
          Text(
            '$totalDuration ${translate(AppStrings.min)} ${translate(AppStrings.total)}',
            style: AppStyles.subtextGray14Regular,
          ),
        ],
      ),
    );
  }

  String _formatDate() {
    final date = DateTime.parse(isScheduled ? createdAt : startTime);
    final dayMonth = AppDateFormatter.dayAndMonth(date);
    final time = AppDateFormatter.dateToStringHHMMA(date);

    return isScheduled
        ? '${translate(AppStrings.today)} $dayMonth $time'
        : '$dayMonth $time';
  }
}
