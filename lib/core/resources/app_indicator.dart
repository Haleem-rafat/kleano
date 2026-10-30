import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppIndicator extends StatelessWidget {
  final int length;
  final int currentIndex;
  final int height;
  final int width;
  final double selectedWidth;
  final double innerPadding;
  final Color unselectedColor;
  final Color selectedColor;

  const AppIndicator({
    super.key,
    required this.currentIndex,
    this.length = 0,
    this.selectedColor = Colors.white,
    this.unselectedColor = Colors.grey,
    this.height = 8,
    this.width = 8,
    this.selectedWidth = 15,
    this.innerPadding = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(
        length,
        (int index) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: innerPadding.w,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: height.h,
              width: currentIndex == index ? selectedWidth.w : width.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.r),
                color: currentIndex == index ? selectedColor : unselectedColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
