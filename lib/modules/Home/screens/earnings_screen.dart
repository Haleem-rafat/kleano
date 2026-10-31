import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_list_row.dart';
import 'package:thewhsherbiker/core/design/components/k_states.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';
import 'package:thewhsherbiker/modules/profile/data/model/total_commission_model.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

/// The Earnings tab: commission for all time, today and weekends, then completed
/// washes. Shows only what `ProfileBloc` already fetches, and a dash rather than
/// a zero for money that hasn't arrived.
class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  static const String _unknown = '—';

  static bool _affectsEarnings(ProfileState state) =>
      state is BikerProfileSuccess ||
      state is BikerGetTotalWashesLoading ||
      state is BikerGetTotalCommissionLoading ||
      state is BikerGetTotalCommissionFailed;

  static void _load() {
    sl<ProfileBloc>().add(BikerGetTotalWashes(status: 'COMPLETED'));
    sl<ProfileBloc>().add(BikerGetTotalCommission());
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        automaticallyImplyLeading: false,
        title: Text(
          tr(context, AppStrings.earnings),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: AdaptiveContent(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          bloc: sl<ProfileBloc>(),
          buildWhen: (ProfileState previous, ProfileState current) =>
              _affectsEarnings(current),
          builder: (BuildContext context, ProfileState state) {
            final ProfileModel profile = sl<ProfileBloc>().profile;
            final TotalCommissionModel? commission = profile.totalCommission;
            if (commission == null) {
              if (state is BikerGetTotalCommissionFailed) {
                return KErrorState(
                  message: translate('defaultError'),
                  onRetry: _load,
                );
              }
              if (state is BikerGetTotalCommissionLoading ||
                  state is BikerGetTotalWashesLoading) {
                return const KLoadingState();
              }
            }
            return _content(context, profile, commission);
          },
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    ProfileModel profile,
    TotalCommissionModel? commission,
  ) {
    final KColors c = KColors.of(context);
    return ListView(
      padding: EdgeInsets.fromLTRB(
        KSpace.l,
        KSpace.s,
        KSpace.l,
        MediaQuery.paddingOf(context).bottom + KSpace.l,
      ),
      children: <Widget>[
        KCard(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      tr(context, AppStrings.allTime),
                      style: KType.footnote.copyWith(color: c.textSecondary),
                    ),
                    const SizedBox(height: KSpace.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        '${commission?.allTime.totalCommission ?? _unknown}',
                        maxLines: 1,
                        style: KType.largeTitle.copyWith(color: c.text),
                      ),
                    ),
                    if (commission != null)
                      Text(
                        _ordersLine(context, commission.allTime),
                        style: KType.subhead.copyWith(color: c.textSecondary),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: KSpace.m),
              SvgPicture.asset(
                ImageAssets.walletCoin,
                width: KSpace.xxxl,
                height: KSpace.xxxl,
              ),
            ],
          ),
        ),
        const SizedBox(height: KSpace.l),
        KCard(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _period(context, AppStrings.today, commission?.today),
              Divider(height: 1, color: c.separator),
              _period(context, AppStrings.weekends, commission?.allWeekends),
              Divider(height: 1, color: c.separator),
              KListRow(
                leading: SvgPicture.asset(
                  ImageAssets.totalWashesLogo,
                  width: KSpace.xxl,
                  height: KSpace.xxl,
                  colorFilter: ColorFilter.mode(c.brand, BlendMode.srcIn),
                ),
                title: tr(context, AppStrings.completedWashes),
                trailing: Text(
                  '${profile.totalWashes ?? _unknown}',
                  style: KType.headline.copyWith(color: c.text),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _period(BuildContext context, String label, CommissionPeriod? period) {
    return KListRow(
      leading: SvgPicture.asset(
        ImageAssets.walletCoin,
        width: KSpace.xxl,
        height: KSpace.xxl,
      ),
      title: tr(context, label),
      subtitle: period == null ? null : _ordersLine(context, period),
      trailing: Text(
        '${period?.totalCommission ?? _unknown}',
        style: KType.headline.copyWith(color: KColors.of(context).text),
      ),
    );
  }

  String _ordersLine(BuildContext context, CommissionPeriod period) =>
      '${period.ordersCount} ${tr(context, AppStrings.orders)}';
}
