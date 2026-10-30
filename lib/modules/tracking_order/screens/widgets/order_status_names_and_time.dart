import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class OrderStutesNamesAndTime extends StatelessWidget {
  const OrderStutesNamesAndTime({
    super.key,
    required this.bikerStatesName,
    required this.estimatedTimeBikerStates,
  });

  final List<String> bikerStatesName;
  final List<String> estimatedTimeBikerStates;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330.h,
      width: 200.w,
      child: ListView.separated(
        itemCount: 4,
        padding: EdgeInsets.zero,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, index) {
          return 45.ph;
        },
        itemBuilder: (_, int index) {
          return SizedBox(
            height: 38.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bikerStatesName[index],
                  style: AppStyles.caption12Regular.copyWith(
                    color: ColorManager.darkGrey,
                  ),
                ),
                Expanded(
                  child: Text(
                    estimatedTimeBikerStates[index],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: AppStyles.caption12Regular.copyWith(
                      color: ColorManager.medGray,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
