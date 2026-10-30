import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class DiscountAndTotal extends StatelessWidget {
  final double discount, total;
  const DiscountAndTotal({
    super.key,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("sjfnvonvnson ${sl<PromoBloc>().totalPayModel.discount}");
    return BlocBuilder<PromoBloc, PromoState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  translate(AppStrings.discount),
                  style: AppStyles.subtextGray14Regular.copyWith(
                    color: ColorManager.red,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '- ${sl<PromoBloc>().totalPayModel.discount?.toStringAsFixed(2) ?? discount} ',
                      style: AppStyles.subtextGray14Regular.copyWith(
                        color: ColorManager.red,
                      ),
                    ),
                    SvgPicture.asset(
                      AssetsManager.saudiRiyalSymbol,
                      height: 14.h,
                      width: 14.w,
                    ),
                  ],
                ),
              ],
            ),
            AppPadding.p12.ph,
            const Divider(),
            Row(
              children: <Widget>[
                Text(
                  translate(AppStrings.total),
                  style: AppStyles.subtextGray14Regular
                      .copyWith(color: ColorManager.black),
                ),
                const Spacer(),
                sl<PromoBloc>().totalPayModel.discount != null
                    ? Text(
                        (sl<PromoBloc>().totalPayModel.totalPrice! -
                                sl<PromoBloc>()
                                    .totalPayModel
                                    .discount!
                                    .toDouble())
                            .toStringAsFixed(2),
                        style: AppStyles.subtextGray14Regular
                            .copyWith(color: ColorManager.black),
                      )
                    : Text(
                        total.toStringAsFixed(2),
                        style: AppStyles.subtextGray14Regular
                            .copyWith(color: ColorManager.black),
                      ),
                AppPadding.p4.pw,
                SvgPicture.asset(
                  AssetsManager.saudiRiyalSymbol,
                  height: 14.h,
                  width: 14.w,
                ),
              ],
            )
          ],
        );
      },
    );
  }
}
