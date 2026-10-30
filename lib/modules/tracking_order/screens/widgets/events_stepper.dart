import 'package:avatar_glow/avatar_glow.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/functions/check_step_data.dart';

class EventsStepper extends StatelessWidget {
  final String? status;
  const EventsStepper({
    super.key,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    Tuple4 stepData = getStepData(status!);
    int step = stepData.value4;

    Color getStepColor(int index) {
      if (step == index) {
        return ColorManager.secondary;
      } else if (step > index) {
        return ColorManager.secondary;
      } else {
        return ColorManager.divider;
      }
    }

    return SizedBox(
      height: 300.h,
      width: 26.w,
      child: ListView.builder(
        itemCount: 4,
        padding: EdgeInsets.zero,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, int index) {
          return Column(
            children: <Widget>[
              SizedBox(
                height: 20.h,
                width: 20.w,
                child: step + 1 == index
                    ? AvatarGlow(
                        // endRadius: 20.0,

                        glowColor: ColorManager.secondary,
                        animate: true,
                        duration: const Duration(milliseconds: 2000),
                        repeat: true,
                        child: Container(
                          height: 20.h,
                          width: 20.w,
                          decoration: BoxDecoration(
                            color: ColorManager.primary.withOpacity(.5),
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : Container(
                        height: 20.h,
                        width: 20.w,
                        decoration: BoxDecoration(
                          color: getStepColor(index),
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
              if (index != 3)
                Container(
                  height: 57.h,
                  width: 4.w,
                  color: getStepColor(index),
                )
            ],
          );
        },
      ),
    );
  }
}
