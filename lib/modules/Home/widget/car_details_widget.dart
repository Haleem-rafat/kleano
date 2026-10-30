import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:photo_view/photo_view.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/models/color_model.dart';
import 'package:thewhsherbiker/modules/order/data/model/order_model.dart'
    as order;
import 'package:thewhsherbiker/shared/components/cached_network_image.dart';

class CarDetailsWidget extends StatelessWidget {
  final order.Vehicle? carData;
  const CarDetailsWidget({Key? key, required this.carData}) : super(key: key);

  void _showEnhancedFullScreenImage(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Hero(
          tag: 'car_image_${carData!.plateNumber}',
          child: _EnhancedImageViewer(
            imageUrl: carData!.imageLink!,
            carBrand: carData!.brand ?? 'Unknown',
            carModel: carData!.model ?? 'Model',
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int selectedColor = 0;
    selectedColor = colorList.indexWhere(
        (ColorType element) => element.colorName == carData!.color!);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "${carData!.brand} ${carData!.model}",
            style: AppStyles.body14Medium.copyWith(
              color: ColorManager.darkGrey,
            ),
          ),
          SizedBox(
            width: 213.w,
            child: Divider(
              color: ColorManager.divider,
              thickness: 1,
              height: 10.h,
            ),
          ),
          8.verticalSpace,
          carData!.imageLink != null
              ? GestureDetector(
                  onTap: () => _showEnhancedFullScreenImage(context),
                  child: Hero(
                    tag: 'car_image_${carData!.plateNumber}',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Stack(
                          children: [
                            ImageShared(
                              image: carData!.imageLink!,
                              height: 200.h, // Increased from 94.h
                              width: double
                                  .infinity, // Full width instead of fixed 326.w
                              raduis: 12,
                              errorFont: 14.sp, // Increased font size
                            ),
                            // Overlay with tap indicator
                            Positioned(
                              top: 8.h,
                              right: 8.w,
                              child: Container(
                                padding: EdgeInsets.all(6.r),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 16.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 200.h, // Increased from 94.h
                  width: double.infinity, // Full width
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 50.r, // Increased from 30
                        color: ColorManager.medGray,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'No Image Available',
                        style: AppStyles.caption12Regular.copyWith(
                          color: ColorManager.medGray,
                        ),
                      ),
                    ],
                  ),
                ),
          SizedBox(
            height: 16.h, // Increased spacing
          ),
          RichText(
            text: TextSpan(
              text: translate(AppStrings.plateNo),
              style: AppStyles.caption12Regular.copyWith(
                color: ColorManager.darkGrey,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: " ${carData!.plateNumber}",
                    style: AppStyles.caption12Medium
                        .copyWith(color: ColorManager.medGray)),
              ],
            ),
          ),
          SizedBox(
            height: 4.h,
          ),
          Row(
            children: <Widget>[
              Text(
                translate(AppStrings.color),
                style: AppStyles.caption12Regular.copyWith(
                  color: ColorManager.darkGrey,
                ),
              ),
              4.horizontalSpace,
              Container(
                height: 10.h,
                width: 10.w,
                decoration: BoxDecoration(
                    color: colorList[selectedColor].color,
                    border: selectedColor == 0 ? Border.all() : null,
                    shape: BoxShape.circle),
              ),
              4.horizontalSpace,
              Text('${carData!.color}',
                  style: AppStyles.caption12Medium
                      .copyWith(color: ColorManager.medGray)),
            ],
          ),
          SizedBox(
            height: 14.h,
          ),
        ],
      ),
    );
  }
}

class _EnhancedImageViewer extends StatefulWidget {
  final String imageUrl;
  final String carBrand;
  final String carModel;

  const _EnhancedImageViewer({
    Key? key,
    required this.imageUrl,
    required this.carBrand,
    required this.carModel,
  }) : super(key: key);

  @override
  State<_EnhancedImageViewer> createState() => _EnhancedImageViewerState();
}

class _EnhancedImageViewerState extends State<_EnhancedImageViewer>
    with TickerProviderStateMixin {
  late PhotoViewController _photoViewController;
  late AnimationController _fadeController;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _photoViewController = PhotoViewController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController.forward();

    // Auto-hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _hideControls();
      }
    });
  }

  @override
  void dispose() {
    _photoViewController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _hideControls() {
    if (mounted) {
      setState(() {
        _showControls = false;
      });
      _fadeController.reverse();
    }
  }

  void _showControlsTemporarily() {
    if (mounted) {
      setState(() {
        _showControls = true;
      });
      _fadeController.forward();

      // Auto-hide again after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _hideControls();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main image viewer
          Center(
            child: GestureDetector(
              onTap: _showControlsTemporarily,
              child: PhotoView(
                imageProvider: NetworkImage(widget.imageUrl),
                controller: _photoViewController,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                initialScale: PhotoViewComputedScale.contained,
                backgroundDecoration: const BoxDecoration(
                  color: Colors.black,
                ),
                loadingBuilder: (context, event) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: event == null
                              ? null
                              : event.cumulativeBytesLoaded /
                                  event.expectedTotalBytes!,
                          color: ColorManager.primary,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Loading image...',
                          style: AppStyles.caption12Regular.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 60.r,
                        color: Colors.white70,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Failed to load image',
                        style: AppStyles.body14Medium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Tap to retry',
                        style: AppStyles.caption12Regular.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top controls
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Opacity(
                opacity: _showControls ? _fadeController.value : 0.0,
                child: SafeArea(
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.carBrand} ${widget.carModel}',
                                style: AppStyles.body14Medium.copyWith(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Tap to zoom • Pinch to zoom • Drag to pan',
                                style: AppStyles.caption12Regular.copyWith(
                                  color: Colors.white70,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25.r),
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.close,
                                size: 24.r,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Bottom controls for zoom actions
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _showControls ? _fadeController.value : 0.0,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildZoomButton(
                          icon: Icons.zoom_out,
                          onTap: () {
                            _photoViewController.reset();
                          },
                          label: 'Fit',
                        ),
                        _buildZoomButton(
                          icon: Icons.zoom_in,
                          onTap: () {
                            final currentScale =
                                _photoViewController.scale ?? 1.0;
                            _photoViewController.scale = currentScale * 1.5;
                          },
                          label: 'Zoom In',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(25.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20.r,
                color: Colors.white,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: AppStyles.caption12Regular.copyWith(
                  color: Colors.white70,
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
