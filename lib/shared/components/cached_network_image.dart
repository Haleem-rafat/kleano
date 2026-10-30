import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/shimmering/main_shimmering_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return image != null
        ? CachedNetworkImage(
            imageUrl: image,
            height: height,
            width: width,
            fit: fit,
            imageBuilder: (
              ctx,
              image,
            ) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius:
                      raduis != null ? BorderRadius.circular(raduis!) : null,
                  image: DecorationImage(
                    image: image,
                    fit: fit,
                  ),
                ),
              );
            },
            placeholder: (_, __) {
              return ShimmeringWidget(
                child: Container(
                  color: ColorManager.primary.withOpacity(0.1),
                  width: width,
                  height: height,
                ),
              );
            },
            errorWidget: (context, url, dynamic error) =>
                Image.asset(AssetsManager.logoN),
          )
        : const CircularProgressIndicator();
  }
}
