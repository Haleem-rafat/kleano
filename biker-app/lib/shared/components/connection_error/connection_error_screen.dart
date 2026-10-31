
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/shared/components/buttons.dart';

class ConnectionErrorSharedScreen extends StatelessWidget {
  final VoidCallback onPressed;
  const ConnectionErrorSharedScreen({
    super.key,
    required this.onPressed,
    });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.darkStatusBarIconsWithWhiteColorStyle,
      child: Column(
        children: <Widget>[
          SizedBox(height: 220.h,),
         /* Lottie.asset(
              'assets/wifi.json',
              repeat: true,
              width: 250.w,
              height: 250.h,
            ),*/
          Text(
            translate(AppStrings.yourNotConnected),
            textAlign: TextAlign.center,
            style: AppStyles.titleGray16Regular.copyWith(
              color: ColorManager.darkGrey,)
          ),
          SizedBox(height: AppPadding.p50.h,),
          ButtonsShared(
            onPressed: onPressed, 
            width: 164.w,
            height: 50.h,
            borderRadius: 25,
            textStyle: AppStyles.title16Bold,
            text: translate(AppStrings.refresh),
            )
        ],
      ),
    );
  }
}