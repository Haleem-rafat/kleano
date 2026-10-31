import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/review_order_model.dart';
import 'package:thewasher/modules/my_booking/widgets/wash_section.dart';
import 'package:thewasher/modules/tracking_order/data/models/accepted_biker_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

class BikerDetails extends StatelessWidget {
  static const double _avatarRadius = 24;

  final Biker biker;
  final Location location;
  const BikerDetails({super.key, required this.biker, required this.location});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final bool hasPhone = biker.phone != null && biker.phone!.isNotEmpty;
    return WashSection(
      title: translate(AppStrings.biker),
      padding: EdgeInsets.zero,
      child: WashRows(
        rows: <Widget>[
          KListRow(
            leading: CircleAvatar(
              radius: _avatarRadius,
              backgroundColor: c.brand.withValues(alpha: 0.14),
              child: biker.imageLink != null && biker.imageLink!.isNotEmpty
                  ? ClipOval(
                      child: ImageShared(
                        image: biker.imageLink!,
                        height: _avatarRadius * 2,
                        width: _avatarRadius * 2,
                      ),
                    )
                  : Text(
                      biker.userName != null && biker.userName!.isNotEmpty
                          ? biker.userName!.split(' ').first[0].toUpperCase()
                          : 'B',
                      style: KType.headline.copyWith(color: c.brand),
                    ),
            ),
            title: biker.userName ?? 'Unknown',
          ),
          if (hasPhone) ...<Widget>[
            KListRow(
              leading: SizedBox.square(
                dimension: KSpace.xxl,
                child: Icon(Icons.phone, color: c.brand),
              ),
              title: translate(AppStrings.call),
              trailing: Text(
                biker.phone!,
                style: KType.subhead.copyWith(color: c.textSecondary),
                textDirection: TextDirection.ltr,
              ),
              onTap: () => _callBiker(biker.phone!),
            ),
            KListRow(
              leading: SvgPicture.asset(
                AssetsManager.whatsappIcon,
                height: KSpace.xxl,
                width: KSpace.xxl,
                colorFilter: ColorFilter.mode(c.success, BlendMode.srcIn),
              ),
              title: translate(AppStrings.whatsapp),
              showChevron: true,
              onTap: () => _openWhatsApp(biker.phone!),
            ),
          ],
        ],
      ),
    );
  }

  void _callBiker(String phoneNumber) async {
    final String phone = phoneNumber.replaceAll('+', '').trim();

    try {
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
    } catch (e) {
      debugPrint('Error calling biker: $e');
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    try {
      final String phone = phoneNumber
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
    } catch (e) {
      debugPrint('Error opening WhatsApp: $e');
    }
  }
}
