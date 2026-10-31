import 'package:flutter/material.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/data/model/add_ons_model.dart';

class AddOnsDetails extends StatelessWidget {
  final List<AddOnsModel> addons;
  const AddOnsDetails({super.key, required this.addons});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: addons.map((AddOnsModel addons) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppPadding.p4.h),
          child: Row(
            children: <Widget>[
              Text(addons.name!, style: AppStyles.subtextGray14Regular),
              const Spacer(),
              Text(
                addons.price!.toString(),
                style: AppStyles.subtextGray14Regular,
              ),
              SizedBox(width: AppPadding.p4.w),
              SvgPicture.asset(
                AssetsManager.saudiRiyalSymbol,
                colorFilter: ColorFilter.mode(
                  KColors.of(context).text,
                  BlendMode.srcIn,
                ),
                height: 14.h,
                width: 14.w,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
