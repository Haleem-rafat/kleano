import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/shared/components/shimmering/basic_container_shimmering.dart';
import 'package:thewhsherbiker/shared/components/shimmering/main_shimmering_widget.dart';

class ProfileShimmiring extends StatelessWidget {
  const ProfileShimmiring({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
            height: 180.h,
            width: 375.w,
            child: Stack(
              children: <Widget>[
                BasicContainerShemmering(
                  height: 110.h,
                  width: 375.w,
                ),
                Positioned(
                  bottom: 30.h,
                  left: 150.w,
                  right: 150.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: ShimmeringWidget(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorManager.primary.withOpacity(0.1),
                        ),
                        width: 73.39.w,
                        height: 73.39.h,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.h,
                  left: 120.w,
                  right: 120.w,
                  child: BasicContainerShemmering(
                    height: 21.h,
                    width: 75.w,
                  ),
                )
              ],
            )),
        SizedBox(
          height: AppPadding.p24.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BasicContainerShemmering(
              height: 75.h,
              width: 150.w,
            ),
            SizedBox(
              width: AppPadding.p26.w,
            ),
            BasicContainerShemmering(
              height: 75.h,
              width: 150.w,
            ),
          ],
        ),
        SizedBox(height: 56.h),
        ...<int>[1, 2, 3, 4, 5].map((_) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppPadding.p24.h),
            child: BasicContainerShemmering(
              height: 56.h,
              width: 328.w,
            ),
          );
        }).toList(),
      ],
    );
  }
}
