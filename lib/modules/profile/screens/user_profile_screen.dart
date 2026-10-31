import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/enums/status.dart';
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

/// Profile tab (design: ProfileFlow · Profile): avatar and name, then grouped
/// lists — money (wallet, points, promo codes), account, and log out alone at
/// the end, confirmed in a [KDialog].
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
    Widget tile(IconData icon, Color color) => DecoratedBox(
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: SizedBox.square(
        dimension: 30,
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
    Widget group(List<Widget> rows) => Card(
      child: Column(
        children: <Widget>[
          for (int i = 0; i < rows.length; i++) ...<Widget>[
            if (i > 0) Divider(height: 1, indent: 58, color: c.separator),
            rows[i],
          ],
        ],
      ),
    );
    Widget value(String text) => Text(
      text,
      style: KType.subhead.copyWith(color: c.textSecondary),
      textDirection: TextDirection.ltr,
    );

    return SafeArea(
      bottom: false,
      child: ListView(
        // Clears the floating glass tab bar.
        padding: const EdgeInsets.fromLTRB(
          KSpace.xl,
          KSpace.xxl,
          KSpace.xl,
          120,
        ),
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 32,
                backgroundColor: c.brand.withValues(alpha: 0.14),
                foregroundImage: image == null ? null : NetworkImage(image),
                child: Text(
                  name.isEmpty ? '' : name.characters.first.toUpperCase(),
                  style: KType.title.copyWith(color: c.brand),
                ),
              ),
              const SizedBox(width: KSpace.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: KType.title.copyWith(color: c.text),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((profile.phone ?? '').isNotEmpty) value(profile.phone!),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KSpace.xxl),
          group(<Widget>[
            KListRow(
              title: translate(AppStrings.wallet),
              leading: tile(Icons.account_balance_wallet_rounded, c.success),
              trailing: value((profile.walletBalance ?? 0).toStringAsFixed(2)),
              showChevron: true,
              onTap: () => pushPage(context, const WalletTopupScreen()),
            ),
            KListRow(
              title: translate(AppStrings.points),
              leading: tile(Icons.stars_rounded, c.warning),
              trailing: value('${profile.points ?? 0}'),
              showChevron: true,
              onTap: () => pushPage(context, const PointScreen()),
            ),
            KListRow(
              title: translate(AppStrings.promoCodes),
              leading: tile(Icons.local_offer_rounded, c.brandLight),
              showChevron: true,
              onTap: () => pushPage(context, const PromoCodeScreen()),
            ),
          ]),
          const SizedBox(height: KSpace.xl),
          group(<Widget>[
            KListRow(
              title: translate(AppStrings.account),
              leading: tile(Icons.person_rounded, c.brand),
              showChevron: true,
              onTap: () => pushPage(context, const ProfileAccountScreen()),
            ),
            KListRow(
              title: translate(AppStrings.settings),
              leading: tile(Icons.settings_rounded, c.textSecondary),
              showChevron: true,
              onTap: () => pushPage(context, const SettingScreen()),
            ),
            KListRow(
              title: translate(AppStrings.aboutUs),
              leading: tile(Icons.info_rounded, c.textSecondary),
              showChevron: true,
              onTap: () => pushPage(context, const AboutUsScreen()),
            ),
          ]),
          const SizedBox(height: KSpace.xl),
          group(<Widget>[
            KListRow(
              title: translate(AppStrings.logout),
              leading: loggingOut
                  ? const SizedBox.square(
                      dimension: 30,
                      child: Padding(
                        padding: EdgeInsets.all(6),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : tile(Icons.logout_rounded, c.error),
              onTap: loggingOut ? null : onLogout,
            ),
          ]),
        ],
      ),
    );
  }
}
