import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/fonts_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';

class DateJoinedContainer extends StatelessWidget {
  final String timeCreateAt;
  const DateJoinedContainer({Key? key, required this.timeCreateAt})
      : super(key: key);

  String _formatDate(String dateString) {
    try {
      // Parse the date string (format: dd/M/yyyy)
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final date = DateTime(year, month, day);

        // Format as "dd MMM yyyy" (e.g., "11 Sep 2025")
        return DateFormat('dd MMM yyyy', 'en').format(date);
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  String _calculateDuration(BuildContext context, String dateString) {
    try {
      final parts = dateString.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final joinDate = DateTime(year, month, day);
        final now = DateTime.now();
        final difference = now.difference(joinDate);
        final days = difference.inDays;

        if (days < 30) {
          return '$days ${days == 1 ? translate(AppStrings.day) : translate(AppStrings.days)}';
        } else if (days < 365) {
          final months = (days / 30).floor();
          return '$months ${months == 1 ? translate(AppStrings.month) : translate(AppStrings.months)}';
        } else {
          final years = (days / 365).floor();
          final remainingMonths = ((days % 365) / 30).floor();
          if (remainingMonths > 0) {
            return '$years ${years == 1 ? translate(AppStrings.year) : translate(AppStrings.years)} $remainingMonths ${remainingMonths == 1 ? translate(AppStrings.month) : translate(AppStrings.months)}';
          }
          return '$years ${years == 1 ? translate(AppStrings.year) : translate(AppStrings.years)}';
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatDate(timeCreateAt);
    final duration = _calculateDuration(context, timeCreateAt);

    return Container(
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: const BorderRadius.all(Radius.circular(AppSize.s12)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorManager.black.withOpacity(.06),
            blurRadius: 6.r,
            offset: const Offset(0, 3),
          )
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(ImageAssets.joinedLogo),
              SizedBox(width: 6.w),
              Text(
                translate(AppStrings.dateJoined),
                style: AppStyles.title16Regular.copyWith(
                  color: ColorManager.medGray,
                  fontSize: FontSize.s12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          14.verticalSpace,
          Container(
            height: 1.h,
            color: ColorManager.divider,
            width: double.infinity,
          ),
          14.verticalSpace,
          Column(
            children: <Widget>[
              Text(
                formattedDate,
                style: AppStyles.body14Medium.copyWith(
                  color: ColorManager.darkGrey,
                  fontSize: FontSize.s16.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (duration.isNotEmpty) ...[
                6.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: ColorManager.medGray,
                    ),
                    4.horizontalSpace,
                    Text(
                      '${translate(AppStrings.memberSince)} $duration',
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.medGray,
                        fontSize: FontSize.s10.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
