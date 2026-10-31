import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/profile/data/models/promo_code_model.dart';
import 'package:thewasher/modules/profile/screens/profile_account/promo_codes/pormo_codes_screen.dart';
import 'package:thewasher/modules/profile/widgets/button_use_promo.dart';

class PromoContainerWidget extends StatelessWidget {
  final PromoCodeModel promoCodeModel;
  final String type;
  final bool isVisible;
  final bool isHighlighted;
  const PromoContainerWidget({
    super.key,
    required this.type,
    required this.promoCodeModel,
    required this.isVisible,
    this.isHighlighted = false,
  });

  bool get _isFixed => promoCodeModel.discountFixedNumber != null;

  String get _discountText {
    if (_isFixed) return '${promoCodeModel.discountFixedNumber}';
    if (promoCodeModel.discountPercentage != null) {
      return '${promoCodeModel.discountPercentage} %';
    }
    return translate(AppStrings.promoTitle);
  }

  bool get _hasDiscount =>
      _isFixed || promoCodeModel.discountPercentage != null;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final bool expired = type == PromoCodeTypes.expired.name;
    final Color accent = expired ? c.error : c.brand;

    Widget riyal(double size) => SvgPicture.asset(
      AssetsManager.saudiRiyalSymbol,
      height: size,
      width: size,
      colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
    );

    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: ShapeDecoration(
        shape: KRadius.shape(
          BorderRadius.circular(KRadius.card),
          side: isHighlighted
              ? BorderSide(color: c.brand, width: 2)
              : BorderSide.none,
        ),
      ),
      child: KCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (isVisible) ...<Widget>[
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: c.brandTint,
                  shape: KRadius.shape(BorderRadius.circular(KRadius.field)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(KSpace.m),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.local_offer_outlined,
                        size: 18,
                        color: c.onBrandTint,
                      ),
                      const SizedBox(width: KSpace.s),
                      Expanded(
                        child: Text(
                          promoCodeModel.code ?? '',
                          style: KType.headline.copyWith(
                            color: c.onBrandTint,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: KSpace.m),
            ],
            Row(
              children: <Widget>[
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: KSpace.xs,
                    children: <Widget>[
                      Text(
                        _discountText,
                        style: KType.title.copyWith(color: accent),
                      ),
                      if (_isFixed) riyal(20),
                      if (_hasDiscount)
                        Text(
                          translate(AppStrings.promoTitle),
                          style: KType.subhead.copyWith(color: c.text),
                        ),
                    ],
                  ),
                ),
                if (!expired) ...<Widget>[
                  const SizedBox(width: KSpace.s),
                  ButtonUsePromoCode(promoCodeModel: promoCodeModel),
                ],
              ],
            ),
            if (promoCodeModel.numberOfUses != null) ...<Widget>[
              const SizedBox(height: KSpace.s),
              KStatusChip(
                label:
                    '${translate(AppStrings.used)}: ${promoCodeModel.numberOfUses}',
                status: expired
                    ? KStatus.error
                    : type == PromoCodeTypes.used.name
                    ? KStatus.neutral
                    : KStatus.brand,
              ),
            ],
            if (promoCodeModel.expiryDate != null) ...<Widget>[
              const SizedBox(height: KSpace.s),
              Text.rich(
                TextSpan(
                  style: KType.footnote.copyWith(color: c.textSecondary),
                  children: <InlineSpan>[
                    TextSpan(
                      text: '${translate(AppStrings.validUp)} $_discountText ',
                    ),
                    if (_isFixed)
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: riyal(12),
                      ),
                    TextSpan(
                      text: type == PromoCodeTypes.used.name
                          ? ' ${promoCodeModel.expiryDate!}'
                          : ' ${translate(AppStrings.expiresDate)} ${promoCodeModel.expiryDate!}',
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
