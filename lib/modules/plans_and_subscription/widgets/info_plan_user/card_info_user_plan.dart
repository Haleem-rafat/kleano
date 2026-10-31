import 'package:flutter/material.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/subscription_model.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/info_plan_user/info_subscription.dart';

class CardInfoUserPlan extends StatelessWidget {
  final Subscription subscription;
  const CardInfoUserPlan({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KSpace.xl,
        vertical: KSpace.s,
      ),
      child: KCard(child: InformationSubscription(subscription: subscription)),
    );
  }
}
