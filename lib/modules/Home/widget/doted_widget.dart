import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';

class DotedWidget extends StatefulWidget {
  final Color? color;
  final double? height, width;
  const DotedWidget({
    super.key,
    this.color = ColorManager.white,
    this.height = 5,
    this.width = 5,
  });

  @override
  State<DotedWidget> createState() => _DotedWidgetState();
}

class _DotedWidgetState extends State<DotedWidget> {
  double dot1 = 1;
  double dot2 = 1;
  double dot3 = 1;
  int counter = 0;

  Timer timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {});

  void changeSize() {
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        if (counter == 0) {
          dot1 = 2;
          dot2 = 1;
          dot3 = 1;
        } else if (counter == 1) {
          dot2 = 2;
        } else if (counter == 2) {
          dot1 = 1;
          dot3 = 2;
        }
        counter++;
        if (counter > 2) {
          counter = 0;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    changeSize();
  }

  @override
  void dispose() {
    timer.cancel();
    dot1 = 1;
    dot2 = 1;
    dot3 = 1;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: dot1),
          duration: const Duration(milliseconds: 500),
          builder: (_, val, child) => Transform.scale(
            scale: val,
            child: child,
          ),
          child: const Circle(),
        ),
        AppSize.s1_5.pw,

        // Second
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: dot2),
          duration: const Duration(milliseconds: 500),
          builder: (_, val, child) => Transform.scale(
            scale: val,
            child: child,
          ),
          child: const Circle(),
        ),
        AppSize.s1_5.pw,
        // Third
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: dot3),
          duration: const Duration(milliseconds: 500),
          builder: (_, val, child) => Transform.scale(
            scale: val,
            child: child,
          ),
          child: Circle(
            color: widget.color,
            height: widget.height,
            width: widget.width,
          ),
        ),
      ],
    );
  }
}

class Circle extends StatelessWidget {
  final Color? color;
  final double? height, width;
  const Circle({
    super.key,
    this.color = ColorManager.white,
    this.height = 5,
    this.width = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height!.h,
      width: width!.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color!,
      ),
    );
  }
}
