import 'package:cached_network_image/cached_network_image.dart';
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
  const MostBookedBadge({
    super.key,
    required this.serviceId,
    this.tight = false,
  });

  final String? serviceId;

  /// No space below, for a badge sitting on a photo.
  final bool tight;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return ValueListenableBuilder<String?>(
      valueListenable: mostBookedServiceId,
      builder: (BuildContext context, String? id, Widget? child) {
        if (id == null || id != serviceId) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(bottom: tight ? 0 : KSpace.xs),
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
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  translate(AppStrings.chooseYourMainService),
                  style: KType.title.copyWith(color: c.text),
                ),
              ),
              TextButton(
                onPressed: () => _openAll(shown),
                style: TextButton.styleFrom(
                  minimumSize: const Size(KSpace.xxxl, KSpace.xxxl + KSpace.m),
                  padding: const EdgeInsets.symmetric(horizontal: KSpace.xs),
                  foregroundColor: c.brand,
                  textStyle: KType.subhead.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(translate('seeAll')),
              ),
            ],
          ),
          const SizedBox(height: KSpace.xs),
          GridView.count(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: _columns,
            crossAxisSpacing: KSpace.s,
            mainAxisSpacing: KSpace.s,
            childAspectRatio: 0.72,
            children: <Widget>[
              for (final int index in shown.take(_columns * _compactRows))
                _PhotoTile(
                  service: widget.services[index],
                  onTap: () => widget.onOpen(widget.services[index], index),
                ),
            ],
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

/// A service as a photo with its name and price under it. Without a working
/// photo it shows a brand graphic instead of a broken image.
class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.service, required this.onTap});

  final ServiceModel service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final String link = service.icon?.iconLink ?? '';
    final Widget graphic = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[c.brand, c.brandLight],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_car_wash_rounded,
          size: KSpace.xxxl,
          color: c.surface,
        ),
      ),
    );
    return KCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (link.isEmpty)
                  graphic
                else
                  CachedNetworkImage(
                    imageUrl: link,
                    fit: BoxFit.cover,
                    memCacheWidth:
                        (MediaQuery.sizeOf(context).width /
                                2 *
                                MediaQuery.devicePixelRatioOf(context))
                            .round(),
                    placeholder: (BuildContext _, String _) =>
                        ColoredBox(color: c.fill),
                    errorWidget: (BuildContext _, String _, Object _) =>
                        graphic,
                  ),
                PositionedDirectional(
                  top: KSpace.xs,
                  start: KSpace.xs,
                  end: KSpace.xs,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _BadgeOnPhoto(serviceId: service.sId),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(KSpace.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  service.name ?? '',
                  maxLines: 1,
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
          ),
        ],
      ),
    );
  }
}

/// The badge on a solid backing, so it stays readable on any photo.
class _BadgeOnPhoto extends StatelessWidget {
  const _BadgeOnPhoto({required this.serviceId});

  final String? serviceId;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: mostBookedServiceId,
      builder: (BuildContext context, String? id, Widget? child) {
        if (id == null || id != serviceId) return const SizedBox.shrink();
        return DecoratedBox(
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: KColors.of(context).surface,
          ),
          child: MostBookedBadge(serviceId: serviceId, tight: true),
        );
      },
    );
  }
}
