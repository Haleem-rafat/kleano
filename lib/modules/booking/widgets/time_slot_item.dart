import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/modules/booking/data/models/booking_available_model.dart';
import 'package:thewasher/utilties/app_date_formatter.dart';

class TimeSlotItem extends StatelessWidget {
  final TimeSlot? timeSlot;
  final VoidCallback onTimeSelected;
  final bool isSelected;
  final bool isDisabled;

  const TimeSlotItem({
    super.key,
    this.timeSlot,
    required this.onTimeSelected,
    this.isSelected = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isDisabled ? null : onTimeSelected,
      child: SizedBox(
        width: 80.w,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isSelected ? ColorManager.secondary : ColorManager.divider2,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              AppDateFormatter.dateToStringHHMMA(timeSlot!.availableTime, "en"),
              style: AppStyles.body14Medium.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? ColorManager.white
                    : isDisabled
                        ? ColorManager.thirdColor400
                        : ColorManager.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
