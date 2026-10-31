import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewhsherbiker/core/design/components/k_status_chip.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/utilis/enums.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_status_card.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

/// Online switch for the bar floating over the map: shows what the backend
/// confirmed, because `ProfileBloc` changes the status only on success.
class BikerStatusSwitchWidget extends StatelessWidget {
  const BikerStatusSwitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, bool>(
      bloc: sl<ProfileBloc>(),
      selector: (ProfileState state) => bikerIsOnline(),
      builder: (BuildContext context, bool online) {
        final String word = online
            ? trOr(context, 'online', en: 'Online', ar: 'متصل')
            : trOr(context, 'offline', en: 'Offline', ar: 'غير متصل');
        return LiquidGlass(
          capsule: true,
          padding: const EdgeInsets.symmetric(horizontal: KSpace.s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              KStatusChip(
                label: word,
                status: online ? KStatus.success : KStatus.neutral,
              ),
              const SizedBox(width: KSpace.xs),
              Semantics(
                label: word,
                child: Switch.adaptive(
                  value: online,
                  activeTrackColor: KColors.of(context).success,
                  onChanged: (bool value) {
                    sl<ProfileBloc>().add(
                      BikerUpdateStatus(
                        status: value
                            ? BikerStatus.ONLINE.name
                            : BikerStatus.OFFLINE.name,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
