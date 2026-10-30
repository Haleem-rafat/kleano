import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/shared/components/shimmering/main_shimmering_widget.dart';

class BasicContainerShemmering extends StatelessWidget {
  final double height;
  final double width;
  final double? radius;
  const BasicContainerShemmering({
    super.key,
    required this.height,
    required this.width,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius!.r),
      child: ShimmeringWidget(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius!.r),
            color: ColorManager.primary.withValues(alpha: 0.1),
          ),
          width: width,
          height: height,
        ),
      ),
    );
  }
}
