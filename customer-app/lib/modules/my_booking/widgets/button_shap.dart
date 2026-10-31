
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class ButtonShap extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? color;
  const ButtonShap({
    super.key,
    required this.text,
    required this.onTap,
    this.color = ColorManager.white,
    });

  @override
  Widget build(BuildContext context) {
    return  Expanded(
           child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
             child: Container(
               height: 30.h,
               decoration: BoxDecoration(
                 border: Border.all(color: ColorManager.primary),
                 borderRadius: BorderRadius.circular(8.r),
                 color: color
                 ),
                 child: Center(
                  child: Text(
                    text,
                    style: AppStyles.body14Medium.copyWith(color: ColorManager.primary),
                    )
                  ),
               ),
           ),
           );
  }
}