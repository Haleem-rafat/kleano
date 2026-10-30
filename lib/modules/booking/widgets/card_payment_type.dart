import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/booking/data/models/payment_type_model.dart';

class CardPaymentMethod extends StatelessWidget {
  final PaymentMethodModel type;
  final int groupValue;
  final Color borderColor;
  final num walletBalance;
  final bool isWallet;
  const CardPaymentMethod({
    super.key,
    required this.type,
    required this.groupValue,
    required this.borderColor,
    required this.walletBalance,
    required this.isWallet,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = type.value == groupValue;

    return Container(
      margin: EdgeInsets.only(bottom: 0.h),
      padding: EdgeInsets.all(AppPadding.p16.r),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isSelected ? ColorManager.primary : borderColor,
          width: 2.w,
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 40.w,
            width: 40.w,
            padding: EdgeInsets.all(8.r),
            decoration: const BoxDecoration(
              color: ColorManager.primary,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              type.image,
              color: isSelected ? ColorManager.white : ColorManager.white,
            ),
          ),
          SizedBox(width: AppPadding.p12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  type.title,
                  style: AppStyles.title16Medium.copyWith(
                    color:
                        isSelected ? ColorManager.primary : ColorManager.black,
                  ),
                ),
                if (isWallet) ...[
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: ColorManager.primary.withOpacity(0.2),
                        width: 1.w,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 14.w,
                          color: ColorManager.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          ': ${translate(AppStrings.balance)}',
                          style: AppStyles.caption12Regular.copyWith(
                            color: ColorManager.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          walletBalance.toStringAsFixed(2),
                          style: AppStyles.caption12Regular.copyWith(
                            color: ColorManager.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        SvgPicture.asset(
                          AssetsManager.saudiRiyalSymbol,
                          width: 12.w,
                          height: 12.w,
                          color: ColorManager.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle,
              color: ColorManager.primary,
              size: 22.w,
            ),
        ],
      ),
    );
  }
}
