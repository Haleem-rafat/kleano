import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class BookButton extends StatelessWidget {
  final bool isEmpty; // only one flag now

  const BookButton({
    super.key,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      width: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isEmpty
            ? LinearGradient(
                colors: [
                  Colors.grey.shade400,
                  Colors.grey.shade500,
                ],
              )
            : LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: <Color>[
                  ColorManager.primary,
                  ColorManager.secondary,
                ],
              ),
        boxShadow: isEmpty
            ? []
            : [
                BoxShadow(
                  color: ColorManager.primary.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Icon(
            isEmpty ? Icons.block : Icons.add_rounded,
            key: ValueKey<bool>(isEmpty),
            color: ColorManager.white,
            size: 32.r,
            shadows: [
              if (isEmpty)
                Shadow(
                  blurRadius: 6,
                  color: Colors.black26,
                  offset: const Offset(2, 2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
