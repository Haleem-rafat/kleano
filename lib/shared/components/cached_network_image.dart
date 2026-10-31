import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';

class ImageShared extends StatelessWidget {
  final String image;
  final double? raduis;
  final double height;
  final double width;
  final BoxFit? fit;
  const ImageShared({
    super.key,
    required this.image,
    this.raduis,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
  });

  /// Decode at the size shown, not the size uploaded: full-size photos are the
  /// main cost of scrolling lists. Unbounded sizes fall back to the screen width.
  int _decodeWidth(BuildContext context) {
    final MediaQueryData mq = MediaQuery.of(context);
    final double logical = width.isFinite ? width : mq.size.width;
    return (logical * mq.devicePixelRatio).round();
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return CachedNetworkImage(
      imageUrl: image,
      height: height,
      width: width,
      fit: fit,
      memCacheWidth: _decodeWidth(context),
      fadeInDuration: const Duration(milliseconds: 150),
      imageBuilder: (ctx, image) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: raduis != null ? BorderRadius.circular(raduis!) : null,
            image: DecorationImage(image: image, fit: fit),
          ),
        );
      },
      // A flat fill: an animated shimmer on every card repaints constantly.
      placeholder: (_, _) => ColoredBox(
        color: c.fill,
        child: SizedBox(width: width, height: height),
      ),
      errorWidget: (context, url, dynamic error) =>
          Image.asset(AssetsManager.logoN),
    );
  }
}
