import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/about_us/screens/contact_us_screen.dart';
import 'package:thewasher/modules/about_us/screens/terms_and_conditions.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/modules/plans_and_subscription/screens/plans_subscription_screen.dart';
import 'package:thewasher/modules/profile/screens/points_explanation_screen.dart';
import 'package:thewasher/utilties/navigator.dart';

/// Profile tab for a guest: sign up, then what a guest can already open.
class ProfileGuestViewScreen extends StatelessWidget {
  const ProfileGuestViewScreen({super.key});

  /// Room for the floating WhatsApp button that sits above the tab bar.
  static const double _floatingButtonClearance = KSpace.xxxl * 2 + KSpace.l;
  static const double _avatarRadius = 36;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final List<(String, IconData, Color, Widget)> screens =
        <(String, IconData, Color, Widget)>[
          (
            translate(AppStrings.subscriptions),
            Icons.card_membership_rounded,
            c.brandLight,
            const PlansAndSubscriptionScreen(),
          ),
          (
            translate(AppStrings.termsAndConditions),
            Icons.description_rounded,
            c.textSecondary,
            const TermsAndConditionsScreen(),
          ),
          (
            translate(AppStrings.contactUs),
            Icons.support_agent_rounded,
            c.success,
            const ContactUsScreen(),
          ),
          (
            translate(AppStrings.howPointsWorks),
            Icons.stars_rounded,
            c.warning,
            const PointsExplanationScreen(),
          ),
        ];
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          KSpace.xl,
          KSpace.xxl,
          KSpace.xl,
          MediaQuery.paddingOf(context).bottom + _floatingButtonClearance,
        ),
        children: <Widget>[
          Center(
            child: CircleAvatar(
              radius: _avatarRadius,
              backgroundColor: c.brand.withValues(alpha: 0.14),
              child: Icon(Icons.person, color: c.brand, size: _avatarRadius),
            ),
          ),
          const SizedBox(height: KSpace.l),
          KButton(
            label: translate(AppStrings.signUpNow),
            onPressed: () => popALlAndPushPage(context, ChooseRegisterView()),
          ),
          const SizedBox(height: KSpace.xxl),
          KCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                for (int i = 0; i < screens.length; i++) ...<Widget>[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: KSpace.l + KSpace.xxxl + KSpace.m,
                      color: c.separator,
                    ),
                  KListRow(
                    title: screens[i].$1,
                    leading: _IconTile(
                      icon: screens[i].$2,
                      color: screens[i].$3,
                    ),
                    showChevron: true,
                    onTap: () => pushPage(context, screens[i].$4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        color: color.withValues(alpha: 0.14),
        shape: KRadius.shape(BorderRadius.circular(KSpace.s)),
      ),
      child: SizedBox.square(
        dimension: KSpace.xxxl,
        child: Icon(icon, size: KSpace.xl, color: color),
      ),
    );
  }
}
