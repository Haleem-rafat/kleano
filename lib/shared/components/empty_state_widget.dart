import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

class EmptyStateWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? lottieAsset;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final bool showRetryButton;

  const EmptyStateWidget({
    super.key,
    this.title,
    this.subtitle,
    this.lottieAsset,
    this.onRetry,
    this.retryButtonText,
    this.showRetryButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 120.w,
              color: ColorManager.medGray.withOpacity(0.5),
            ),

            SizedBox(height: 24.h),

            // Title
            Text(
              title ?? translate(AppStrings.noContent),
              textAlign: TextAlign.center,
              style: AppStyles.titleGray16Regular.copyWith(
                color: ColorManager.darkGrey,
                fontSize: 18.sp,
              ),
            ),

            SizedBox(height: 8.h),

            // Subtitle
            if (subtitle != null)
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppStyles.subtextGray14Regular.copyWith(
                  color: ColorManager.medGray,
                ),
              ),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}
