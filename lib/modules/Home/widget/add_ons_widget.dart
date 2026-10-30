import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';
import 'package:thewhsherbiker/shared/components/cached_network_image.dart';

class AddOnsWidget extends StatelessWidget {
  final List<AddOns>? addOns;
  const AddOnsWidget({Key? key, required this.addOns}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: addOns!.length,
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 5.h,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        return Column(
          children: [
            _cardAddOns(context, index),
            if (index == addOns!.length - 1) AppPadding.p16.verticalSpace,
          ],
        );
      },
    );
  }

  Container _cardAddOns(BuildContext context, int index) {
    return Container(
      height: 82.h,
      width: 327.w,
      decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: ColorManager.black.withOpacity(.02),
                blurRadius: 6.r,
                offset: const Offset(0, 3))
          ]),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      child: Row(
        children: <Widget>[
          ImageShared(
            image: addOns![index].iconAddons!.iconLink!,
            height: 50.h,
            width: 50.w,
            raduis: 0,
            errorFont: 30.sp,
          ),
          SizedBox(
            width: 18.w,
          ),
          Text(
            addOns![index].getLocalizedName(
              Localizations.localeOf(context).languageCode,
            ) ?? '',
            style: AppStyles.subtext14Regular.copyWith(
              color: ColorManager.darkGrey,
            ),
          ),
        ],
      ),
    );
  }
}
