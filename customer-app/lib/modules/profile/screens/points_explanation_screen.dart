import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class PointsExplanationScreen extends StatelessWidget {
  const PointsExplanationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(translate(AppStrings.howPointsWorks)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(KSpace.xl),
        children: <Widget>[
          Center(
            child: Lottie.asset(
              'assets/point.json',
              repeat: true,
              width: 96,
              height: 96,
            ),
          ),
          const SizedBox(height: KSpace.l),
          Text(
            translate(AppStrings.howPointsWorks),
            textAlign: TextAlign.center,
            style: KType.title.copyWith(color: c.text),
          ),
          const SizedBox(height: KSpace.s),
          Text(
            translate('earnRewards'),
            textAlign: TextAlign.center,
            style: KType.subhead.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: KSpace.xxl),
          _FeatureCard(
            icon: Icons.trending_up_rounded,
            title: translate(AppStrings.watchPointsGrow),
            description: translate(AppStrings.certainNumberPoints),
          ),
          const SizedBox(height: KSpace.m),
          _FeatureCard(
            icon: Icons.card_giftcard_rounded,
            title: translate(AppStrings.redeemPoints),
            description: translate(AppStrings.certainAmountPoints),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return KCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DecoratedBox(
            decoration: ShapeDecoration(
              color: c.brandTint,
              shape: KRadius.shape(BorderRadius.circular(KRadius.field)),
            ),
            child: SizedBox.square(
              dimension: KSpace.tapTarget,
              child: Icon(icon, color: c.onBrandTint),
            ),
          ),
          const SizedBox(width: KSpace.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: KType.headline.copyWith(color: c.text)),
                const SizedBox(height: KSpace.xs),
                Text(
                  description,
                  style: KType.subhead.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
