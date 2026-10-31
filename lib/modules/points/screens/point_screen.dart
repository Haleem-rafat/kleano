import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/points/bloc/point_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class PointScreen extends StatefulWidget {
  const PointScreen({super.key});

  @override
  State<PointScreen> createState() => _PointScreenState();
}

class _PointScreenState extends State<PointScreen> {
  @override
  void initState() {
    super.initState();
    sl<PointBloc>().add(GetUserPoints());
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(translate(AppStrings.myPoints)),
      ),
      body: BlocBuilder<PointBloc, PointState>(
        builder: (BuildContext context, PointState state) {
          if (state is PointFailed) {
            return KErrorState(
              message: translate('somethingWentWrong'),
              onRetry: () => sl<PointBloc>().add(GetUserPoints()),
            );
          }
          if (state is! PointLoaded) {
            return const KLoadingState();
          }
          return const _PointsBody();
        },
      ),
    );
  }
}

class _PointsBody extends StatelessWidget {
  const _PointsBody();

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final response = sl<PointBloc>().pointResponse;
    final num points = response.points!;
    final num exchange = response.pointsExchange!;
    final num limit = response.redeemLimit!;
    final String pointsText = points >= 1000000
        ? '${points / 1000000} M'
        : points >= 1000
        ? '${points / 1000} K'
        : '$points';
    final String exchangeText = exchange >= 1000000
        ? '${(exchange / 1000000).toStringAsFixed(2)} M'
        : exchange >= 1000
        ? '${(exchange / 1000).toStringAsFixed(2)} K'
        : exchange.toStringAsFixed(2);
    final double progress = points / limit > 1.0 ? 1.0 : points / limit;
    final TextStyle small = KType.footnote.copyWith(color: c.textSecondary);

    Widget amount(String text, String asset) => Expanded(
      // Very large balances shrink instead of overflowing.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(text, style: KType.title.copyWith(color: c.text)),
            const SizedBox(width: KSpace.s),
            SvgPicture.asset(asset, height: KSpace.xxl, width: KSpace.xxl),
          ],
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(KSpace.xl),
      children: <Widget>[
        KCard(
          padding: const EdgeInsets.all(KSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                translate(AppStrings.points),
                style: KType.subhead.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: KSpace.m),
              Row(
                children: <Widget>[
                  amount(pointsText, AssetsManager.walletCoin),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: KSpace.s),
                    child: Text(
                      '=',
                      style: KType.largeTitle.copyWith(color: c.textSecondary),
                    ),
                  ),
                  amount(exchangeText, AssetsManager.saudiRiyalSymbol),
                ],
              ),
              const SizedBox(height: KSpace.l),
              Divider(height: 1, color: c.separator),
              const SizedBox(height: KSpace.l),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('0 pt', style: small),
                  Text('$limit pt', style: small),
                ],
              ),
              const SizedBox(height: KSpace.s),
              LinearProgressIndicator(
                value: progress,
                minHeight: KSpace.s,
                borderRadius: BorderRadius.circular(KSpace.xs),
                color: c.brand,
                backgroundColor: c.fill,
              ),
              const SizedBox(height: KSpace.m),
              Text(
                '${translate(AppStrings.earn)} $limit pt ${translate(AppStrings.moreToRedeemYourPoints)}',
                style: small,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
