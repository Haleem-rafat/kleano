import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactBiker extends StatelessWidget {
  final String phoneBiker;
  const ContactBiker({super.key, required this.phoneBiker});

  @override
  Widget build(BuildContext context) {
    void callNumber() async {
      final String phone = phoneBiker.replaceAll('+', '').trim();

      if (Platform.isAndroid) {
        await FlutterPhoneDirectCaller.callNumber(phone);
      } else if (Platform.isIOS) {
        final Uri telUri = Uri(scheme: 'tel', path: phone);
        if (await canLaunchUrl(telUri)) {
          await launchUrl(telUri);
        } else {
          throw 'Could not launch dialer';
        }
      }
    }

    void openWhatsApp() async {
      final String phone = phoneBiker
          .replaceAll('+', '')
          .replaceAll(' ', '')
          .trim();

      // Ensure the phone number starts with country code
      String whatsappNumber = phone.startsWith('966') ? phone : '966$phone';

      final Uri whatsappUri = Uri.parse('https://wa.me/$whatsappNumber');

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch WhatsApp';
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        IconButton(
          tooltip: translate(AppStrings.phoneNumber),
          onPressed: callNumber,
          icon: SvgPicture.asset(
            AssetsManager.phoneIcon,
            height: 34,
            width: 34,
          ),
        ),
        IconButton(
          tooltip: 'WhatsApp',
          onPressed: openWhatsApp,
          icon: SvgPicture.asset(
            AssetsManager.whatsappIcon,
            height: KSpace.xxl,
            width: KSpace.xxl,
            colorFilter: ColorFilter.mode(
              KColors.of(context).success,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}
