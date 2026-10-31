import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialWidget extends StatelessWidget {
  final FaIcon icon;
  final String titleSocial;
  final String url;
  final bool? isPhone;
  const SocialWidget({
    super.key,
    required this.icon,
    required this.titleSocial,
    required this.url,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return KListRow(
      leading: IconTheme.merge(
        data: IconThemeData(color: KColors.of(context).brand),
        child: icon,
      ),
      title: titleSocial,
      showChevron: true,
      onTap: () =>
          isPhone == true ? launchURL('https://wa.me/$url') : launchURL(url),
    );
  }

  void launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
