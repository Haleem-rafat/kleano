import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/fonts_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/modules/profile/data/models/promo_code_model.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class CopyPromoCode {
  final String promoCode;
  final String id;

  CopyPromoCode({required this.promoCode, required this.id});
}

CopyPromoCode? copiedPromoCode;

class ButtonUsePromoCode extends StatelessWidget {
  final PromoCodeModel promoCodeModel;

  const ButtonUsePromoCode({
    super.key,
    required this.promoCodeModel,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, myState) {
        return GestureDetector(
          onTap: () {
            myState(() {
              sl<PromoBloc>.call().code = promoCodeModel.code!;
              copiedPromoCode = CopyPromoCode(
                  promoCode: promoCodeModel.code!, id: promoCodeModel.sId!);
              HapticFeedback.heavyImpact();
            });
            showSnackBar(
                buildContext: context, message: translate(AppStrings.copied));
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 28.h,
            width: 86.w,
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: ColorManager.primary),
            ),
            child: Center(
              child: Text(
                translate(AppStrings.use),
                style: AppStyles.title16Medium.copyWith(
                  color: ColorManager.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
