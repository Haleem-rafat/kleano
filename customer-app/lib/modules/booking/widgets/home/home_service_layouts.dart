import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_search_field.dart';
import 'package:thewasher/core/design/components/k_sheet.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/data/model/services_model.dart';
import 'package:thewasher/modules/booking/home_style.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';

/// Shows on whichever service the customer has booked most.
class MostBookedBadge extends StatelessWidget {
  const MostBookedBadge({super.key, required this.serviceId});

  final String? serviceId;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return ValueListenableBuilder<String?>(
      valueListenable: mostBookedServiceId,
      builder: (BuildContext context, String? id, Widget? child) {
        if (id == null || id != serviceId) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: KSpace.xs),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: c.warning.withValues(alpha: 0.18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KSpace.s,
                vertical: 2,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '★ ${translate('mostBooked')}',
                  maxLines: 1,
                  style: KType.caption.copyWith(
                    color: c.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

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
                        MostBookedBadge(serviceId: services[i].sId),
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
    this.compact = false,
  });

  final List<ServiceModel> services;
  final ServiceOpen onOpen;

  /// Four across with no search, ending in a See all tile that opens every
  /// service in a sheet.
  final bool compact;

  @override
  State<HomeServiceGrid> createState() => _HomeServiceGridState();
}

class _HomeServiceGridState extends State<HomeServiceGrid> {
  static const int _columns = 3;
  static const int _compactColumns = 4;
  static const int _compactRows = 2;
  static const double _photo = KSpace.xxxl + KSpace.xl;

  String _query = '';

  void _openAll(List<int> shown) {
    showKSheet<void>(
      context: context,
      builder: (BuildContext sheet) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheet).height * 0.6,
        ),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            for (final int index in shown)
              KListRow(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(KRadius.field),
                  child: ImageShared(
                    image: widget.services[index].icon?.iconLink ?? '',
                    height: KSpace.xxxl + KSpace.s,
                    width: KSpace.xxxl + KSpace.s,
                  ),
                ),
                title: widget.services[index].name ?? '',
                subtitle:
                    '${widget.services[index].price ?? ''} ${translate(AppStrings.sAR)}',
                showChevron: true,
                onTap: () {
                  Navigator.of(sheet).pop();
                  widget.onOpen(widget.services[index], index);
                },
              ),
          ],
        ),
      ),
    );
  }

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
    if (widget.compact) {
      final int room = _compactColumns * _compactRows - 1;
      final List<int> first = shown.take(room).toList();
      return GridView.count(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: _compactColumns,
        crossAxisSpacing: KSpace.s,
        mainAxisSpacing: KSpace.s,
        childAspectRatio: 0.6,
        children: <Widget>[
          for (final int index in first)
            KCard(
              padding: const EdgeInsets.all(KSpace.s),
              onTap: () => widget.onOpen(widget.services[index], index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MostBookedBadge(serviceId: widget.services[index].sId),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(KRadius.field),
                    child: ColoredBox(
                      color: c.fill,
                      child: ImageShared(
                        image: widget.services[index].icon?.iconLink ?? '',
                        height: KSpace.xxxl + KSpace.s,
                        width: KSpace.xxxl + KSpace.s,
                      ),
                    ),
                  ),
                  const SizedBox(height: KSpace.xs),
                  Text(
                    widget.services[index].name ?? '',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: KType.caption.copyWith(
                      color: c.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${widget.services[index].price ?? ''} ${translate(AppStrings.sAR)}',
                    maxLines: 1,
                    style: KType.caption.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
          KCard(
            padding: const EdgeInsets.all(KSpace.s),
            onTap: () => _openAll(shown),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.brandTint,
                  ),
                  child: SizedBox.square(
                    dimension: KSpace.xxxl + KSpace.s,
                    child: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_back_rounded
                          : Icons.arrow_forward_rounded,
                      color: c.onBrandTint,
                    ),
                  ),
                ),
                const SizedBox(height: KSpace.xs),
                Text(
                  translate('seeAll'),
                  textAlign: TextAlign.center,
                  style: KType.caption.copyWith(
                    color: c.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
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
                  MostBookedBadge(serviceId: service.sId),
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
