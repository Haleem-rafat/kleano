import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

class PriceAndPoints extends StatelessWidget {
  final int price;
  final String durationUnit;
  final int pointsToPay, duration;
  const PriceAndPoints({
    super.key,
    required this.price,
    required this.durationUnit,
    required this.pointsToPay,
    required this.duration,
  });

  getMonth(int duration) {
    if (duration == 1) {
      return translate(AppStrings.month);
    } else if (duration == 2) {
      return translate(AppStrings.months2);
    } else {
      return translate(AppStrings.months);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Row(
          children: [
            Text(
              '$price ',
              style: AppStyles.title16Bold.copyWith(
                color: const Color(0xFF2A2A2A),
              ),
            ),
            SvgPicture.asset(
              AssetsManager.saudiRiyalSymbol,
              height: 16.h,
              width: 16.w,
            ),
          ],
        ),
        duration == 1 && Localizations.localeOf(context).languageCode != 'en' ||
                duration == 2 &&
                    Localizations.localeOf(context).languageCode != 'en'
            ? Text(
                ' / ${getMonth(duration)}',
                style: AppStyles.body14Medium.copyWith(
                  color: ColorManager.darkGrey,
                ),
              )
            : Text(
                ' / $duration ${getMonth(duration)}',
                style: AppStyles.body14Medium.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
        // const Spacer(),
        // SvgPicture.asset(
        //   AssetsManager.singleCoin,
        //   height: 19.h,
        //   width: 19.w,
        // ),
        // 8.horizontalSpace,
        // Text(
        //   pointsToPay.toString(),
        //   style: AppStyles.title16Regular.copyWith(
        //     color: ColorManager.medGray,
        //   ),
        // ),
      ],
    );
  }
}
