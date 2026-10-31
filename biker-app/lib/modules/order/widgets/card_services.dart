import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';

/// A washing service; tapping it shows what the service includes.
class CardServices extends StatefulWidget {
  final WashingServices service;
  const CardServices({super.key, required this.service});

  @override
  State<CardServices> createState() => _CardServicesState();
}

class _CardServicesState extends State<CardServices> {
  static const double _iconSize = KSpace.xxxl + KSpace.l;

  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final String language = Localizations.localeOf(context).languageCode;
    final String? icon = widget.service.iconWashingServices?.iconLink;
    final int cacheSize = (_iconSize * MediaQuery.devicePixelRatioOf(context))
        .round();
    return KCard(
      onTap: () => setState(() => _open = !_open),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (icon != null) ...<Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(KRadius.field),
                  child: SizedBox.square(
                    dimension: _iconSize,
                    child: ColoredBox(
                      color: c.fill,
                      child: Padding(
                        padding: const EdgeInsets.all(KSpace.s),
                        child: CachedNetworkImage(
                          imageUrl: icon,
                          memCacheWidth: cacheSize,
                          errorWidget:
                              (BuildContext context, String url, Object e) =>
                                  const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: KSpace.m),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.service.getLocalizedName(language) ?? '',
                      style: KType.headline.copyWith(color: c.text),
                    ),
                    const SizedBox(height: KSpace.xs),
                    Row(
                      children: <Widget>[
                        SvgPicture.asset(
                          ImageAssets.serviceCoinSvg,
                          width: KSpace.l,
                          height: KSpace.l,
                          colorFilter: ColorFilter.mode(
                            c.textSecondary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: KSpace.xs),
                        Text(
                          '${widget.service.duration!} '
                          '${tr(context, AppStrings.min)}',
                          style: KType.footnote.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KSpace.s),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: KMotion.of(context, KMotion.normal),
                curve: KMotion.curve,
                child: Icon(Icons.expand_more_rounded, color: c.brand),
              ),
            ],
          ),
          if (_open)
            for (final String line
                in widget.service.getLocalizedDescription(language) ??
                    const <String>[])
              Padding(
                padding: const EdgeInsets.only(top: KSpace.s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(Icons.check, color: c.success, size: KSpace.l),
                    const SizedBox(width: KSpace.s),
                    Expanded(
                      child: Text(
                        line,
                        style: KType.subhead.copyWith(color: c.text),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}
