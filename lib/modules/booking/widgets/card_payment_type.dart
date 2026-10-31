import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/payment_type_model.dart';

/// One payment method, as a row of a `KCard` group. Laid out like `KListRow`,
/// whose subtitle is plain text and so cannot show the riyal symbol.
class CardPaymentMethod extends StatelessWidget {
  final PaymentMethodModel type;
  final int groupValue;
  final num walletBalance;
  final bool isWallet;
  final VoidCallback? onTap;
  const CardPaymentMethod({
    super.key,
    required this.type,
    required this.groupValue,
    required this.walletBalance,
    required this.isWallet,
    this.onTap,
  });

  static const double _iconSize = 40;

  /// Lines a divider between rows up with the row's title.
  static const double dividerIndent = KSpace.l + _iconSize + KSpace.m;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final bool isSelected = type.value == groupValue;

    return Semantics(
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KSpace.l,
            vertical: KSpace.m,
          ),
          child: Row(
            children: <Widget>[
              DecoratedBox(
                decoration: ShapeDecoration(
                  shape: const CircleBorder(),
                  color: c.brand.withValues(alpha: 0.12),
                ),
                child: SizedBox.square(
                  dimension: _iconSize,
                  child: Padding(
                    padding: const EdgeInsets.all(KSpace.s + KSpace.xs / 2),
                    child: SvgPicture.asset(
                      type.image,
                      colorFilter: ColorFilter.mode(c.brand, BlendMode.srcIn),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: KSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(type.title, style: KType.body.copyWith(color: c.text)),
                    if (isWallet) _buildBalance(c),
                  ],
                ),
              ),
              if (isSelected) ...<Widget>[
                const SizedBox(width: KSpace.s),
                Icon(Icons.check_circle, color: c.brand),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalance(KColors c) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          child: Text(
            '${translate(AppStrings.balance)}: '
            '${walletBalance.toStringAsFixed(2)}',
            style: KType.subhead.copyWith(color: c.textSecondary),
          ),
        ),
        const SizedBox(width: KSpace.xs),
        SvgPicture.asset(
          AssetsManager.saudiRiyalSymbol,
          width: KType.subhead.fontSize,
          height: KType.subhead.fontSize,
          colorFilter: ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
        ),
      ],
    );
  }
}
