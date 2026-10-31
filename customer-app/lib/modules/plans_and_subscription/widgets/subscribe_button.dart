import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/snack_bar.dart';

/// Secondary, not primary: several plan cards can be open at once and a screen
/// has one primary button at most.
class SubscribeButton extends StatelessWidget {
  final bool userHaveAPlan;
  final String planId;
  final String planType;
  final double planPrice;
  final bool isSubscribed, comeformBooking;
  final String createdAt;
  const SubscribeButton({
    super.key,
    required this.userHaveAPlan,
    required this.createdAt,
    required this.planId,
    required this.planType,
    required this.planPrice,
    required this.isSubscribed,
    this.comeformBooking = false,
  });

  void _onPressed(BuildContext context) {
    if (AppShared.token.isEmpty) {
      AlertHelper.guestAlert(context);
    } else if (!userHaveAPlan) {
      AlertHelper.createSubscription(
        createdAt: createdAt,
        context: context,
        planType: planType,
        price: planPrice,
        planId: planId,
      );
    } else {
      showSnackBar(
        buildContext: context,
        message: translate(AppStrings.youHaveAlreadySubscribed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (comeformBooking) return const SizedBox.shrink();
    return KButton(
      label: translate(
        isSubscribed ? AppStrings.subscribed : AppStrings.subscribe,
      ),
      variant: KButtonVariant.secondary,
      color: userHaveAPlan ? KColors.of(context).textSecondary : null,
      onPressed: () => _onPressed(context),
    );
  }
}
