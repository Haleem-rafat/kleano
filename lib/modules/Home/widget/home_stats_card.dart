import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_states.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';
import 'package:thewhsherbiker/modules/profile/data/model/total_commission_model.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

/// Total washes and rating, then today's, all-time and weekend earnings.
/// Known numbers stay on screen while they reload.
class HomeStatsCard extends StatelessWidget {
  const HomeStatsCard({super.key});

  static bool _affectsStats(ProfileState state) =>
      state is BikerProfileSuccess ||
      state is BikerGetTotalWashesLoading ||
      state is BikerGetTotalWashesFailed ||
      state is BikerGetTotalCommissionLoading ||
      state is BikerGetTotalCommissionFailed;

  static void _retry() {
    sl<ProfileBloc>().add(BikerGetTotalWashes(status: 'COMPLETED'));
    sl<ProfileBloc>().add(BikerGetTotalCommission());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      bloc: sl<ProfileBloc>(),
      buildWhen: (ProfileState previous, ProfileState current) =>
          _affectsStats(current),
      builder: (BuildContext context, ProfileState state) {
        final ProfileModel profile = sl<ProfileBloc>().profile;
        final TotalCommissionModel? commission = profile.totalCommission;
        if (profile.totalWashes == null && commission == null) {
          switch (state) {
            case BikerGetTotalWashesLoading():
            case BikerGetTotalCommissionLoading():
              return const KCard(child: KLoadingState());
            case BikerGetTotalWashesFailed():
            case BikerGetTotalCommissionFailed():
              return KCard(
                child: KErrorState(
                  message: translate('defaultError'),
                  onRetry: _retry,
                ),
              );
            default:
              // Nothing in flight, so no spinner: show zeros, as before.
              break;
          }
        }
        final KColors c = KColors.of(context);
        return KCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                tr(context, AppStrings.yourAnalytics),
                style: KType.footnote.copyWith(color: c.textSecondary),
              ),
              const SizedBox(height: KSpace.m),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _Stat(
                    icon: ImageAssets.totalWashesLogo,
                    tinted: true,
                    value: '${profile.totalWashes ?? 0}',
                    label: tr(context, AppStrings.totalWashes),
                  ),
                  _Stat(
                    icon: ImageAssets.ratingLogo,
                    tinted: true,
                    value: profile.rating?.toStringAsFixed(1) ?? '0.0',
                    label: tr(context, AppStrings.rating),
                  ),
                ],
              ),
              if (commission != null) ...<Widget>[
                Divider(height: KSpace.xxl, color: c.separator),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _Stat(
                      icon: ImageAssets.walletCoin,
                      value: '${commission.today.totalCommission}',
                      label: tr(context, AppStrings.today),
                    ),
                    _Stat(
                      icon: ImageAssets.walletCoin,
                      value: '${commission.allTime.totalCommission}',
                      label: tr(context, AppStrings.allTime),
                    ),
                    _Stat(
                      icon: ImageAssets.walletCoin,
                      value: '${commission.allWeekends.totalCommission}',
                      label: tr(context, AppStrings.weekends),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    this.tinted = false,
  });

  final String icon;
  final String value;
  final String label;

  /// Single-colour icons take the brand colour; the coin keeps its own.
  final bool tinted;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Expanded(
      child: Column(
        children: <Widget>[
          SvgPicture.asset(
            icon,
            width: KSpace.xxl,
            height: KSpace.xxl,
            colorFilter: tinted
                ? ColorFilter.mode(c.brand, BlendMode.srcIn)
                : null,
          ),
          const SizedBox(height: KSpace.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: KType.headline.copyWith(color: c.text),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: KType.footnote.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}
