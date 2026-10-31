import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class CreationStepIndicator extends StatelessWidget {
  final int step;
  final double stepWidth;

  CreationStepIndicator({required this.step, super.key})
    : stepWidth =
          (350 - ((accountCreationStepCount - 1) * 10.5)) /
          accountCreationStepCount;

  static const int accountCreationStepCount = 5;

  int? currentIndex;
  Color getStepColor(int index) {
    if (step == index) {
      return ColorManager.secondary;
    } else if (step < index) {
      return ColorManager.divider;
    } else {
      return ColorManager.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 40.h,
        width: 330.w,
        child: ListView.builder(
          itemCount: accountCreationStepCount,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, int index) {
            return Row(
              children: [
                Container(
                  height: 20.h,
                  width: 20.w,
                  decoration: BoxDecoration(
                    color: getStepColor(index),
                    shape: BoxShape.circle,
                  ),
                ),
                if (index != accountCreationStepCount - 1)
                  Container(
                    height: 4.h,
                    width: 57.w,
                    color: getStepColor(index + 1),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
