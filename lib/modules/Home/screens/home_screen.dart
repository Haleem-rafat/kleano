import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/Home/screens/guest_home.dart';
import 'package:thewasher/modules/Home/widget/search_model.dart';
import 'package:thewasher/modules/plans_and_subscription/screens/plans_subscription_screen.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/text-form-shared.dart';
import 'package:thewasher/shared/services/location_single_tone.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/modules/Home/screens/search_map_screen.dart';

LatLng currentPosition = const LatLng(0, 0);
String currentAddress = "";
String administrativeArea = "";
String country = "";

class HomeScreen extends StatefulWidget {
  final bool isFromSignUp;
  const HomeScreen({super.key, this.isFromSignUp = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  GlobalKey _mapKey = GlobalKey();

  Position? position;

  double zoom = 14.4746;
  int homeTapIndex = 0;
  TextEditingController searchController = TextEditingController();

  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  LocationMap locationMap = LocationMap();
  GeneralSingleton generalSingleton = GeneralSingleton();

  BitmapDescriptor? _customMarkerIcon;
  LatLng _cameraTarget = _initialLatLng;
  final bool _showCenterPin = true;
  bool _mapCreated = false;

  String? selectedAddressType;
  TextEditingController addressController = TextEditingController();
  bool enabledAddress = false;

  static const LatLng _initialLatLng = LatLng(31.2001, 29.9187);
  static const CameraPosition _initialCameraPosition =
      CameraPosition(target: _initialLatLng, zoom: 14.4746);

  @override
  void dispose() {
    searchController.dispose();
    locationMap.markers.clear();
    locationMap.newLocation = const LatLng(0, 0);
    super.dispose();
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

    try {
      var pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() {
          currentPosition = LatLng(pos.latitude, pos.longitude);
          _cameraTarget = currentPosition;
        });
      }

      if (_controller.isCompleted) {
        try {
          final GoogleMapController controller = await _controller.future;
          await controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              bearing: 0,
              target:
                  LatLng(currentPosition.latitude, currentPosition.longitude),
              zoom: zoom,
            ),
          ));
        } catch (e) {
          debugPrint("Camera animation error: $e");
        }
      }

      if (_customMarkerIcon != null && mounted) {
        setState(() {
          locationMap.markers.clear();
          locationMap.markers.add(
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: currentPosition,
              icon: _customMarkerIcon!,
            ),
          );
          locationMap.newLocation = currentPosition;
        });
      }
    } catch (e) {
      debugPrint("Error getting user location: $e");
    }
  }

  void _restartMap() {
    if (mounted) {
      setState(() {
        _mapKey = GlobalKey();
        _mapCreated = false;
        _controller = Completer<GoogleMapController>();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<GetUserProfileBloc>().add(GetUserProfileEvent());
    _getUserLocation();
  }

  void _currentLocation() async {
    if (!_controller.isCompleted) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: zoom,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Current location error: $e");
    }
  }

  final controller = PageController(viewportFraction: 0.8, keepPage: true);

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      key: homeScaffoldKey,
      backgroundColor: ColorManager.white,
      resizeToAvoidBottomInset: true,
      body: AppShared.token.isEmpty
          ? GuestHome(
              onPressed: () {
                AlertHelper.guestAlert(context);
              },
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                final availableHeight = constraints.maxHeight - keyboardHeight;

                return Column(
                  children: [
                    // Map Section with dynamic height
                    SizedBox(
                      height: keyboardHeight > 0
                          ? availableHeight *
                              0.4 // Smaller when keyboard is open
                          : availableHeight * 0.6, // Normal size
                      child: Stack(
                        children: [
                          // Map
                          GoogleMap(
                            key: _mapKey,
                            onMapCreated: (GoogleMapController controller) {
                              if (!_mapCreated && !_controller.isCompleted) {
                                _mapCreated = true;
                                _controller.complete(controller);

                                if (currentPosition.latitude != 0 &&
                                    currentPosition.longitude != 0) {
                                  controller
                                      .animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: currentPosition,
                                        zoom: zoom,
                                      ),
                                    ),
                                  )
                                      .catchError((e) {
                                    debugPrint("Initial animation error: $e");
                                  });
                                }
                              }
                            },
                            markers: Set<Marker>.of(locationMap.markers),
                            myLocationEnabled: true,
                            zoomControlsEnabled: false,
                            myLocationButtonEnabled: false,
                            compassEnabled: true,
                            mapToolbarEnabled: false,
                            buildingsEnabled: true,
                            indoorViewEnabled: false,
                            trafficEnabled: false,
                            minMaxZoomPreference:
                                const MinMaxZoomPreference(3, 20),
                            initialCameraPosition: _initialCameraPosition,
                            onCameraMove: (CameraPosition cameraPosition) {
                              _cameraTarget = cameraPosition.target;
                            },
                            onCameraIdle: () async {
                              if (!mounted) return;

                              currentPosition = _cameraTarget;
                              locationMap.newLocation = _cameraTarget;
                              location = _cameraTarget;

                              try {
                                final placemarks =
                                    await placemarkFromCoordinates(
                                  _cameraTarget.latitude,
                                  _cameraTarget.longitude,
                                );

                                if (!mounted) return;

                                country = placemarks.first.country ?? "";
                                administrativeArea =
                                    placemarks.first.subAdministrativeArea ??
                                        "";
                                currentAddress = placemarks.first.street ?? '';

                                sl<OffersBloc>().add(GetServices(
                                  lat: _cameraTarget.latitude,
                                  lng: _cameraTarget.longitude,
                                  country: "saudi arabia",
                                ));
                              } catch (e) {
                                debugPrint("Reverse geocoding failed: $e");
                              }

                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),

                          // Center Pin
                          if (_showCenterPin)
                            Positioned.fill(
                              child: IgnorePointer(
                                ignoring: true,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Transform.translate(
                                        offset: Offset(0, -12.h),
                                        child: Icon(
                                          Icons.location_on,
                                          size: 40.h,
                                          color: ColorManager.secondary,
                                        ),
                                      ),
                                      4.ph,
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          // Right Side Controls
                          Positioned(
                            top: 180.h,
                            right: 16.w,
                            child: Column(
                              children: <Widget>[
                                _buildMapControl(
                                  icon: CupertinoIcons.restart,
                                  onTap: _restartMap,
                                ),
                                12.verticalSpace,
                                _buildMapControl(
                                  icon: Icons.my_location,
                                  onTap: () {
                                    if (!mounted) return;
                                    setState(() {
                                      locationMap.markers.clear();
                                    });
                                    context.read<OffersBloc>().add(GetServices(
                                          lat: currentPosition.latitude,
                                          lng: currentPosition.longitude,
                                          country: "saudi arabia",
                                        ));
                                    _currentLocation();
                                  },
                                ),
                                12.verticalSpace,
                                _buildMapControl(
                                  icon: Icons.add,
                                  onTap: () async {
                                    if (!_controller.isCompleted) return;
                                    try {
                                      final GoogleMapController controller =
                                          await _controller.future;
                                      var currentZoomLevel =
                                          await controller.getZoomLevel();
                                      currentZoomLevel = currentZoomLevel + 2;
                                      if (currentZoomLevel > 20)
                                        currentZoomLevel = 20;
                                      await controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                            target: locationMap.newLocation ==
                                                    const LatLng(0, 0)
                                                ? currentPosition
                                                : locationMap.newLocation,
                                            zoom: currentZoomLevel,
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      debugPrint("Zoom in error: $e");
                                    }
                                  },
                                ),
                                12.verticalSpace,
                                _buildMapControl(
                                  icon: Icons.remove,
                                  onTap: () async {
                                    if (!_controller.isCompleted) return;
                                    try {
                                      final GoogleMapController controller =
                                          await _controller.future;
                                      var currentZoomLevel =
                                          await controller.getZoomLevel();
                                      currentZoomLevel = currentZoomLevel - 2;
                                      if (currentZoomLevel < 0)
                                        currentZoomLevel = 0;
                                      await controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                            target: locationMap.newLocation ==
                                                    const LatLng(0, 0)
                                                ? currentPosition
                                                : locationMap.newLocation,
                                            zoom: currentZoomLevel,
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      debugPrint("Zoom out error: $e");
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),

                          // Search Model Overlay
                          Positioned(
                            top: 140.h,
                            left: 16.w,
                            right: 16.w,
                            child: Visibility(
                              visible: locationMap.search,
                              child: Container(
                                width: 343.w,
                                decoration: BoxDecoration(
                                  color: ColorManager.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.r)),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: ColorManager.black2
                                            .withOpacity(0.08),
                                        offset: const Offset(0, 3),
                                        blurRadius: 10.r),
                                  ],
                                ),
                                child: SearchModel(
                                  currentAddress: currentAddress,
                                  controller: _controller,
                                  onTap: () => _handleSearchResult(),
                                  setOnMap: () {
                                    if (mounted) {
                                      setState(() {
                                        locationMap.search = false;
                                      });
                                    }
                                  },
                                  currentPosition: currentPosition,
                                  subAdministrativeArea: administrativeArea,
                                  country: country,
                                ),
                              ),
                            ),
                          ),

                          // Top Header Bar
                          Container(
                            height: 100.h,
                            decoration: BoxDecoration(
                                color: ColorManager.primary,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12.r),
                                  bottomRight: Radius.circular(12.r),
                                )),
                            child: Padding(
                              padding:
                                  EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 0.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  if (widget.isFromSignUp == false)
                                    GestureDetector(
                                      onTap: () => pop(context),
                                      child: const Icon(
                                        Icons.arrow_back,
                                        color: ColorManager.white,
                                      ),
                                    ),
                                  Expanded(
                                    child: Text(
                                      translate(AppStrings.setBookingLocation),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: ColorManager.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 24.w),
                                ],
                              ),
                            ),
                          ),

                          // Search Bar
                          Positioned(
                            top: 90.h,
                            left: 24.w,
                            right: 24.w,
                            child: InkWell(
                              onTap: () => _handleSearchResult(),
                              child: Container(
                                height: 50.h,
                                width: 343.w,
                                decoration: BoxDecoration(
                                  color: ColorManager.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppPadding.p8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          translate(AppStrings.searchInMap),
                                          style: AppStyles.titleGray16Regular,
                                        ),
                                        SvgPicture.asset(
                                          AssetsManager.search,
                                          color: ColorManager.medGray,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom Sheet Section
                    Expanded(
                      child: BlocBuilder<OffersBloc, OffersState>(
                        builder: (context, state) {
                          final isServiceEmpty = sl<OffersBloc>().emptyServices;

                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: ColorManager.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, -4),
                                ),
                              ],
                            ),
                            child: isServiceEmpty
                                ? _buildOutOfServiceUI()
                                : _buildAddAddressUI(),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildMapControl(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40.h,
        width: 40.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ColorManager.secondary,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 24,
            color: ColorManager.white,
          ),
        ),
      ),
    );
  }

  Widget _buildOutOfServiceUI() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: ColorManager.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              color: ColorManager.red,
              size: 40.sp,
            ),
          ),
          20.verticalSpace,
          Text(
            translate(AppStrings.outOfServiceArea),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: ColorManager.black,
            ),
          ),
          12.verticalSpace,
          Text(
            translate(AppStrings.weApologizeServicesNotAvailable),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorManager.darkGrey,
              height: 1.5,
            ),
          ),
          // 30.verticalSpace,
          // Container(
          //   width: double.infinity,
          //   height: 52.h,
          //   decoration: BoxDecoration(
          //     border: Border.all(
          //       color: ColorManager.secondary,
          //       width: 2,
          //     ),
          //     borderRadius: BorderRadius.circular(8.r),
          //   ),
          //   child: Material(
          //     color: Colors.transparent,
          //     child: InkWell(
          //       onTap: () {
          //         // Navigate to saved locations
          //       },
          //       borderRadius: BorderRadius.circular(8.r),
          //       child: Center(
          //         child: Text(
          //           translate(AppStrings.orSelectSavedLocation),
          //           style: TextStyle(
          //             fontSize: 16.sp,
          //             fontWeight: FontWeight.w600,
          //             color: ColorManager.secondary,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildAddAddressUI() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24.w, 10.w, 24.w,
            MediaQuery.of(context).viewInsets.bottom > 0 ? 20.h : 100.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate(AppStrings.locationDetails),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: ColorManager.black,
              ),
            ),
            4.verticalSpace,
            Text(
              currentAddress.isEmpty
                  ? translate(AppStrings.selectALocation)
                  : currentAddress,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorManager.darkGrey,
              ),
            ),
            10.verticalSpace,
            TextFormShared(
              hintText: translate(AppStrings.addressLabel),
              radius: 8,
              enabled: enabledAddress,
              controller: addressController,
            ),
            12.verticalSpace,
            Text(
              translate(AppStrings.quickLabels),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: ColorManager.black,
              ),
            ),
            10.verticalSpace,
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: [
                _buildAddressChip(translate(AppStrings.homeLocation)),
                _buildAddressChip(translate(AppStrings.work)),
                _buildAddressChip(translate(AppStrings.other)),
              ],
            ),
            12.verticalSpace,
            BlocListener<LocationBloc, LocationState>(
              listener: (context, state) {
                if (state is SaveLocationSuccess) {
                  pop(context);
                  popALlAndPushPage(
                      context, MainNavigationScreen(selectedIndex: 0));
                }
              },
              child: SizedBox(
                width: double.infinity,
                child: BlocBuilder<LocationBloc, LocationState>(
                  builder: (context, state) {
                    return ButtonsShared(
                      onPressed: () {
                        context.read<LocationBloc>().add(SaveLocation(
                              country: country,
                              latitude: currentPosition.latitude.toString(),
                              longitude: currentPosition.longitude.toString(),
                              streetName: currentAddress,
                              subAdministrativeArea:
                                  administrativeArea.toString(),
                              savedName: selectedAddressType ==
                                      translate(AppStrings.other)
                                  ? addressController.text
                                  : (selectedAddressType ??
                                      addressController.text),
                            ));
                      },
                      text: state is SaveLocationLoading
                          ? translate(AppStrings.saving)
                          : translate(AppStrings.addAddress),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddressChip(String label) {
    final isSelected = selectedAddressType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAddressType = label;
          if (label == translate(AppStrings.other)) {
            addressController.text = "";
            enabledAddress = true;
          } else {
            addressController.text = label;
            enabledAddress = false;
          }
        });
      },
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? ColorManager.primary : ColorManager.darkGrey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor:
            isSelected ? ColorManager.primaryLight : ColorManager.lightGray,
        side: BorderSide(
          color: isSelected ? ColorManager.primary : ColorManager.medGray,
          width: isSelected ? 2.0 : 1.5,
        ),
        elevation: isSelected ? 2.0 : 0.0,
        shadowColor: isSelected
            ? ColorManager.primary.withOpacity(0.3)
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }

  Future<void> _handleSearchResult() async {
    if (!mounted) return;

    setState(() {
      locationMap.search = false;
    });

    final result = await pushPageForResult(
      context,
      SearchMapScreen(
        showMap: () {
          if (mounted) {
            setState(() {
              locationMap.search = !locationMap.search;
            });
          }
        },
        handlePressButton: () {},
        showOptions: true,
        country: country,
        administrativeArea: administrativeArea,
        currentAddress: currentAddress,
        currentPosition: currentPosition,
      ),
    );

    if (!mounted) return;

    debugPrint('Returned from SearchMapScreen with:');
    debugPrint(result?.toString() ?? 'null');

    LatLng? newLatLng;
    String? address;
    if (result != null &&
        result['geometry'] != null &&
        result['geometry']['location'] != null) {
      final lat = result['geometry']['location']['lat'];
      final lng = result['geometry']['location']['lng'];
      if (lat != null && lng != null) {
        newLatLng = LatLng(lat, lng);
        address = result['formatted_address'] ?? result['name'] ?? '';
      }
    }

    if (newLatLng == null) {
      debugPrint('No valid LatLng found in result.');
      return;
    }

    setState(() {
      locationMap.markers.clear();
      locationMap.markers.add(
        Marker(
          markerId: const MarkerId('searchedLocation'),
          position: newLatLng!,
          infoWindow: InfoWindow(
            title: address ?? '',
          ),
          icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
        ),
      );
      locationMap.newLocation = newLatLng;
      currentPosition = newLatLng;
      currentAddress = address ?? '';
    });

    if (_controller.isCompleted) {
      try {
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: newLatLng,
              zoom: zoom,
            ),
          ),
        );
      } catch (e) {
        debugPrint("Search animation error: $e");
      }
    }
    debugPrint('Marker set at: ${newLatLng.latitude}, ${newLatLng.longitude}');
  }

  @override
  bool get wantKeepAlive => true;
}
