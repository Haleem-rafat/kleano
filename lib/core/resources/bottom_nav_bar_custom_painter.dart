import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = ColorManager.white
      ..style = PaintingStyle.fill;
    Path path = Path()..moveTo(0, 15);
    path.quadraticBezierTo(375.w * 0.20, 0, 375.w * 0.35, 0);
    path.quadraticBezierTo(375.w * 0.40, 0, 375.w * 0.40, 20);
    path.arcToPoint(Offset(375.w * 0.60, 20),
        radius: Radius.circular(10.0.r), clockwise: false);
    path.quadraticBezierTo(375.w * 0.60, 0, 375.w * 0.65, 0);
    path.quadraticBezierTo(375.w * 0.85, 0, 375.w, 15);
    path.lineTo(375.w, 85.h);
    path.lineTo(0, 85.h);
    path.close();
    canvas.drawShadow(path, ColorManager.medGray, 7, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
