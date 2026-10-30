import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/tracking_order/data/models/accepted_biker_model.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/contact_biker.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';

class BikerInformation extends StatelessWidget {
  final Biker biker;
  final String status;
  const BikerInformation({
    super.key,
    required this.biker,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(top: 22.5.h, bottom: 24.h, left: 24.w, right: 24.w),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(50.r),
            child: biker.imageLink!.isEmpty
                ? const Icon(Icons.image)
                : ImageShared(
                    image: biker.imageLink!,
                    height: 47.03.h,
                    width: 47.03.w,
                    raduis: 50.r,
                  ),
          ),
          AppPadding.p12.pw,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                translate(AppStrings.biker),
                style: AppStyles.caption12Regular.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
              Text(
                biker.userName!,
                style: AppStyles.title16Bold.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
            ],
          ),
          const Spacer(),
          ContactBiker(
            phoneBiker: biker.phone!,
          )
        ],
      ),
    );
  }
}
