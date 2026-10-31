import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/design/tokens.dart';

/// A small non-interactive map. Lite mode on Android draws a static image, far
/// cheaper inside a scrolling screen.
class FixedMap extends StatelessWidget {
  final double height;
  final LatLng latLng;
  const FixedMap({super.key, this.height = 182, required this.latLng});

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final Widget map = GoogleMap(
      liteModeEnabled: true,
      scrollGesturesEnabled: false,
      zoomControlsEnabled: false,
      zoomGesturesEnabled: false,
      myLocationButtonEnabled: false,
      myLocationEnabled: false,
      mapToolbarEnabled: false,
      initialCameraPosition: CameraPosition(target: latLng, zoom: 14),
      circles: <Circle>{
        Circle(
          circleId: const CircleId('id'),
          center: latLng,
          radius: 100,
          fillColor: c.brand.withValues(alpha: 0.25),
          strokeWidth: 2,
          strokeColor: c.brand,
        ),
      },
    );
    return SizedBox(height: height, width: double.infinity, child: map);
  }
}
