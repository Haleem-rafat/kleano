import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:action_slider/action_slider.dart';

class CustomSwipeButton extends StatefulWidget {
  final double? height;
  final double? width;
  final Color initialBackgroundColor;
  final String initialText;
  final TextDirection textDirection;
  final VoidCallback onChange;
  final bool isSuccess;
  final Future<void> Function(ActionSliderController controller)? onSwipe;

  const CustomSwipeButton({
    super.key,
    this.height = 30,
    this.width = 82,
    required this.initialBackgroundColor,
    required this.initialText,
    required this.onChange,
    required this.textDirection,
    required this.isSuccess,
    this.onSwipe,
  });

  @override
  State<CustomSwipeButton> createState() => _CustomSwipeButtonState();
}

class _CustomSwipeButtonState extends State<CustomSwipeButton> {
  @override
  Widget build(BuildContext context) {
    return ActionSlider.standard(
      direction: widget.textDirection,
      width: widget.width!.w,
      height: widget.height!.h,
      toggleColor: ColorManager.white,
      borderWidth: 2.r,
      boxShadow: <BoxShadow>[],
      backgroundColor: widget.initialBackgroundColor,
      icon: Icon(
        Icons.arrow_forward_ios,
        color: ColorManager.white,
      ),
      action: widget.onSwipe,
      child: Padding(
        padding: EdgeInsets.only(
          left: !widget.isSuccess ? 13.w : 0.w,
          right: widget.isSuccess ? 13.w : 0.w,
          bottom: 5.h,
          top: 5.h,
        ),
        child: Center(
          child: Text(
            widget.initialText,
            style: AppStyles.caption12Regular.copyWith(
              color:
                  widget.isSuccess ? ColorManager.white : ColorManager.darkGrey,
            ),
          ),
        ),
      ),
    );
  }
}
