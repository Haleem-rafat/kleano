import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Builds Google Maps marker bitmaps from SVG assets or icon glyphs.
///
/// Replaces the abandoned `custom_marker` package, which pinned flutter_svg 1.x.
/// [size] is in logical pixels; the bitmap is rendered at the device pixel
/// ratio so markers stay sharp on every screen.
class MarkerIcon {
  MarkerIcon._();

  static Future<BitmapDescriptor> svgAsset({
    required String assetName,
    required BuildContext context,
    required double size,
  }) async {
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final String svgString =
        await DefaultAssetBundle.of(context).loadString(assetName);
    final PictureInfo info =
        await vg.loadPicture(SvgStringLoader(svgString), null);

    final int px = (size * dpr).round();
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.scale(px / info.size.width, px / info.size.height);
    canvas.drawPicture(info.picture);
    info.picture.dispose();

    return _toDescriptor(recorder, px, dpr);
  }

  static Future<BitmapDescriptor> markerFromIcon(
    IconData icon,
    Color color,
    double size, {
    double devicePixelRatio = 1,
  }) async {
    final int px = (size * devicePixelRatio).round();
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final TextPainter painter = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: px.toDouble(),
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      )
      ..layout();
    painter.paint(canvas, Offset.zero);

    return _toDescriptor(recorder, px, devicePixelRatio);
  }

  static Future<BitmapDescriptor> _toDescriptor(
      ui.PictureRecorder recorder, int px, double dpr) async {
    final ui.Image image = await recorder.endRecording().toImage(px, px);
    final ByteData? bytes =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: dpr,
    );
  }
}
