import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/components/circle_image.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/utilis/launch_map.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart'
    as order;

class UserDetailsWidget extends StatelessWidget {
  final order.OrderModel userData;
  final TextStyle textStyle;

  const UserDetailsWidget(
      {super.key, required this.userData, required this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: [
            Text(
              translate(AppStrings.requestID),
              style: textStyle.copyWith(color: ColorManager.darkGrey),
            ),
            SizedBox(
              width: 5.w,
            ),
            Text(
              textDirection: TextDirection.ltr,
              "# ${(userData.sId != null && userData.sId!.length > 6) ? userData.sId!.substring(userData.sId!.length - 6) : userData.sId ?? "N/A"}",
              style: AppStyles.body14Medium.copyWith(color: ColorManager.red),
            ),
          ],
        ),
        // RichText(
        //   textDirection: TextDirection.ltr,
        //   text: TextSpan(
        //     text: translate(AppStrings.requestID),
        //     style: textStyle.copyWith(color: ColorManager.darkGrey),
        //     children: <TextSpan>[
        //       TextSpan(
        //           text:
        //               " ${userData.sId!.replaceRange(0, userData.sId!.length ~/ 1.5, '#').toUpperCase()}",
        //           style:
        //               AppStyles.body14Medium.copyWith(color: ColorManager.red)),
        //     ],
        //   ),
        // ),
        SizedBox(
          height: 8.h,
        ),
        Row(
          children: <Widget>[
            CircleImageShared(
              imageUrl:
                  userData.user != null && userData.user!.imageLink != null
                      ? userData.user!.imageLink!
                      : '',
              radius: 12.r,
              name: userData.user != null && userData.user!.userName != null
                  ? userData.user!.userName!
                  : AppStrings.noName,
            ),
            SizedBox(
              width: 8.w,
            ),
            if (userData.user != null && userData.user!.userName != null)
              Text(
                userData.user!.userName!,
                style: AppStyles.title16Regular.copyWith(
                  // color: ColorManager.medGray,
                  fontSize: 13.sp,
                ),
              ),
          ],
        ),
        SizedBox(
          height: 12.h,
        ),
        if (userData.location?.streetName != null)
          InkWell(
            highlightColor: Colors.transparent,
            onTap: () async {
              await launchMap(
                  lat: userData.location?.latitude.toString() ?? "",
                  long: userData.location?.longitude.toString() ?? "");
            },
            child: Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: <Widget>[
                SvgPicture.asset(ImageAssets.locationIcon),
                Expanded(
                  child: Text(
                    userData.location!.streetName!,
                    style: AppStyles.title16Regular.copyWith(
                      fontSize: 13.sp,
                      // color: ColorManager.medGray,
                    ),
                    maxLines: 2,
                  ),
                ),
                // SizedBox(
                //   width: 23.w,
                // ),
                // if (userData.startTime != null)
                //   Directionality(
                //     textDirection: TextDirection.ltr,
                //     child: Text(
                //       AppDateFormatter.dateToStringHHMMA(userData.startTime!),
                //       style: AppStyles.caption12Regular.copyWith(
                //         fontSize: 13,
                //         // color: ColorManager.medGray,
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
      ],
    );
  }
}
