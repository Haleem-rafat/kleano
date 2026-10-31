import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/booking/widgets/add_services/change_location_button.dart';

class SubscriptionNotAvalibleLocation extends StatelessWidget {
  const SubscriptionNotAvalibleLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 25.h, 20.w, 25.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: ColorManager.red.withValues(alpha: .07),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 292.w,
            child: Text(
              translate(AppStrings.availableThisLocation),
              style: AppStyles.caption12Regular.copyWith(
                color: ColorManager.red,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: AppPadding.p16.h),
          const ButtonChangeLocation(),
        ],
      ),
    );
  }
}
