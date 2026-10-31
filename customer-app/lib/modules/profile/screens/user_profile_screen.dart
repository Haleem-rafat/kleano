import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/enums/status.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Auth/cubit/auth_cubit.dart';
import 'package:thewasher/modules/Auth/cubit/auth_state.dart';
import 'package:thewasher/modules/about_us/screens/about_us_screen.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/modules/points/screens/point_screen.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/data/models/profile_user.dart';
import 'package:thewasher/modules/profile/screens/profile_account/profile_account.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/pormo_codes_screen.dart';
import 'package:thewasher/modules/profile/screens/profile_account/setting/setting_screen.dart';
import 'package:thewasher/modules/profile/screens/profile_guest_view/profile_guest_view.dart';
import 'package:thewasher/modules/profile/widgets/wallet_topup_bottom_sheet.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/utilties/navigator.dart';

/// Profile tab, in the biker app's style: centred photo and name, wallet and
/// points, one list of everything else, and log out, confirmed in a [KDialog].
class UserProfileScreen extends StatefulWidget {
  final bool? openAnother;
  const UserProfileScreen({super.key, this.openAnother = false});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late GetUserProfileBloc getUserProfileBloc;
  late AuthCubit authCubit;

  @override
  void initState() {
    super.initState();
    if (AppShared.token.isNotEmpty) {
      getUserProfileBloc = BlocProvider.of<GetUserProfileBloc>(context);
      getUserProfileBloc.add(GetUserProfileEvent());
    }
    authCubit = BlocProvider.of<AuthCubit>(context);
  }

  Future<void> _confirmLogout() async {
    final bool? yes = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => KDialog(
        icon: Icon(
          Icons.logout_rounded,
          size: 36,
          color: KColors.of(context).error,
        ),
        title: translate(AppStrings.logout),
        actions: <Widget>[
          KButton(
            label: translate(AppStrings.logout),
            variant: KButtonVariant.destructive,
            onPressed: () => Navigator.of(context).pop(true),
          ),
          KButton(
            label: translate(AppStrings.cancel),
            variant: KButtonVariant.text,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
    if (yes == true) authCubit.logout();
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state.logoutStatus == RequestStatus.loaded) {
          popALlAndPushPage(context, ChooseRegisterView());
        } else if (state.logoutStatus == RequestStatus.failure) {
          showSnackBar(
            buildContext: context,
            message:
                state.logoutErrorMessage ??
                'Failed to logout. Please try again.',
            icon: Icons.error_outline,
            backgroundColor: c.error,
          );
        }
      },
      builder: (BuildContext context, AuthState authState) {
        if (isGuestUser) {
          return const Scaffold(body: ProfileGuestViewScreen());
        }
        final bool loggingOut = authState.logoutStatus == RequestStatus.loading;
        return Scaffold(
          backgroundColor: c.background,
          body: AppShared.token.isEmpty
              ? const SizedBox.shrink()
              : BlocBuilder<GetUserProfileBloc, GetUserProfileState>(
                  builder: (BuildContext context, GetUserProfileState state) {
                    if (state is GetUserProfileConnectionError) {
                      return KErrorState(
                        message: translate('somethingWentWrong'),
                        onRetry: () =>
                            getUserProfileBloc.add(GetUserProfileEvent()),
                      );
                    }
                    if (state is! GetUserProfileSuccess) {
                      return const KLoadingState();
                    }
                    return _ProfileBody(
                      profile: state.userProfile.data!,
                      loggingOut: loggingOut,
                      onLogout: _confirmLogout,
                    );
                  },
                ),
        );
      },
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.profile,
    required this.loggingOut,
    required this.onLogout,
  });

  final Profile profile;
  final bool loggingOut;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final String name = profile.userName ?? '';
    final String? image =
        (profile.imageLink == null || profile.imageLink == 'null')
        ? null
        : profile.imageLink;
    Widget icon(IconData icon) => Icon(icon, color: c.brand);
    Widget group(List<Widget> rows) => KCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0)
              Divider(
                height: 1,
                indent: KSpace.l * 2 + KSpace.xxl,
                color: c.separator,
              ),
            rows[i],
          ],
        ],
      ),
    );

    return SafeArea(
      bottom: false,
      child: ListView(
        // Clears the floating glass tab bar.
        padding: const EdgeInsets.fromLTRB(
          KSpace.xl,
          KSpace.xl,
          KSpace.xl,
          120,
        ),
        children: <Widget>[
          Text(
            translate(AppStrings.profile),
            textAlign: TextAlign.center,
            style: KType.headline.copyWith(color: c.text),
          ),
          const SizedBox(height: KSpace.xl),
          Center(
            child: CircleAvatar(
              radius: KSpace.xxxl * 1.5,
              backgroundColor: c.brandTint,
              foregroundImage: image == null
                  ? null
                  : ResizeImage(
                      NetworkImage(image),
                      width:
                          (KSpace.xxxl *
                                  3 *
                                  MediaQuery.devicePixelRatioOf(context))
                              .round(),
                    ),
              child: Text(
                name.isEmpty ? '' : name.characters.first.toUpperCase(),
                style: KType.largeTitle.copyWith(color: c.onBrandTint),
              ),
            ),
          ),
          const SizedBox(height: KSpace.m),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: KType.title.copyWith(color: c.text),
          ),
          if ((profile.phone ?? '').isNotEmpty)
            Text(
              profile.phone!,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: KType.subhead.copyWith(color: c.textSecondary),
            ),
          const SizedBox(height: KSpace.xl),
          KCard(
            padding: const EdgeInsets.all(KSpace.l),
            child: IntrinsicHeight(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _Balance(
                      icon: AssetsManager.walletCoin,
                      label: translate(AppStrings.wallet),
                      value: (profile.walletBalance ?? 0).toStringAsFixed(2),
                      onTap: () => pushPage(context, const WalletTopupScreen()),
                    ),
                  ),
                  VerticalDivider(width: 1, color: c.separator),
                  Expanded(
                    child: _Balance(
                      icon: AssetsManager.singleCoin,
                      label: translate(AppStrings.points),
                      value: '${profile.points ?? 0}',
                      onTap: () => pushPage(context, const PointScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: KSpace.l),
          group(<Widget>[
            KListRow(
              title: translate(AppStrings.promoCodes),
              leading: icon(Icons.local_offer_outlined),
              showChevron: true,
              onTap: () => pushPage(context, const PromoCodeScreen()),
            ),
            KListRow(
              title: translate(AppStrings.account),
              leading: icon(Icons.person_outline_rounded),
              showChevron: true,
              onTap: () => pushPage(context, const ProfileAccountScreen()),
            ),
            KListRow(
              title: translate(AppStrings.settings),
              leading: icon(Icons.settings_outlined),
              showChevron: true,
              onTap: () => pushPage(context, const SettingScreen()),
            ),
            KListRow(
              title: translate(AppStrings.aboutUs),
              leading: icon(Icons.info_outline_rounded),
              showChevron: true,
              onTap: () => pushPage(context, const AboutUsScreen()),
            ),
          ]),
          const SizedBox(height: KSpace.l),
          KButton(
            label: translate(AppStrings.logout),
            variant: KButtonVariant.text,
            color: c.error,
            loading: loggingOut,
            onPressed: loggingOut ? null : onLogout,
          ),
        ],
      ),
    );
  }
}

/// One figure on the profile, as in the biker's analytics card.
class _Balance extends StatelessWidget {
  const _Balance({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgPicture.asset(icon, width: KSpace.xxl, height: KSpace.xxl),
            const SizedBox(height: KSpace.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                textDirection: TextDirection.ltr,
                style: KType.headline.copyWith(color: c.text),
              ),
            ),
            Text(label, style: KType.footnote.copyWith(color: c.textSecondary)),
          ],
        ),
      ),
    );
  }
}
