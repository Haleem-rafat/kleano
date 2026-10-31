import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/screens/payment_type.dart';
import 'package:thewasher/utilties/navigator.dart';

class CreateSubscription extends StatelessWidget {
  final double price;
  final String planType;
  final String planId;
  final String createdAt;
  const CreateSubscription({
    super.key,
    required this.price,
    required this.planType,
    required this.createdAt,
    required this.planId,
  });

  @override
  Widget build(BuildContext context) {
    return KDialog(
      // KDialog titles are plain text, so the riyal symbol sits above them.
      icon: SvgPicture.asset(
        AssetsManager.saudiRiyalSymbol,
        width: KSpace.xxxl,
        height: KSpace.xxxl,
        colorFilter: ColorFilter.mode(
          KColors.of(context).brand,
          BlendMode.srcIn,
        ),
      ),
      title:
          '${translate(AppStrings.youArePaying)} ${price.toStringAsFixed(0)} $planType',
      actions: <Widget>[
        KButton(
          label: 'Checkout',
          onPressed: () {
            pop(context);
            pushPage(
              context,
              SelectPaymentTypeScreen(
                amount: price,
                createdAt: createdAt,
                planId: planId,
              ),
            );
          },
        ),
        KButton(
          label: translate(AppStrings.cancel),
          variant: KButtonVariant.text,
          onPressed: () => pop(context),
        ),
      ],
    );
  }
}
