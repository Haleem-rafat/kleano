import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';

class ServicesDetails extends StatelessWidget {
  final List<ServiceModel> services;
  const ServicesDetails({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: AppPadding.p18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            translate(AppStrings.services),
            style: AppStyles.title16Bold.copyWith(color: ColorManager.black),
          ),
          AppPadding.p8.ph,
          Column(
            children: services.map((ServiceModel service) {
              return Padding(
                padding: EdgeInsets.only(bottom: AppPadding.p4.h),
                child: Row(
                  children: <Widget>[
                    Text(
                      service.name!,
                      style: AppStyles.subtextGray14Regular.copyWith(
                        color: ColorManager.black,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      service.price!.toString(),
                      style: AppStyles.subtextGray14Regular.copyWith(
                        color: ColorManager.black,
                      ),
                    ),
                    AppPadding.p4.pw,
                    SvgPicture.asset(
                      AssetsManager.saudiRiyalSymbol,
                      height: 14.h,
                      width: 14.w,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
