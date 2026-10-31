import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/about_us/bloc/about_us_bloc.dart';
import 'package:thewasher/modules/about_us/widgets/social_widget.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/utilties/navigator.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.of(context).background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(translate(AppStrings.contactUs)),
      ),
      body: BlocProvider<AboutUsBloc>(
        create: (BuildContext context) => AboutUsBloc()..add(GetContactInfo()),
        child: BlocConsumer<AboutUsBloc, AboutUsState>(
          listener: (BuildContext context, AboutUsState state) {
            if (state.status == AboutUsStateStatus.error) {
              showSnackBar(buildContext: context, message: state.errorMessage!);
            }
          },
          builder: (BuildContext context, AboutUsState state) {
            if (state.status == AboutUsStateStatus.loading) {
              return const KSkeleton.details();
            }
            if (state.status == AboutUsStateStatus.success) {
              return _buildContactInfo(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context, AboutUsState state) {
    final KColors c = KColors.of(context);
    Widget section(String title, List<Widget> rows) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(
            start: KSpace.xs,
            bottom: KSpace.s,
          ),
          child: Text(
            title,
            style: KType.footnote.copyWith(color: c.textSecondary),
          ),
        ),
        KCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              for (int i = 0; i < rows.length; i++) ...<Widget>[
                if (i > 0)
                  Divider(height: 1, indent: KSpace.l, color: c.separator),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
    return ListView(
      padding: const EdgeInsets.all(KSpace.xl),
      children: <Widget>[
        section(translate(AppStrings.emails), <Widget>[
          for (final String email in state.contactInfo!.emails)
            KListRow(
              title: email,
              leading: Icon(Icons.email_outlined, color: c.brand),
            ),
        ]),
        const SizedBox(height: KSpace.xxl),
        section(translate(AppStrings.phoneNumbers), <Widget>[
          for (final String phone in state.contactInfo!.phoneNumbers)
            KListRow(
              // Isolated so the number stays left-to-right in Arabic.
              title: '\u2066$phone\u2069',
              leading: Icon(Icons.phone_outlined, color: c.brand),
            ),
        ]),
        const SizedBox(height: KSpace.xxl),
        section(translate(AppStrings.socialMedia), <Widget>[
          SocialWidget(
            icon: const FaIcon(FontAwesomeIcons.whatsapp),
            titleSocial: 'WhatsApp',
            isPhone: true,
            url: state.contactInfo!.whatsAppNumber,
          ),
          if (state.contactInfo!.facebookLink.isNotEmpty)
            SocialWidget(
              icon: const FaIcon(FontAwesomeIcons.facebook),
              titleSocial: 'Facebook',
              url: state.contactInfo!.facebookLink,
            ),
          if (state.contactInfo!.instagramLink.isNotEmpty)
            SocialWidget(
              icon: const FaIcon(FontAwesomeIcons.instagram),
              titleSocial: 'Instagram',
              url: state.contactInfo!.instagramLink,
            ),
          if (state.contactInfo!.twitterLink.isNotEmpty)
            SocialWidget(
              icon: const FaIcon(FontAwesomeIcons.x),
              titleSocial: 'X',
              url: state.contactInfo!.twitterLink,
            ),
          if (state.contactInfo!.linkedinLink.isNotEmpty)
            SocialWidget(
              icon: const FaIcon(FontAwesomeIcons.linkedin),
              titleSocial: 'LinkedIn',
              url: state.contactInfo!.linkedinLink,
            ),
          if (state.contactInfo!.youtubeLink.isNotEmpty)
            SocialWidget(
              icon: const FaIcon(FontAwesomeIcons.youtube),
              titleSocial: 'Youtube',
              url: state.contactInfo!.youtubeLink,
            ),
          if (state.contactInfo!.tiktokLink.isNotEmpty)
            SocialWidget(
              icon: const FaIcon(FontAwesomeIcons.tiktok),
              titleSocial: 'TikTok',
              url: state.contactInfo!.tiktokLink,
            ),
          if (state.contactInfo!.webSiteLink.isNotEmpty)
            SocialWidget(
              icon: const FaIcon(FontAwesomeIcons.globe),
              titleSocial: 'Website',
              url: state.contactInfo!.webSiteLink,
            ),
        ]),
      ],
    );
  }
}
