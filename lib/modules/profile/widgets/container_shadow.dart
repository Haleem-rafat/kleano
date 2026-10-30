import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';

class ContainerShadow extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  const ContainerShadow({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
  });

  @override
  State<ContainerShadow> createState() => _ContainerShadowState();
}

class _ContainerShadowState extends State<ContainerShadow> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.only(bottom: AppMargin.m12.h),
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.p20.w,
          vertical: AppPadding.p16.h,
        ),
        decoration: BoxDecoration(
          color: _isPressed
              ? ColorManager.darkGrey.withValues(alpha: 0.03)
              : ColorManager.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: ColorManager.darkGrey.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: _isPressed
              ? []
              : <BoxShadow>[
                  BoxShadow(
                    color: ColorManager.black.withValues(alpha: .04),
                    blurRadius: 8.r,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Row(
          children: <Widget>[
            if (widget.icon != null) ...[
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: ColorManager.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  widget.icon,
                  size: 20.r,
                  color: ColorManager.primary,
                ),
              ),
              SizedBox(width: 16.w),
            ],
            Expanded(
              child: Text(
                widget.text,
                style: AppStyles.titleGray16Regular.copyWith(
                  color: ColorManager.black,
                  fontWeight: FontWeight.w500,
                  fontSize: 15.sp,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.r,
              color: ColorManager.darkGrey.withValues(alpha: 0.4),
            )
          ],
        ),
      ),
    );
  }
}
