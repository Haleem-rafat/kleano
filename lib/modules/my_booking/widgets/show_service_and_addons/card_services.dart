import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';

/// A service on the wash details screen; tap to read what it includes.
class CardServices extends StatefulWidget {
  final ServiceModel service;
  const CardServices({super.key, required this.service});

  @override
  State<CardServices> createState() => _CardServicesState();
}

class _CardServicesState extends State<CardServices> {
  static const double _iconTileSize = 48;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final Duration duration = KMotion.of(context, KMotion.normal);
    final TextStyle info = KType.footnote.copyWith(color: c.text);
    final ColorFilter tint = ColorFilter.mode(c.textSecondary, BlendMode.srcIn);
    return KCard(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: c.fill,
                  shape: KRadius.shape(BorderRadius.circular(KRadius.field)),
                ),
                child: SizedBox.square(
                  dimension: _iconTileSize,
                  child: Padding(
                    padding: const EdgeInsets.all(KSpace.s),
                    child: Image.network(
                      widget.service.icon != null
                          ? widget.service.icon!.iconLink!
                          : "",
                    ),
                  ),
                ),
              ),
              const SizedBox(width: KSpace.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: KSpace.xs,
                  children: <Widget>[
                    Text(
                      widget.service.name!,
                      style: KType.headline.copyWith(color: c.text),
                    ),
                    Row(
                      children: <Widget>[
                        SvgPicture.asset(
                          AssetsManager.timeIconLogo,
                          colorFilter: tint,
                        ),
                        const SizedBox(width: KSpace.s),
                        Flexible(
                          child: Text(
                            "${widget.service.duration!} ${translate(AppStrings.service)}",
                            style: info,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        SvgPicture.asset(
                          AssetsManager.serviceCoinSvg,
                          colorFilter: tint,
                        ),
                        const SizedBox(width: KSpace.s),
                        Text("${widget.service.price!} ", style: info),
                        SvgPicture.asset(
                          AssetsManager.saudiRiyalSymbol,
                          height: KSpace.m,
                          width: KSpace.m,
                          colorFilter: ColorFilter.mode(
                            c.text,
                            BlendMode.srcIn,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: duration,
                curve: KMotion.curve,
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: duration,
            curve: KMotion.curve,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: KSpace.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: KSpace.xs,
                      children: <Widget>[
                        for (final String description
                            in widget.service.description!)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.check,
                                color: c.textSecondary,
                                size: KSpace.l,
                              ),
                              const SizedBox(width: KSpace.s),
                              Expanded(
                                child: Text(
                                  description,
                                  style: KType.subhead.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
