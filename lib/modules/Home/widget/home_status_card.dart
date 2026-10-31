import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_status_chip.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/utilis/enums.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

/// Whether the backend has the biker as online.
bool bikerIsOnline() =>
    sl<ProfileBloc>().profile.status == BikerStatus.ONLINE.name;

void _setOnline(bool online) {
  sl<ProfileBloc>().add(
    BikerUpdateStatus(
      status: online ? BikerStatus.ONLINE.name : BikerStatus.OFFLINE.name,
    ),
  );
}

/// The most important control on Home. The switch shows what the backend
/// confirmed: `ProfileBloc` changes the status only after the call succeeds.
class HomeStatusCard extends StatelessWidget {
  const HomeStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, bool>(
      bloc: sl<ProfileBloc>(),
      selector: (ProfileState state) => bikerIsOnline(),
      builder: (BuildContext context, bool online) {
        final KColors c = KColors.of(context);
        final String word = online
            ? trOr(context, 'online', en: 'Online', ar: 'متصل')
            : trOr(context, 'offline', en: 'Offline', ar: 'غير متصل');
        return KCard(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    KStatusChip(
                      label: word,
                      status: online ? KStatus.success : KStatus.neutral,
                    ),
                    if (!online) ...<Widget>[
                      const SizedBox(height: KSpace.s),
                      Text(
                        tr(context, AppStrings.startReceivingRequests),
                        style: KType.subhead.copyWith(color: c.text),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: KSpace.m),
              Semantics(
                label: word,
                child: Switch.adaptive(
                  value: online,
                  activeTrackColor: c.success,
                  onChanged: _setOnline,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shown instead of the order lists while the biker is offline.
class HomeOfflinePrompt extends StatelessWidget {
  const HomeOfflinePrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return KCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SvgPicture.asset(
            ImageAssets.offlineAnimationLogo,
            height: KSpace.xxl,
          ),
          const SizedBox(height: KSpace.l),
          KButton(
            label: trOr(
              context,
              AppStrings.goOnlineNow,
              en: 'Go Online Now',
              ar: 'افتح الاتصال الآن',
            ),
            onPressed: () => _setOnline(true),
          ),
        ],
      ),
    );
  }
}
