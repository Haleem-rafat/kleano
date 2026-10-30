import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/fonts_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class CardAddOns extends StatelessWidget {
  final int index;
  final VoidCallback onTap;
  const CardAddOns({
    super.key,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    OffersBloc offersBloc = sl<OffersBloc>();
    return Container(
      decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
              color: sl<OffersBloc>()
                      .cartAddOnsList
                      .contains(offersBloc.addOnsList[index])
                  ? ColorManager.primary
                  : ColorManager.white,
              width: 2.w),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: ColorManager.black.withOpacity(.12),
                blurRadius: 2.r,
                offset: const Offset(0, 0))
          ]),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 24.h,
          ),
          ImageShared(
            image: offersBloc.addOnsList[index].icon != null
                ? offersBloc.addOnsList[index].icon!.iconLink!
                : '',
            height: 50.h,
            width: 50.w,
          ),
          SizedBox(
            height: 10.h,
          ),
          Text(
            offersBloc.addOnsList[index].name!,
            style: AppStyles.caption12Regular.copyWith(
                overflow: TextOverflow.ellipsis,
                color: ColorManager.darkGrey,
                fontSize: FontSize.s10.sp),
          ),
          SizedBox(
            height: 15.h,
          ),
          InkWell(
            onTap: onTap,
            child: Container(
              width: 76.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: offersBloc.cartAddOnsList
                        .contains(offersBloc.addOnsList[index])
                    ? ColorManager.primary
                    : ColorManager.white,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(color: ColorManager.primary),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "+ ${offersBloc.addOnsList[index].price}",
                      style: AppStyles.subtext14Regular.copyWith(
                        color: offersBloc.cartAddOnsList
                                .contains(offersBloc.addOnsList[index])
                            ? ColorManager.white
                            : ColorManager.primary,
                        fontSize: FontSize.s10.sp,
                      ),
                    ),
                    4.horizontalSpace,
                    SvgPicture.asset(
                      AssetsManager.saudiRiyalSymbol,
                      height: 12.h,
                      width: 12.w,
                      color: offersBloc.cartAddOnsList
                              .contains(offersBloc.addOnsList[index])
                          ? ColorManager.white
                          : ColorManager.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
