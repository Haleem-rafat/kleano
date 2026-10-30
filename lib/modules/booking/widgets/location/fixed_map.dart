import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class FixedMap extends StatelessWidget {
  final double height;
  final LatLng latLng;
  const FixedMap({
    super.key,
    this.height = 182.23,
    required this.latLng,
    });

  @override
  Widget build(BuildContext context) {
    Set<Circle> circles = <Circle>{
      Circle(
        circleId: const CircleId('id'),
        center: latLng,
        radius: 100,
        fillColor: ColorManager.red,
        strokeWidth: 20,
        strokeColor: ColorManager.secondary.withValues(alpha: .80),
      ),
    };
    return SizedBox(
        height: height.h,
        width: 326.w,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: GoogleMap(
            scrollGesturesEnabled: false,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false,
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            mapToolbarEnabled: false,
            initialCameraPosition: CameraPosition(
                target: latLng,
                zoom: 14),
            onCameraMove: null,
            circles: circles,
          ),
        ));
  }
}
