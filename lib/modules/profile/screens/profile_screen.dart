import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_list_row.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_stats_card.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_status_card.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/screens/account_screen.dart';
import 'package:thewhsherbiker/modules/profile/screens/biker_schedule.dart';
import 'package:thewhsherbiker/modules/profile/screens/settings_screen.dart';
import 'package:thewhsherbiker/modules/profile/widget/logout_widget.dart';
import 'package:thewhsherbiker/modules/profile/widget/profile/date_joined_container.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

/// The biker's profile: who they are, status, stats and the account menu. A tab
/// in the shell ([isTab]); also pushed from the Today and order screens.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.isTab = false});

  /// A tab has nothing to go back to.
  final bool isTab;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    sl<ProfileBloc>().add(BikerGetTotalWashes(status: "COMPLETED"));
    sl<ProfileBloc>().add(BikerGetTotalCommission());
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    const Widget gap = SizedBox(height: KSpace.l);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        automaticallyImplyLeading: !widget.isTab,
        title: Text(
          tr(context, AppStrings.profile),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: AdaptiveContent(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            KSpace.l,
            KSpace.s,
            KSpace.l,
            MediaQuery.paddingOf(context).bottom + KSpace.l,
          ),
          children: <Widget>[
            const _ProfileHeader(),
            gap,
            const HomeStatusCard(),
            gap,
            const HomeStatsCard(),
            gap,
            BlocSelector<ProfileBloc, ProfileState, String?>(
              bloc: sl<ProfileBloc>(),
              selector: (ProfileState state) =>
                  sl<ProfileBloc>().profile.createdAt,
              builder: (BuildContext context, String? createdAt) =>
                  createdAt == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(bottom: KSpace.l),
                      child: DateJoinedContainer(timeCreateAt: createdAt),
                    ),
            ),
            KCard(
              padding: EdgeInsets.zero,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _menuRow(
                    context,
                    Icons.calendar_today_outlined,
                    AppStrings.mySchedule,
                    () => pushPage(context, const BikerSchedule()),
                  ),
                  Divider(height: 1, color: c.separator),
                  _menuRow(
                    context,
                    Icons.person_outline,
                    AppStrings.personalInformation,
                    () => pushPage(context, const AccountScreen()),
                  ),
                  Divider(height: 1, color: c.separator),
                  _menuRow(
                    context,
                    Icons.settings_outlined,
                    AppStrings.settings,
                    () => pushPage(context, const SettingScreen()),
                  ),
                ],
              ),
            ),
            gap,
            const LogOutWidget(),
          ],
        ),
      ),
    );
  }

  Widget _menuRow(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return KListRow(
      leading: Icon(icon, color: KColors.of(context).brand),
      title: tr(context, title),
      showChevron: true,
      onTap: onTap,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ProfileBloc, ProfileState, (String?, String?, String?)>(
      bloc: sl<ProfileBloc>(),
      selector: (ProfileState state) => (
        sl<ProfileBloc>().profile.imageLink,
        sl<ProfileBloc>().profile.userName,
        sl<ProfileBloc>().profile.phone,
      ),
      builder: (BuildContext context, (String?, String?, String?) biker) {
        final KColors c = KColors.of(context);
        final (String? image, String? name, String? phone) = biker;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            HomeAvatar(imageUrl: image, name: name, size: KSpace.xxxl * 3),
            const SizedBox(height: KSpace.m),
            if (name != null)
              Text(
                name,
                textAlign: TextAlign.center,
                style: KType.title.copyWith(color: c.text),
              ),
            if (phone != null)
              Text(
                phone,
                textDirection: TextDirection.ltr,
                style: KType.subhead.copyWith(color: c.textSecondary),
              ),
          ],
        );
      },
    );
  }
}
