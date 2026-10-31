import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/my_booking/widgets/wash_section.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';

/// The photos the biker sent, side by side. Shows only what the order has, and
/// nothing at all before the first photo. A tap opens one to zoom.
class WashPhotos extends StatelessWidget {
  const WashPhotos({super.key, this.before, this.after});

  final String? before;
  final String? after;

  static const double _height = KSpace.xxxl * 5;

  @override
  Widget build(BuildContext context) {
    final bool hasBefore = before?.isNotEmpty == true;
    final bool hasAfter = after?.isNotEmpty == true;
    if (!hasBefore && !hasAfter) return const SizedBox.shrink();
    return WashSection(
      title: translate(AppStrings.beforeAndAfter),
      child: Row(
        children: <Widget>[
          if (hasBefore)
            Expanded(
              child: _Photo(
                label: translate(AppStrings.beforeWash),
                link: before!,
              ),
            ),
          if (hasBefore && hasAfter) const SizedBox(width: KSpace.m),
          if (hasAfter)
            Expanded(
              child: _Photo(
                label: translate(AppStrings.afterWash),
                link: after!,
              ),
            ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.label, required this.link});

  final String label;
  final String link;

  void _open(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => Dialog(
        insetPadding: const EdgeInsets.all(KSpace.l),
        clipBehavior: Clip.antiAlias,
        child: InteractiveViewer(
          child: CachedNetworkImage(imageUrl: link, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _open(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ImageShared(
              image: link,
              width: double.infinity,
              height: WashPhotos._height,
              raduis: KRadius.field,
            ),
            const SizedBox(height: KSpace.xs),
            Text(label, style: KType.footnote.copyWith(color: c.textSecondary)),
          ],
        ),
      ),
    );
  }
}
