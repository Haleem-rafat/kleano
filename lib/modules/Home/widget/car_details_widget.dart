import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/models/color_model.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart'
    as order;

/// The customer's car: photo (tap to zoom), plate and colour.
class CarDetailsWidget extends StatelessWidget {
  final order.Vehicle? carData;
  const CarDetailsWidget({super.key, required this.carData});

  void _showFullScreenImage(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: KMotion.of(context, KMotion.normal),
      pageBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) => _CarImageViewer(imageUrl: carData!.imageLink!),
      transitionBuilder:
          (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) => FadeTransition(opacity: animation, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final int selectedColor = colorList.indexWhere(
      (ColorType element) => element.colorName == carData!.color!,
    );
    final TextStyle label = KType.footnote.copyWith(color: c.textSecondary);
    final TextStyle value = KType.subhead.copyWith(color: c.text);
    return KCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${carData!.brand} ${carData!.model}',
            style: KType.headline.copyWith(color: c.text),
          ),
          const SizedBox(height: KSpace.m),
          ClipRRect(
            borderRadius: BorderRadius.circular(KRadius.field),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: carData!.imageLink != null
                  ? _CarPhoto(
                      url: carData!.imageLink!,
                      onTap: () => _showFullScreenImage(context),
                    )
                  : ColoredBox(
                      color: c.fill,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.image_outlined, color: c.textSecondary),
                          const SizedBox(height: KSpace.xs),
                          Text(
                            tr(context, AppStrings.noImageAvailable),
                            style: label,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: KSpace.m),
          Row(
            children: <Widget>[
              Text(tr(context, AppStrings.plateNo), style: label),
              const SizedBox(width: KSpace.xs),
              Expanded(child: Text('${carData!.plateNumber}', style: value)),
            ],
          ),
          const SizedBox(height: KSpace.xs),
          Row(
            children: <Widget>[
              Text(tr(context, AppStrings.color), style: label),
              const SizedBox(width: KSpace.xs),
              DecoratedBox(
                decoration: ShapeDecoration(
                  color: colorList[selectedColor].color,
                  shape: CircleBorder(side: BorderSide(color: c.separator)),
                ),
                child: const SizedBox.square(dimension: KSpace.m),
              ),
              const SizedBox(width: KSpace.xs),
              Expanded(child: Text('${carData!.color}', style: value)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CarPhoto extends StatelessWidget {
  const _CarPhoto({required this.url, required this.onTap});

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              memCacheWidth:
                  (constraints.maxWidth *
                          MediaQuery.devicePixelRatioOf(context))
                      .round(),
              placeholder: (BuildContext context, String url) =>
                  ColoredBox(color: c.fill),
              errorWidget: (BuildContext context, String url, Object error) =>
                  ColoredBox(
                    color: c.fill,
                    child: Icon(Icons.image_outlined, color: c.textSecondary),
                  ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap),
            ),
          ],
        );
      },
    );
  }
}

/// Full-screen zoomable photo on black, whatever the app's theme.
class _CarImageViewer extends StatelessWidget {
  const _CarImageViewer({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    const KColors photo = KColors.dark;
    return Scaffold(
      backgroundColor: photo.background,
      body: Stack(
        children: <Widget>[
          PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrl),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 3.0,
            initialScale: PhotoViewComputedScale.contained,
            backgroundDecoration: BoxDecoration(color: photo.background),
            loadingBuilder: (BuildContext context, ImageChunkEvent? event) =>
                const Center(child: CircularProgressIndicator.adaptive()),
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) =>
                    Center(
                      child: Text(
                        tr(context, AppStrings.errorLoadingImage),
                        textAlign: TextAlign.center,
                        style: KType.body.copyWith(color: photo.text),
                      ),
                    ),
          ),
          SafeArea(
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.all(KSpace.l),
                child: GlassIconButton(
                  icon: Icons.close,
                  sfSymbol: 'xmark',
                  color: photo.text,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
