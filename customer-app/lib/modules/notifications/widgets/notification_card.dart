import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/modules/notifications/data/models/notifaction_model.dart';
import 'package:thewasher/modules/notifications/screens/methods/select_notification_type.dart';
import 'package:thewasher/shared/components/snack_bar.dart';

class NotificationCard extends StatefulWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final Notifications notification;
  final VoidCallback onTap;

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
    final KColors c = KColors.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isPromoCode = widget.notification.type == AppConstants.promoCodeBased;

    String bodyText = languageCode == 'en'
        ? widget.notification.message?.enBody ?? ''
        : widget.notification.message?.arBody ?? '';

    String promoCode = '';
    if (isPromoCode) {
      promoCode = _extractPromoCode(bodyText, languageCode);
      if (!_isPromoCodeVisible && promoCode.isNotEmpty) {
        bodyText = _maskPromoCode(bodyText, promoCode, languageCode);
      }
    }
    return KCard(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SvgPicture.asset(
                getImageNotificationType(widget.notification.type!),
              ),
              const SizedBox(width: KSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      languageCode == 'en'
                          ? widget.notification.message?.enTitle ?? ''
                          : widget.notification.message?.arTitle ?? '',
                      style: KType.headline.copyWith(color: c.text),
                    ),
                    const SizedBox(height: KSpace.xs),
                    Text(
                      bodyText,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: KType.subhead.copyWith(color: c.textSecondary),
                    ),
                    if (isPromoCode && promoCode.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          KButton(
                            label: _isPromoCodeVisible
                                ? (languageCode == 'en' ? 'Hide' : 'إخفاء')
                                : (languageCode == 'en' ? 'Show' : 'عرض'),
                            variant: KButtonVariant.text,
                            expand: false,
                            onPressed: () {
                              setState(() {
                                _isPromoCodeVisible = !_isPromoCodeVisible;
                              });
                            },
                          ),
                          if (_isPromoCodeVisible)
                            KButton(
                              label: languageCode == 'en' ? 'Copy' : 'نسخ',
                              variant: KButtonVariant.text,
                              expand: false,
                              onPressed: () => _copyPromoCode(promoCode),
                            ),
                        ],
                      ),
                  ],
                ),
              ),
              if (!widget.notification.isRead!) ...<Widget>[
                const SizedBox(width: KSpace.s),
                Padding(
                  padding: const EdgeInsets.only(top: KSpace.xs),
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: c.brand,
                      shape: const CircleBorder(),
                    ),
                    child: const SizedBox.square(dimension: KSpace.s),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: KSpace.xs),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(
              widget.notification.createdAt! == widget.notification.timeNow
                  ? widget.notification.createdAtByTime!
                  : widget.notification.createdAt!,
              style: KType.footnote.copyWith(color: c.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
