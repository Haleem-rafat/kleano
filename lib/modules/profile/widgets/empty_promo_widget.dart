import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';

class EmptyPromoWidget extends StatelessWidget {
  const EmptyPromoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            AssetsManager.emptyPromo,
            colorFilter: ColorFilter.mode(ColorManager.black, BlendMode.srcIn),
          ),
          AppPadding.p30.ph,
          Text(
            translate(AppStrings.noPromoCodesYet),
            style: AppStyles.title16Regular.copyWith(color: ColorManager.black),
          )
        ],
      ),
    );
  }
}
