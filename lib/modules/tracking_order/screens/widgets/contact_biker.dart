import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactBiker extends StatelessWidget {
  final String phoneBiker;
  const ContactBiker({
    super.key,
    required this.phoneBiker,
  });

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
      final String phone =
          phoneBiker.replaceAll('+', '').replaceAll(' ', '').trim();

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
      children: <Widget>[
        GestureDetector(
          onTap: callNumber,
          child: SvgPicture.asset(
            AssetsManager.phoneIcon,
            height: 34.h,
            width: 34.w,
          ),
        ),
        AppPadding.p16.pw,
        GestureDetector(
          onTap: openWhatsApp,
          child: SvgPicture.asset(
            AssetsManager.whatsappIcon,
            height: 22.h,
            width: 22.w,
            colorFilter: ColorFilter.mode(const Color(0xFF25D366), BlendMode.srcIn),
          ),
        ),
      ],
    );
  }
}
