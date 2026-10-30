import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/data/model/add_ons_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';

class CardAddOns extends StatelessWidget {
  final AddOnsModel addOns;
  const CardAddOns({
    super.key,
    required this.addOns,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: ColorManager.black.withOpacity(.05),
              blurRadius: 6.r,
              offset: const Offset(0, 3))
        ],
      ),
      padding: EdgeInsets.fromLTRB(
          AppPadding.p18.w, 24.87.h, AppPadding.p18.w, AppPadding.p16.h),
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        children: [
          ImageShared(
            image: addOns.icon!.iconLink!,
            height: 50.h,
            width: 50.w,
          ),
          AppPadding.p18.pw,
          Text(
            addOns.name!,
            style: AppStyles.subtextGray14Regular
                .copyWith(color: ColorManager.darkGrey),
          ),
          const Spacer(),
          Text(
            addOns.price!.toString(),
            style: AppStyles.title16Bold.copyWith(color: ColorManager.darkGrey),
          ),
          AppPadding.p4.pw,
          SvgPicture.asset(
            AssetsManager.saudiRiyalSymbol,
            height: 16.h,
            width: 16.w,
          ),
        ],
      ),
    );
  }
}
