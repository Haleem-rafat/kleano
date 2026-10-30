import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/notifications/data/models/notifaction_model.dart';
import 'package:thewasher/modules/notifications/screens/methods/select_notification_type.dart';
import 'package:thewasher/shared/components/snack_bar.dart';

class NotificationCard extends StatefulWidget {
  const NotificationCard({
    super.key,
    required this.notification,
  });

  final Notifications notification;

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isPromoCodeVisible = false;

  String _extractPromoCode(String text, String languageCode) {
    // Extract promo code from the text
    // For English: "Use code NEW20..." or "code NEW20"
    // For Arabic: "استخدم الرمز NEW20..." or "الرمز NEW20"

    final codePatterns = languageCode == 'en'
        ? [r'code\s+([A-Z0-9]+)', r'Code\s+([A-Z0-9]+)']
        : [r'الرمز\s+([A-Z0-9]+)'];

    for (final pattern in codePatterns) {
      final regex = RegExp(pattern);
      final match = regex.firstMatch(text);
      if (match != null && match.groupCount >= 1) {
        return match.group(1)!;
      }
    }

    return '';
  }

  String _maskPromoCode(String text, String promoCode, String languageCode) {
    if (promoCode.isEmpty) return text;

    // Replace the promo code with asterisks
    final masked = '*' * promoCode.length;
    return text.replaceAll(promoCode, masked);
  }

  void _copyPromoCode(String promoCode) {
    Clipboard.setData(ClipboardData(text: promoCode));
    showSnackBar(
      buildContext: context,
      message: Localizations.localeOf(context).languageCode == 'en'
          ? 'Promo code copied!'
          : 'تم نسخ الرمز الترويجي!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    final isPromoCode = widget.notification.type == AppConstants.promoCodeBased;

    String bodyText = languageCode == 'en'
        ? widget.notification.message!.enBody!
        : widget.notification.message!.arBody!;

    String promoCode = '';
    if (isPromoCode) {
      promoCode = _extractPromoCode(bodyText, languageCode);
      if (!_isPromoCodeVisible && promoCode.isNotEmpty) {
        bodyText = _maskPromoCode(bodyText, promoCode, languageCode);
      }
    }
    return Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                height: AppSize.s6.h,
                width: AppSize.s6.w,
                child: !widget.notification.isRead!
                    ? CircleAvatar(
                        radius: 3.5.r,
                        backgroundColor: ColorManager.darkPrimary,
                      )
                    : null,
              ),
              AppPadding.p8.pw,
              SizedBox(
                child: SvgPicture.asset(
                  getImageNotificationType(widget.notification.type!),
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          AppPadding.p11.pw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  languageCode == 'en'
                      ? widget.notification.message!.enTitle!
                      : widget.notification.message!.arTitle!,
                  style: AppStyles.caption12Medium.copyWith(
                    color: ColorManager.darkGrey,
                  ),
                ),
                AppPadding.p2.ph,
                Text(
                  bodyText,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: AppStyles.caption12Regular.copyWith(
                    color: ColorManager.darkGrey,
                  ),
                ),
                if (isPromoCode && promoCode.isNotEmpty) ...[
                  AppPadding.p4.ph,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isPromoCodeVisible = !_isPromoCodeVisible;
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isPromoCodeVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 14.sp,
                              color: ColorManager.darkPrimary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              _isPromoCodeVisible
                                  ? (languageCode == 'en' ? 'Hide' : 'إخفاء')
                                  : (languageCode == 'en' ? 'Show' : 'عرض'),
                              style: AppStyles.caption12Regular.copyWith(
                                color: ColorManager.darkPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isPromoCodeVisible) ...[
                        SizedBox(width: 8.w),
                        InkWell(
                          onTap: () => _copyPromoCode(promoCode),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy,
                                size: 14.sp,
                                color: ColorManager.darkPrimary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                languageCode == 'en' ? 'Copy' : 'نسخ',
                                style: AppStyles.caption12Regular.copyWith(
                                  color: ColorManager.darkPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          )
        ],
      ),
      Align(
        alignment:
            languageCode == 'en' ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          widget.notification.createdAt! == widget.notification.timeNow
              ? widget.notification.createdAtByTime!
              : widget.notification.createdAt!,
          style: AppStyles.captionGray12Medium.copyWith(
            fontSize: 10.sp,
          ),
        ),
      ),
    ]);
  }
}
