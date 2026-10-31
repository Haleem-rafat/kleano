import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

class PriceAndPoints extends StatelessWidget {
  final int price;
  final String durationUnit;
  final int pointsToPay, duration;
  const PriceAndPoints({
    super.key,
    required this.price,
    required this.durationUnit,
    required this.pointsToPay,
    required this.duration,
  });

  String getMonth(int duration) {
    if (duration == 1) {
      return translate(AppStrings.month);
    } else if (duration == 2) {
      return translate(AppStrings.months2);
    } else {
      return translate(AppStrings.months);
    }
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    // Arabic has its own singular and dual words, so no number for 1 and 2.
    final bool wordOnly =
        (duration == 1 || duration == 2) &&
        Localizations.localeOf(context).languageCode != 'en';
    return Row(
      children: <Widget>[
        Text('$price ', style: KType.title.copyWith(color: c.text)),
        SvgPicture.asset(
          AssetsManager.saudiRiyalSymbol,
          height: KSpace.l,
          width: KSpace.l,
          colorFilter: ColorFilter.mode(c.text, BlendMode.srcIn),
        ),
        Flexible(
          child: Text(
            wordOnly
                ? ' / ${getMonth(duration)}'
                : ' / $duration ${getMonth(duration)}',
            style: KType.subhead.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}
