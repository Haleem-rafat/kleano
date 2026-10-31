import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/plans_and_subscription/data/models/subscription_model.dart';
import 'package:thewasher/utilties/app_date_formatter.dart';

class InformationSubscription extends StatelessWidget {
  final Subscription subscription;

  const InformationSubscription({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final Color planColor = Color(
      int.parse("0xFF${subscription.plan!.color!}"),
    );
    final double washesPercentage =
        subscription.remainingWashes! / subscription.washesCount!;
    final TextStyle label = KType.footnote.copyWith(color: c.textSecondary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DecoratedBox(
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: planColor.withValues(alpha: 0.12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KSpace.m,
              vertical: KSpace.xs,
            ),
            child: Text(
              subscription.plan!.type!.toUpperCase(),
              style: KType.footnote.copyWith(
                color: planColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: KSpace.l),
        Text(translate(AppStrings.remainingWashes), style: label),
        const SizedBox(height: KSpace.xs),
        Text.rich(
          TextSpan(
            text: '${subscription.remainingWashes}',
            style: KType.title.copyWith(color: c.text),
            children: <InlineSpan>[
              TextSpan(
                text: ' / ${subscription.washesCount}',
                style: KType.body.copyWith(color: c.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: KSpace.m),
        LinearProgressIndicator(
          value: washesPercentage.clamp(0.0, 1.0),
          minHeight: KSpace.s,
          color: planColor,
          backgroundColor: c.fill,
          borderRadius: BorderRadius.circular(KSpace.xs),
        ),
        const SizedBox(height: KSpace.l),
        Text(translate(AppStrings.expiryDate), style: label),
        const SizedBox(height: KSpace.xs),
        Text(
          AppDateFormatter.allDate(
            DateTime.parse(subscription.expiryDate!),
            'en_us',
          ),
          style: KType.subhead.copyWith(
            color: c.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
