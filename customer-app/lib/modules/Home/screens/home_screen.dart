import 'package:thewasher/core/design/adaptive_screen.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/utilis/geocoding_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_segmented.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/Home/screens/guest_home.dart';
import 'package:thewasher/modules/plans_and_subscription/screens/plans_subscription_screen.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/location_single_tone.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/modules/Home/screens/search_map_screen.dart';

LatLng currentPosition = const LatLng(0, 0);
String currentAddress = "";
String administrativeArea = "";
String country = "";

class HomeScreen extends StatefulWidget implements KFullWidthPage {
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
  final FocusNode _labelFocus = FocusNode();
  bool enabledAddress = false;

  static const LatLng _initialLatLng = LatLng(31.2001, 29.9187);
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: _initialLatLng,
    zoom: 14.4746,
  );

  @override
  void dispose() {
    searchController.dispose();
    addressController.dispose();
    _labelFocus.dispose();
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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          currentPosition = LatLng(pos.latitude, pos.longitude);
          _cameraTarget = currentPosition;
        });
      }

      if (_controller.isCompleted) {
        try {
          final GoogleMapController controller = await _controller.future;
          await controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                bearing: 0,
                target: LatLng(
                  currentPosition.latitude,
                  currentPosition.longitude,
                ),
                zoom: zoom,
              ),
            ),
          );
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
    // Starts on a label, so a saved address always has a name.
    selectedAddressType = translate(AppStrings.homeLocation);
    addressController.text = selectedAddressType!;
    context.read<GetUserProfileBloc>().add(GetUserProfileEvent());
    _getUserLocation();
  }

  void _currentLocation() async {
    if (!_controller.isCompleted) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
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

  Future<void> _zoomBy(double delta) async {
    if (!_controller.isCompleted) return;
    try {
      final GoogleMapController controller = await _controller.future;
      final double level = await controller.getZoomLevel();
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: locationMap.newLocation == const LatLng(0, 0)
                ? currentPosition
                : locationMap.newLocation,
            zoom: (level + delta).clamp(0, 20).toDouble(),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Zoom error: $e");
    }
  }

  void _selectLabel(String label) {
    final bool other = label == translate(AppStrings.other);
    setState(() {
      selectedAddressType = label;
      enabledAddress = other;
      addressController.text = other ? "" : label;
    });
    if (other) {
      _labelFocus.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final KColors c = KColors.of(context);
    // Read above the Scaffold: it removes the keyboard inset from its body.
    final bool keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      key: homeScaffoldKey,
      backgroundColor: c.surface,
      resizeToAvoidBottomInset: true,
      body: AppShared.token.isEmpty
          ? GuestHome(
              onPressed: () {
                AlertHelper.guestAlert(context);
              },
            )
          : LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double mapHeight =
                    constraints.maxHeight * (keyboardOpen ? 0.4 : 0.6);
                return Stack(
                  children: <Widget>[
                    // The map runs under the panel's rounded corners; its
                    // padding keeps the camera centre (and the Google logo) in
                    // the visible part.
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: mapHeight + KRadius.sheet,
                      child: _buildMap(),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: mapHeight,
                      child: _buildMapOverlay(c, keyboardOpen),
                    ),
                    Positioned(
                      top: mapHeight,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: DecoratedBox(
                        decoration: ShapeDecoration(
                          color: c.surface,
                          shape: const RoundedSuperellipseBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(KRadius.sheet),
                            ),
                          ),
                        ),
                        child: BlocBuilder<OffersBloc, OffersState>(
                          builder: (BuildContext context, OffersState state) {
                            return sl<OffersBloc>().emptyServices
                                ? KEmptyState(
                                    icon: Icons.location_off_rounded,
                                    title: translate(
                                      AppStrings.outOfServiceArea,
                                    ),
                                    message: translate(
                                      AppStrings
                                          .weApologizeServicesNotAvailable,
                                    ),
                                  )
                                : _buildAddAddressUI(c, keyboardOpen);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      key: _mapKey,
      padding: const EdgeInsets.only(bottom: KRadius.sheet),
      onMapCreated: (GoogleMapController controller) {
        if (!_mapCreated && !_controller.isCompleted) {
          _mapCreated = true;
          _controller.complete(controller);

          if (currentPosition.latitude != 0 && currentPosition.longitude != 0) {
            controller
                .animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: currentPosition, zoom: zoom),
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
      minMaxZoomPreference: const MinMaxZoomPreference(3, 20),
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
          final placemarks = await placemarkFromCoordinates(
            _cameraTarget.latitude,
            _cameraTarget.longitude,
          );

          if (!mounted) return;

          country = placemarks.first.country ?? "";
          administrativeArea = placemarks.first.subAdministrativeArea ?? "";
          currentAddress = placemarks.first.street ?? '';

          sl<OffersBloc>().add(
            GetServices(
              lat: _cameraTarget.latitude,
              lng: _cameraTarget.longitude,
              country: "saudi arabia",
            ),
          );
        } catch (e) {
          debugPrint("Reverse geocoding failed: $e");
        }

        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  /// Floating glass controls over the map (Apple Maps style).
  Widget _buildMapOverlay(KColors c, bool keyboardOpen) {
    final double top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: <Widget>[
        // The pin's tip marks the camera centre.
        if (_showCenterPin)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, -KSpace.xl),
                  child: Icon(Icons.location_on, size: 44, color: c.brand),
                ),
              ),
            ),
          ),

        if (!keyboardOpen)
          PositionedDirectional(
            top: top + 124,
            end: KSpace.l,
            child: Column(
              children: <Widget>[
                _buildMapControl(
                  c,
                  icon: CupertinoIcons.restart,
                  sfSymbol: 'arrow.clockwise',
                  onTap: _restartMap,
                ),
                const SizedBox(height: KSpace.m),
                _buildMapControl(
                  c,
                  icon: Icons.my_location,
                  sfSymbol: 'location.fill',
                  onTap: () {
                    if (!mounted) return;
                    setState(() {
                      locationMap.markers.clear();
                    });
                    context.read<OffersBloc>().add(
                      GetServices(
                        lat: currentPosition.latitude,
                        lng: currentPosition.longitude,
                        country: "saudi arabia",
                      ),
                    );
                    _currentLocation();
                  },
                ),
                const SizedBox(height: KSpace.m),
                _buildMapControl(
                  c,
                  icon: Icons.add,
                  sfSymbol: 'plus',
                  onTap: () => _zoomBy(2),
                ),
                const SizedBox(height: KSpace.m),
                _buildMapControl(
                  c,
                  icon: Icons.remove,
                  sfSymbol: 'minus',
                  onTap: () => _zoomBy(-2),
                ),
              ],
            ),
          ),

        Positioned(
          top: top + KSpace.s,
          left: KSpace.l,
          right: KSpace.l,
          child: FoldPane(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if (widget.isFromSignUp == false) ...<Widget>[
                      GlassIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        sfSymbol: 'chevron.backward',
                        color: c.brand,
                        onPressed: () => pop(context),
                      ),
                      const SizedBox(width: KSpace.m),
                    ],
                    Expanded(
                      child: SizedBox(
                        height: KSpace.tapTarget,
                        child: LiquidGlass(
                          capsule: true,
                          child: Center(
                            child: Text(
                              translate(AppStrings.setBookingLocation),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: KType.headline.copyWith(color: c.text),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.isFromSignUp == false)
                      const SizedBox(width: KSpace.tapTarget + KSpace.m),
                  ],
                ),
                const SizedBox(height: KSpace.m),
                Semantics(
                  button: true,
                  label: translate(AppStrings.searchInMap),
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: _handleSearchResult,
                    child: SizedBox(
                      height: KSpace.tapTarget,
                      child: LiquidGlass(
                        capsule: true,
                        padding: const EdgeInsets.symmetric(
                          horizontal: KSpace.l,
                        ),
                        child: Center(
                          child: Row(
                            children: <Widget>[
                              SvgPicture.asset(
                                AssetsManager.search,
                                colorFilter: ColorFilter.mode(
                                  c.textSecondary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: KSpace.s),
                              Expanded(
                                child: Text(
                                  translate(AppStrings.searchInMap),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: KType.body.copyWith(
                                    color: c.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapControl(
    KColors c, {
    required IconData icon,
    required VoidCallback onTap,
    String? sfSymbol,
  }) {
    return GlassIconButton(
      icon: icon,
      sfSymbol: sfSymbol,
      color: c.brand,
      onPressed: onTap,
    );
  }

  Widget _buildAddAddressUI(KColors c, bool keyboardOpen) {
    final String home = translate(AppStrings.homeLocation);
    final String work = translate(AppStrings.work);
    final String other = translate(AppStrings.other);
    final double bottom = MediaQuery.paddingOf(context).bottom;
    return Stack(
      children: <Widget>[
        // The form scrolls under the floating glass button; with the keyboard
        // up it stops above the button, so the field being typed in stays
        // visible.
        Positioned.fill(
          bottom: keyboardOpen ? 72 : 0,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                KSpace.xl,
                KSpace.xl,
                KSpace.xl,
                keyboardOpen ? KSpace.s : bottom + 96,
              ),
              children: <Widget>[
                Text(
                  translate(AppStrings.locationDetails),
                  style: KType.title.copyWith(color: c.text),
                ),
                const SizedBox(height: KSpace.xs),
                Text(
                  currentAddress.isEmpty
                      ? translate(AppStrings.selectALocation)
                      : currentAddress,
                  style: KType.subhead.copyWith(color: c.textSecondary),
                ),
                const SizedBox(height: KSpace.l),
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: KSpace.xs,
                    bottom: KSpace.s,
                  ),
                  child: Text(
                    translate(AppStrings.addressLabel),
                    style: KType.footnote.copyWith(color: c.textSecondary),
                  ),
                ),
                KSegmented<String>(
                  segments: <String, String>{
                    home: home,
                    work: work,
                    other: other,
                  },
                  selected: selectedAddressType ?? home,
                  onChanged: _selectLabel,
                ),
                AnimatedSize(
                  duration: KMotion.of(context, KMotion.fast),
                  curve: KMotion.curve,
                  alignment: AlignmentDirectional.topStart,
                  child: enabledAddress
                      ? Padding(
                          padding: const EdgeInsets.only(top: KSpace.m),
                          child: KTextField(
                            label: translate(AppStrings.other),
                            hint: translate(AppStrings.addressLabel),
                            controller: addressController,
                            focusNode: _labelFocus,
                            textInputAction: TextInputAction.done,
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: KSpace.xl,
          right: KSpace.xl,
          bottom: bottom + KSpace.l,
          child: BlocConsumer<LocationBloc, LocationState>(
            listener: (BuildContext context, LocationState state) {
              if (state is SaveLocationSuccess) {
                pop(context);
                popALlAndPushPage(
                  context,
                  MainNavigationScreen(selectedIndex: 0),
                );
              } else if (state is SaveLocationFailed) {
                showSnackBar(buildContext: context, message: state.error);
              }
            },
            builder: (BuildContext context, LocationState state) {
              return KButton(
                label: translate(AppStrings.addAddress),
                loading: state is SaveLocationLoading,
                onPressed: () {
                  context.read<LocationBloc>().add(
                    SaveLocation(
                      country: country,
                      latitude: currentPosition.latitude.toString(),
                      longitude: currentPosition.longitude.toString(),
                      streetName: currentAddress,
                      subAdministrativeArea: administrativeArea.toString(),
                      savedName:
                          selectedAddressType == translate(AppStrings.other)
                          ? addressController.text
                          : (selectedAddressType ?? addressController.text),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
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

    // The centre pin marks the chosen place once the camera arrives.
    setState(() {
      locationMap.markers.clear();
      locationMap.newLocation = newLatLng!;
      currentPosition = newLatLng!;
      currentAddress = address ?? '';
    });

    if (_controller.isCompleted) {
      try {
        final GoogleMapController controller = await _controller.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: newLatLng, zoom: zoom),
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
