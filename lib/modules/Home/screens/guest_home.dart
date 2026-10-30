import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/utilis/geocoding_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/fonts_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';

import 'package:thewasher/modules/Home/widget/offer_widget.dart';
import 'package:thewasher/modules/notifications/screens/guest_notification_screen.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class GuestHome extends StatefulWidget {
  void Function() onPressed;
  GuestHome({super.key, required this.onPressed});

  @override
  State<GuestHome> createState() => _GuestHomeState();
}

class _GuestHomeState extends State<GuestHome> {
  LatLng currentPosition = const LatLng(0, 0);
  final Completer<GoogleMapController> _controller = Completer();
  String currentAddress = "";
  String administrativeArea = "";
  double zoom = 14.4746;
  int guestHomeTapIndex = 0;

  void _currentLocation() async {
    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: zoom,
      ),
    ));
  }

  void _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {}
    }
    if (permission == LocationPermission.deniedForever) {}
    var position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));

    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
      GeneralSingleton().currentPositionGuest = currentPosition;
    });
  }

  @override
  void initState() {
    _getUserLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Stack(
        children: <Widget>[
          Column(
            children: [
              SizedBox(
                height: 1.sh,
                child: currentPosition.latitude == 0
                    ? const LoadingWidget()
                    : GoogleMap(
                        onMapCreated: (GoogleMapController controller) async {
                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                  currentPosition.latitude,
                                  currentPosition.longitude);
                          currentAddress = placemarks.first.street!;
                          administrativeArea =
                              placemarks.first.administrativeArea!;
                          GeneralSingleton().country = placemarks.first.country;
                          sl<OffersBloc>()
                            ..add(GetGuestServices(
                                lat: currentPosition.latitude,
                                lng: currentPosition.longitude,
                                country: placemarks.first.country!))
                            ..stream.listen((state) {
                              if (state is GetGuestServicesSuccess) {
                                sl<OffersBloc>().add(GetGuestAddOns(
                                    lat: currentPosition.latitude,
                                    lng: currentPosition.longitude,
                                    country: placemarks.first.country!));
                              }
                            });
                          _controller.complete(controller);
                        },
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: currentPosition,
                          zoom: zoom,
                        ),
                      ),
              )
            ],
          ),
          Positioned(
            top: 150.h,
            child: SizedBox(
                height: 182.h,
                width: 1.sw,
                child: guestHomeTapIndex == 0
                    ? const OfferWidget()
                    : guestHomeTapIndex == 1
                        ? Padding(
                            padding: EdgeInsets.symmetric(horizontal: 29.w),
                            child: Container(
                              height: 200.h,
                              width: 316.w,
                              decoration: BoxDecoration(
                                color: ColorManager.white,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                children: <Widget>[
                                  AppPadding.p8.ph,
                                  Lottie.asset(
                                    'assets/empty.json',
                                    repeat: true,
                                    width: 103.w,
                                    height: 69.h,
                                  ),
                                  AppPadding.p8.ph,
                                  Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 50.w),
                                    child: Text(
                                      translate(AppStrings.enjoyServicesNow),
                                      style: AppStyles.captionGray12Medium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  17.ph,
                                  InkWell(
                                    onTap: () {
                                      Navigator.of(context).push(createRoute());
                                    },
                                    child: Container(
                                      height: 26.h,
                                      width: 84.w,
                                      decoration: BoxDecoration(
                                          color: ColorManager.white,
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          border: Border.all(
                                              color: ColorManager.black)),
                                      child: Center(
                                        child: Text(
                                          translate(AppStrings.explore),
                                          style: AppStyles.titleWhite16Bold
                                              .copyWith(
                                                  color: ColorManager.darkGrey,
                                                  fontSize: FontSize.s10),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.w),
                            child: Container(
                              height: 182.h,
                              width: 316.w,
                              decoration: BoxDecoration(
                                color: ColorManager.white,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                      color:
                                          ColorManager.black.withValues(alpha: .08),
                                      blurRadius: 6.r,
                                      offset: const Offset(0, 3))
                                ],
                              ),
                              padding: EdgeInsets.fromLTRB(
                                AppPadding.p10.w,
                                AppPadding.p10.h,
                                AppPadding.p20.w,
                                0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SvgPicture.asset(AssetsManager.emptyLogoSvg),
                                  Transform.translate(
                                    offset: const Offset(0, -60),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        AssetsManager.emptyRecentWashesSvg,
                                        width: 33.w,
                                        height: 33.h,
                                      ),
                                    ),
                                  ),
                                  Transform.translate(
                                    offset: const Offset(0, -50),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 60.w),
                                      child: Text(
                                        translate(AppStrings.joinUs),
                                        style: AppStyles.caption12Regular
                                            .copyWith(
                                                color: ColorManager.medGray),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  AppPadding.p10.ph,
                                  Transform.translate(
                                    offset: const Offset(0, -40),
                                    child: InkWell(
                                      onTap: () {
                                        popALlAndPushPage(
                                            context, ChooseRegisterView());
                                      },
                                      child: Center(
                                        child: Container(
                                          height: 26.h,
                                          width: 84.w,
                                          decoration: BoxDecoration(
                                              color: ColorManager.white,
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              border: Border.all(
                                                  color: ColorManager.black)),
                                          child: Center(
                                            child: Text(
                                              translate(AppStrings.signUpNow),
                                              style: AppStyles.titleWhite16Bold
                                                  .copyWith(
                                                      color:
                                                          ColorManager.darkGrey,
                                                      fontSize: FontSize.s10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )),
          ),
          Positioned(
            top: 400.h,
            right: 24.w,
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: () {
                    _currentLocation();
                  },
                  child: Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorManager.primary.withValues(alpha: 0.7)),
                    child: const Center(
                      child: Icon(
                        Icons.my_location,
                        color: ColorManager.white,
                      ),
                    ),
                  ),
                ),
                AppPadding.p12.ph,
                InkWell(
                  onTap: () async {
                    final GoogleMapController controller =
                        await _controller.future;
                    var currentZoomLevel = await controller.getZoomLevel();
                    currentZoomLevel = currentZoomLevel + 2;
                    if (currentZoomLevel > 20) currentZoomLevel = 20;
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: currentPosition,
                          zoom: currentZoomLevel,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorManager.primary.withValues(alpha: 0.7)),
                    child: const Center(
                      child: Icon(
                        Icons.add,
                        color: ColorManager.white,
                      ),
                    ),
                  ),
                ),
                AppPadding.p12.ph,
                InkWell(
                  onTap: () async {
                    final GoogleMapController controller =
                        await _controller.future;
                    var currentZoomLevel = await controller.getZoomLevel();
                    currentZoomLevel = currentZoomLevel - 2;
                    if (currentZoomLevel < 0) currentZoomLevel = 0;
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: currentPosition,
                          zoom: currentZoomLevel,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorManager.primary.withValues(alpha: 0.7)),
                    child: const Center(
                      child: Icon(
                        Icons.remove,
                        color: ColorManager.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            child: Container(
              height: 110.h,
              decoration: BoxDecoration(
                  color: ColorManager.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12.r),
                    bottomRight: Radius.circular(12.r),
                  )),
              child: Padding(
                padding: EdgeInsets.fromLTRB(5.w, 25.h, 5.w, 0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        "Hello ...",
                        style: AppStyles.titleWhite16Bold,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            AlertHelper.pointAlert(context);
                          },
                          child: Container(
                            height: 24.h,
                            width: 24.w,
                            decoration: BoxDecoration(
                              color: ColorManager.white.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: SvgPicture.asset(
                              AssetsManager.walletCoin,
                              height: 12.h,
                              width: 12.w,
                              fit: BoxFit.none,
                            ),
                          ),
                        ),
                        13.pw,
                        GestureDetector(
                            onTap: () {
                              pushPage(
                                  context, const GuestNotificationScreen());
                            },
                            child:
                                SvgPicture.asset(AssetsManager.notification)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 90.h,
            left: 16.w,
            right: 16.w,
            child: InkWell(
              onTap: widget.onPressed,
              child: Container(
                height: 50.h,
                width: 343.w,
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p8, vertical: AppPadding.p14),
                child: Text(
                  "Search location...",
                  style: AppStyles.titleGray16Regular,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
