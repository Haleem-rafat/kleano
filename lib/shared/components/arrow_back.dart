
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class ArrowBackShared extends StatelessWidget {
  const ArrowBackShared({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
             onTap: ()=> pop(context),
             child: Icon(
               Icons.arrow_back_ios,
               size: AppSize.s24.r,
               color: ColorManager.primary,
             ),
           );
  }
}