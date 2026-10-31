import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
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

  const ButtonUsePromoCode({super.key, required this.promoCodeModel});

  @override
  Widget build(BuildContext context) {
    return KButton(
      label: translate(AppStrings.use),
      variant: KButtonVariant.secondary,
      expand: false,
      onPressed: () {
        sl.call<PromoBloc>.call().code = promoCodeModel.code!;
        copiedPromoCode = CopyPromoCode(
          promoCode: promoCodeModel.code!,
          id: promoCodeModel.sId!,
        );
        HapticFeedback.heavyImpact();
        showSnackBar(
          buildContext: context,
          message: translate(AppStrings.copied),
        );
      },
    );
  }
}
