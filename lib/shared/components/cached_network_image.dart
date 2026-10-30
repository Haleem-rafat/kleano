import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

class ImageShared extends StatelessWidget {
  final String image;
  final double? raduis;
  final double? height;
  final double? width;
  final double errorFont;
  final BoxFit fit;
  final bool maintainAspectRatio;
  final Alignment alignment;

  const ImageShared({
    super.key,
    required this.image,
    this.raduis,
    this.height,
    this.width,
    required this.errorFont,
    this.fit = BoxFit.contain,
    this.maintainAspectRatio = true,
    this.alignment = Alignment.center,
  });

  // Convenience constructor for landscape images
  const ImageShared.landscape({
    super.key,
    required this.image,
    this.raduis,
    this.height,
    this.width,
    required this.errorFont,
    this.alignment = Alignment.center,
  })  : fit = BoxFit.contain,
        maintainAspectRatio = true;

  // Convenience constructor for portrait images
  const ImageShared.portrait({
    super.key,
    required this.image,
    this.raduis,
    this.height,
    this.width,
    required this.errorFont,
    this.alignment = Alignment.center,
  })  : fit = BoxFit.contain,
        maintainAspectRatio = true;

  // Convenience constructor for square images
  const ImageShared.square({
    super.key,
    required this.image,
    this.raduis,
    required double size,
    required this.errorFont,
    this.alignment = Alignment.center,
  })  : height = size,
        width = size,
        fit = BoxFit.cover,
        maintainAspectRatio = true;

  @override
  Widget build(BuildContext context) {
    return image.isNotEmpty
        ? CachedNetworkImage(
            imageUrl: image,
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            imageBuilder:
                (BuildContext ctx, ImageProvider<Object> imageProvider) {
              return Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  borderRadius:
                      raduis != null ? BorderRadius.circular(raduis!) : null,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: fit,
                    alignment: alignment,
                  ),
                ),
              );
            },
            errorWidget: (BuildContext context, String url, dynamic error) =>
                Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                borderRadius:
                    raduis != null ? BorderRadius.circular(raduis!) : null,
                color: ColorManager.primary.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Text(
                  sl<ProfileBloc>().characterUserName,
                  style: AppStyles.title16Bold.copyWith(
                    color: ColorManager.secondary,
                    fontSize: errorFont,
                  ),
                ),
              ),
            ),
            placeholder: (BuildContext context, String url) => Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                borderRadius:
                    raduis != null ? BorderRadius.circular(raduis!) : null,
                color: ColorManager.primary.withValues(alpha: 0.1),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          )
        : Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius:
                  raduis != null ? BorderRadius.circular(raduis!) : null,
              color: ColorManager.primary.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
