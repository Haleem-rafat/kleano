import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_search_field.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';

typedef ServiceOpen = void Function(ServiceModel service, int index);

/// Services with the price standing out at the end of each row (Photo hero).
class HomePricedServices extends StatelessWidget {
  const HomePricedServices({
    super.key,
    required this.services,
    required this.onOpen,
  });

  static const double _photo = KSpace.xxxl + KSpace.xl;

  final List<ServiceModel> services;
  final ServiceOpen onOpen;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Column(
      spacing: KSpace.m,
      children: <Widget>[
        for (int i = 0; i < services.length; i++)
          if (services[i].name != '1')
            KCard(
              padding: const EdgeInsets.all(KSpace.m),
              onTap: () => onOpen(services[i], i),
              child: Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(KRadius.field),
                    child: ColoredBox(
                      color: c.fill,
                      child: ImageShared(
                        image: services[i].icon?.iconLink ?? '',
                        height: _photo,
                        width: _photo,
                      ),
                    ),
                  ),
                  const SizedBox(width: KSpace.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          services[i].name ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: KType.headline.copyWith(color: c.text),
                        ),
                        if (services[i].duration != null)
                          Text(
                            '${services[i].duration} ${translate(AppStrings.min)}',
                            style: KType.footnote.copyWith(
                              color: c.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: KSpace.s),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        '${services[i].price ?? ''}',
                        style: KType.title.copyWith(color: c.text),
                      ),
                      Text(
                        translate(AppStrings.sAR),
                        style: KType.caption.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

/// A searchable grid of service tiles (Service grid).
class HomeServiceGrid extends StatefulWidget {
  const HomeServiceGrid({
    super.key,
    required this.services,
    required this.onOpen,
  });

  final List<ServiceModel> services;
  final ServiceOpen onOpen;

  @override
  State<HomeServiceGrid> createState() => _HomeServiceGridState();
}

class _HomeServiceGridState extends State<HomeServiceGrid> {
  static const int _columns = 3;
  static const double _photo = KSpace.xxxl + KSpace.xl;

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final List<int> shown = <int>[
      for (int i = 0; i < widget.services.length; i++)
        if (widget.services[i].name != '1' &&
            (widget.services[i].name ?? '').toLowerCase().contains(
              _query.trim().toLowerCase(),
            ))
          i,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        KSearchField(
          hint: translate('searchServices'),
          onChanged: (String value) => setState(() => _query = value),
        ),
        const SizedBox(height: KSpace.m),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columns,
            crossAxisSpacing: KSpace.s,
            mainAxisSpacing: KSpace.s,
            childAspectRatio: 0.82,
          ),
          itemCount: shown.length,
          itemBuilder: (BuildContext context, int position) {
            final int index = shown[position];
            final ServiceModel service = widget.services[index];
            return KCard(
              padding: const EdgeInsets.all(KSpace.s),
              onTap: () => widget.onOpen(service, index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(KRadius.field),
                    child: ColoredBox(
                      color: c.fill,
                      child: ImageShared(
                        image: service.icon?.iconLink ?? '',
                        height: _photo,
                        width: _photo,
                      ),
                    ),
                  ),
                  const SizedBox(height: KSpace.s),
                  Text(
                    service.name ?? '',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: KType.footnote.copyWith(
                      color: c.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${service.price ?? ''} ${translate(AppStrings.sAR)}',
                    maxLines: 1,
                    style: KType.caption.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
