import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thewasher/core/resources/app_styles.dart';
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
    return ListTile(
      leading: icon,
      title: Text(
        titleSocial,
        style: AppStyles.title16Regular,
      ),
      onTap: () =>
          isPhone == true ? launchURL("https://wa.me/$url") : launchURL(url),
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
