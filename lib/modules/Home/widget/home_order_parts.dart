import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/design/components/k_status_chip.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/utilis/launch_map.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart';

/// `translate` reads a global, so nothing rebuilds when the language changes.
/// Reading the locale here makes the calling widget depend on it, which matters
/// because the Home sections only rebuild for the bloc states they show.
String tr(BuildContext context, String key) {
  Localizations.localeOf(context);
  return translate(key);
}

/// [tr] for words not in `assets/i18n` yet: once [key] is added there, the JSON
/// wins and these fallbacks stop being used.
String trOr(
  BuildContext context,
  String key, {
  required String en,
  required String ar,
}) {
  final String text = tr(context, key);
  if (text != key) return text;
  return Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
}

/// Design-system status for a backend order status.
KStatus orderChipStatus(String? status) => switch (status) {
  'ACCEPTED_BY_BIKER' => KStatus.brand,
  'BIKER_ON_THE_WAY' || 'BIKER_ARRIVED' || 'ON_WASHING' => KStatus.warning,
  'COMPLETED' => KStatus.success,
  _ => KStatus.neutral,
};

/// A round photo, or the first letter of [name] when there is no photo.
class HomeAvatar extends StatelessWidget {
  const HomeAvatar({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.size,
  });

  final String? imageUrl;
  final String? name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final String letter = (name ?? '').trim().characters.take(1).toString();
    final Widget fallback = ColoredBox(
      color: c.brand.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          letter.toUpperCase(),
          style: KType.subhead.copyWith(
            color: c.brand,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
    final String url = imageUrl ?? '';
    final int cacheSize = (size * MediaQuery.devicePixelRatioOf(context))
        .round();
    return ExcludeSemantics(
      child: ClipOval(
        child: SizedBox.square(
          dimension: size,
          child: url.isEmpty
              ? fallback
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  memCacheWidth: cacheSize,
                  memCacheHeight: cacheSize,
                  placeholder: (BuildContext context, String url) => fallback,
                  errorWidget:
                      (BuildContext context, String url, Object error) =>
                          fallback,
                ),
        ),
      ),
    );
  }
}

/// The customer's photo and name on an order card.
class OrderCustomerRow extends StatelessWidget {
  const OrderCustomerRow({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Row(
      children: <Widget>[
        HomeAvatar(
          imageUrl: order.user?.imageLink,
          name: order.user?.userName,
          size: KSpace.xxl,
        ),
        const SizedBox(width: KSpace.s),
        Expanded(
          child: Text(
            order.user?.userName ?? 'N/A',
            style: KType.subhead.copyWith(color: c.text),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// The order's street: opens the map when tapped.
class OrderLocationRow extends StatelessWidget {
  const OrderLocationRow({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(KRadius.field),
      onTap: () async {
        await launchMap(
          lat: order.location?.latitude?.toString() ?? '',
          long: order.location?.longitude?.toString() ?? '',
        );
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: KSpace.tapTarget),
        child: Row(
          children: <Widget>[
            SvgPicture.asset(
              ImageAssets.locationIcon,
              width: KSpace.xxl,
              height: KSpace.xxl,
              colorFilter: ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
            ),
            const SizedBox(width: KSpace.s),
            Expanded(
              child: Text(
                order.location?.streetName ?? 'N/A',
                style: KType.subhead.copyWith(color: c.text),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
