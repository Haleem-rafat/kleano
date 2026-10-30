import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/modules/points/screens/point_screen.dart';
import 'package:thewasher/utilties/navigator.dart';

class MyPointsWidget extends StatefulWidget {
  final String numberOfPoints;
  const MyPointsWidget({
    super.key,
    required this.numberOfPoints,
  });

  @override
  State<MyPointsWidget> createState() => _MyPointsWidgetState();
}

class _MyPointsWidgetState extends State<MyPointsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    pushPage(context, const PointScreen());
  }

  void _handleTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 150.w,
          height: 125.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorManager.secondary,
                ColorManager.secondary.withOpacity(0.85),
                ColorManager.primary.withOpacity(0.75),
              ],
            ),
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: ColorManager.secondary.withOpacity(0.4),
                blurRadius: 20.r,
                offset: Offset(0, 8.h),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: ColorManager.black.withOpacity(0.1),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -18.h,
                right: -18.w,
                child: Container(
                  width: 70.w,
                  height: 70.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorManager.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -12.h,
                left: -12.w,
                child: Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ColorManager.white.withOpacity(0.08),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(14.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon and Title Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: ColorManager.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: SvgPicture.asset(
                            AssetsManager.coin,
                            color: ColorManager.white,
                            height: 20.h,
                            width: 20.w,
                          ),
                        ),
                      ],
                    ),
                    // Points Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translate(AppStrings.points),
                          style: AppStyles.subtext14Regular.copyWith(
                            color: ColorManager.white.withOpacity(0.9),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                widget.numberOfPoints,
                                style: TextStyle(
                                  color: ColorManager.white,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w800,
                                  height: 1.0,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: Text(
                                  translate(AppStrings.point),
                                  style: TextStyle(
                                    color: ColorManager.white.withOpacity(0.9),
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
