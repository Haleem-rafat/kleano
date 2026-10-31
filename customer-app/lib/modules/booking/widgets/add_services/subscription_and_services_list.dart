import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/booking/widgets/add_services/plan_notavalible_location.dart';
import 'package:thewasher/modules/booking/widgets/add_services/services_list.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/subscription_model.dart';
import 'package:thewasher/modules/plans_and_subscription/widgets/card_plan.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class SubscriptionAndService extends StatelessWidget {
  final Subscription subscription;
  final String message;

  const SubscriptionAndService({
    super.key,
    required this.subscription,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    bool showServicesList =
        sl.call<OffersBloc>.call().cartServicesList.isNotEmpty ? true : false;
    return StatefulBuilder(
      builder: (context, myState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: KSpace.l),
              child: Text(
                '${subscription.plan!.type} · ${translate(AppStrings.remainingWashes)} (${subscription.remainingWashes}/${subscription.washesCount} ${translate(AppStrings.washes)})',
                style: KType.headline.copyWith(color: c.text),
              ),
            ),
            CardOfPlan(
              plan: subscription.plan!,
              userHaveAPlan: true,
              showExpandableContent: false,
              comeformBooking: true,
            ),
            if (message.isNotEmpty) const SubscriptionNotAvalibleLocation(),
            const SizedBox(height: KSpace.l),
            if (showServicesList)
              const ServicesList(alwaysShowExtras: true)
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: KSpace.l),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    KButton(
                      label: translate(AppStrings.addExtraServices),
                      variant: KButtonVariant.secondary,
                      onPressed: message.isNotEmpty
                          ? null
                          : () => myState(() => showServicesList = true),
                    ),
                    const SizedBox(height: KSpace.s),
                    Text(
                      translate(AppStrings.notAlreadyPartOfYourSubscription),
                      textAlign: TextAlign.center,
                      style: KType.footnote.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
