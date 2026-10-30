import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/fonts_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';

class CommissionContainer extends StatelessWidget {
  final String? commission;
  final String? minimumCommission;
  final String? ordersBeforeCommission;
  const CommissionContainer({
    Key? key,
    this.commission,
    this.minimumCommission,
    this.ordersBeforeCommission,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset(ImageAssets.walletCoin),
              SizedBox(width: 6.w),
              Text(
                translate(AppStrings.commission),
                style: AppStyles.title16Regular.copyWith(
                  color: ColorManager.medGray,
                  fontSize: FontSize.s12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Container(
            height: 1.h,
            color: ColorManager.divider,
            width: double.infinity,
          ),
          12.verticalSpace,
          _buildCommissionRow(
            context,
            translate(AppStrings.commission),
            commission ?? "0",
            isMain: true,
            showLabel: false,
          ),
          if (minimumCommission != null && minimumCommission != "0") ...[
            8.verticalSpace,
            _buildCommissionRow(
              context,
              translate(AppStrings.minimumCommission),
              minimumCommission!,
            ),
          ],
          if (ordersBeforeCommission != null &&
              ordersBeforeCommission != "0") ...[
            8.verticalSpace,
            _buildCommissionRow(
              context,
              translate(AppStrings.ordersBeforeCommission),
              ordersBeforeCommission!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommissionRow(
    BuildContext context,
    String label,
    String value, {
    bool isMain = false,
    bool showLabel = true,
  }) {
    if (isMain && !showLabel) {
      return Center(
        child: Text(
          value,
          style: AppStyles.body14Medium.copyWith(
            color: ColorManager.primary,
            fontSize: FontSize.s20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: AppStyles.title16Regular.copyWith(
              color: ColorManager.medGray,
              fontSize: isMain ? FontSize.s12.sp : FontSize.s10.sp,
            ),
          ),
        ),
        Text(
          value,
          style: AppStyles.body14Medium.copyWith(
            color: isMain ? ColorManager.primary : ColorManager.darkGrey,
            fontSize: isMain ? FontSize.s16.sp : FontSize.s14.sp,
            fontWeight: isMain ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

