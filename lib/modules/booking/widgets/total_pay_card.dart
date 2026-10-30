import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class TotalPayCard extends StatelessWidget {
  // final VoidCallback onTap;
  final String text;
  final int servicesCount;
  final int addOnsCount;
  final num servicesTotal;
  final num addOnsTotal;
  final num totalPrice;
  const TotalPayCard({
    super.key,
    // required this.onTap,
    required this.text,
    required this.servicesCount,
    required this.addOnsCount,
    required this.servicesTotal,
    required this.addOnsTotal,
    required this.totalPrice,
  });

  String _formatPrice(num value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        gradient: LinearGradient(
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          colors: <Color>[
            ColorManager.primary,
            ColorManager.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Align(
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              text,
              key: ValueKey<String>(text),
              style: AppStyles.title16Bold
                  .copyWith(color: ColorManager.white, fontSize: 16.sp),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool emphasize;

  const _SummaryRow({
    required this.label,
    required this.amount,
  }) : emphasize = false;

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle =
        emphasize ? AppStyles.title16Bold : AppStyles.subtext14Regular;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: baseStyle.copyWith(
            color: ColorManager.white.withValues(alpha: emphasize ? 1 : 0.9),
            fontSize: emphasize ? 16.sp : 14.sp,
          ),
        ),
        SizedBox(width: 12.w),
        _CurrencyValue(
          amount: amount,
          style: baseStyle.copyWith(
            color: ColorManager.white,
            fontSize: emphasize ? 16.sp : 14.sp,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
          ),
          emphasize: emphasize,
        ),
      ],
    );
  }
}

class _CurrencyValue extends StatelessWidget {
  final String amount;
  final TextStyle style;
  final bool emphasize;

  const _CurrencyValue({
    required this.amount,
    required this.style,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          amount,
          style: style,
          textAlign: TextAlign.end,
        ),
        SizedBox(width: 4.w),
        SvgPicture.asset(
          AssetsManager.saudiRiyalSymbol,
          width: emphasize ? 18.w : 16.w,
          height: emphasize ? 18.w : 16.w,
          colorFilter: ColorFilter.mode(ColorManager.white, BlendMode.srcIn),
        ),
      ],
    );
  }
}
