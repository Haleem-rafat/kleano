import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/about_us/screens/contact_us_screen.dart';
import 'package:thewasher/modules/about_us/screens/terms_and_conditions.dart';
import 'package:thewasher/utilties/navigator.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(translate(AppStrings.aboutUs)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(KSpace.xl),
        children: <Widget>[
          KCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: <Widget>[
                KListRow(
                  title: translate(AppStrings.termsAndConditions),
                  showChevron: true,
                  onTap: () =>
                      pushPage(context, const TermsAndConditionsScreen()),
                ),
                Divider(height: 1, indent: KSpace.l, color: c.separator),
                KListRow(
                  title: translate(AppStrings.contactUs),
                  showChevron: true,
                  onTap: () => pushPage(context, const ContactUsScreen()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
