import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/data/model/address_model.dart';
import 'package:thewasher/modules/Home/screens/home_screen.dart';
import 'package:thewasher/modules/booking/screens/saved_locations_screen.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/layout/main_navigation_screen.dart';

class SetBookingLocationScreen extends StatefulWidget {
  const SetBookingLocationScreen({super.key});

  @override
  State<SetBookingLocationScreen> createState() =>
      _SetBookingLocationScreenState();
}

class _SetBookingLocationScreenState extends State<SetBookingLocationScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  LatLng _selectedLocation =
      const LatLng(24.7136, 46.6753); // Default Riyadh coordinates
  AddressModel? _selectedAddress;

  @override
  void initState() {
    super.initState();
    // Load saved locations
    context.read<LocationBloc>().add(GetSavedLocation());
  }

  void _initializeMapWithDefaultLocation(AddressModel defaultLocation) {
    setState(() {
      _selectedLocation = LatLng(
        defaultLocation.latitude ?? 24.7136,
        defaultLocation.longitude ?? 46.6753,
      );
      _selectedAddress = defaultLocation;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: _selectedLocation,
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: PreferredSize(
          preferredSize: Size(AppSize.s375, AppSize.s60.h),
          child: AppBarShared(
              titleAppBar: translate(AppStrings.setBookingLocation),
              isTextOnly: false)),
      body: BlocListener<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is SetDefaultLocationSuccess) {
            // Navigate to main navigation screen with index 0 and pop all previous pages
            popALlAndPushPage(context, MainNavigationScreen(selectedIndex: 0));
          }
        },
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, state) {
            if (state is GetSavedLocationLoading) {
              return const LoadingWidget();
            } else if (state is GetSavedLocationSuccess) {
              // Find default location and initialize map
              if (_selectedAddress == null && state.savedLocation.isNotEmpty) {
                final defaultLocation = state.savedLocation.firstWhere(
                  (location) => location.isDefault == true,
                  orElse: () => state.savedLocation.first,
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _initializeMapWithDefaultLocation(defaultLocation);
                });
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.verticalSpace,
                    // Upcoming booking location section
                    _buildUpcomingBookingSection(),
                    SizedBox(height: AppPadding.p24.h),

                    // Add location section
                    _buildAddLocationSection(state.savedLocation),
                    SizedBox(height: AppPadding.p24.h),
                  ],
                ),
              );
            } else if (state is GetSavedLocationFailed) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.r,
                      color: ColorManager.red,
                    ),
                    AppPadding.p16.ph,
                    Text(
                      translate(AppStrings.failedToLoadLocations),
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.black,
                      ),
                    ),
                    AppPadding.p16.ph,
                    ElevatedButton(
                      onPressed: () {
                        context.read<LocationBloc>().add(GetSavedLocation());
                      },
                      child: Text(translate(AppStrings.retry)),
                    ),
                  ],
                ),
              );
            }

            return const LoadingWidget();
          },
        ),
      ),
    );
  }

  Widget _buildUpcomingBookingSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate(AppStrings.upcomingBookingLocation),
            style: AppStyles.title16Bold.copyWith(color: ColorManager.black),
          ),
          SizedBox(height: AppPadding.p12.h),

          // Map container
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: ColorManager.black.withValues(alpha: 0.1),
                  blurRadius: 8.r,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: GoogleMap(
                scrollGesturesEnabled: false,
                zoomControlsEnabled: false,
                zoomGesturesEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                mapToolbarEnabled: false,
                initialCameraPosition: CameraPosition(
                  target: _selectedLocation,
                  zoom: 14,
                ),
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                onTap: (LatLng position) {
                  setState(() {
                    _selectedLocation = position;
                    _selectedAddress = AddressModel(
                      latitude: position.latitude,
                      longitude: position.longitude,
                      streetName: translate(AppStrings.customLocation),
                      savedName: translate(AppStrings.customLocation),
                    );
                    _markers.clear();
                    _markers.add(
                      Marker(
                        markerId: const MarkerId('selected_location'),
                        position: position,
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueOrange),
                      ),
                    );
                  });
                },
              ),
            ),
          ),

          SizedBox(height: AppPadding.p12.h),

          // Location details card
          Container(
            padding: EdgeInsets.all(AppPadding.p16.w),
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: ColorManager.darkGrey.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: ColorManager.darkGrey,
                  size: 20.r,
                ),
                SizedBox(width: AppPadding.p8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedAddress?.savedName?.isNotEmpty == true
                            ? _selectedAddress!.savedName!
                            : _selectedAddress?.streetName ??
                                translate(AppStrings.selectedLocation),
                        style: AppStyles.title16Bold
                            .copyWith(color: ColorManager.black),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _selectedAddress?.streetName ??
                            translate(AppStrings.addressNotAvailable),
                        style: AppStyles.subtextGray14Regular
                            .copyWith(color: ColorManager.darkGrey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddLocationSection(List<AddressModel> savedLocations) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                translate(AppStrings.addLocation),
                style:
                    AppStyles.title16Bold.copyWith(color: ColorManager.black),
              ),
              GestureDetector(
                onTap: () {
                  pushPage(context, const SavedLocationsScreen());
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      translate(AppStrings.manageLocations),
                      style: AppStyles.title16Bold
                          .copyWith(color: ColorManager.primary),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: ColorManager.primary,
                      size: 14.r,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppPadding.p16.h),

          // Horizontal scrollable location cards
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: savedLocations.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddLocationCard();
                }

                if (index - 1 < savedLocations.length) {
                  final location = savedLocations[index - 1];
                  return _buildSavedLocationCard(location);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddLocationCard() {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: AppPadding.p12.w),
      decoration: BoxDecoration(
        color: ColorManager.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ColorManager.primary.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            pushPage(context, HomeScreen());
          },
          child: Padding(
            padding: EdgeInsets.all(AppPadding.p12.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_location,
                  color: ColorManager.primary,
                  size: 24.r,
                ),
                SizedBox(height: AppPadding.p8.h),
                Text(
                  translate(AppStrings.addAddress),
                  style: AppStyles.caption12Medium.copyWith(
                    color: ColorManager.primary,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedLocationCard(AddressModel location) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: AppPadding.p12.w),
      decoration: BoxDecoration(
        color: location.isDefault == true
            ? ColorManager.primary
            : ColorManager.darkGrey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: ColorManager.darkGrey.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            // Set this location as selected
            context.read<LocationBloc>().add(SetDefaultLocation(
                  locationId: location.sId!,
                ));
            setState(() {
              _selectedLocation = LatLng(
                location.latitude ?? 24.7136,
                location.longitude ?? 46.6753,
              );
              _selectedAddress = location;
              _markers.clear();
              _markers.add(
                Marker(
                  markerId: const MarkerId('selected_location'),
                  position: _selectedLocation,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueOrange),
                ),
              );
            });

            // Animate map to new location
            _mapController?.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _selectedLocation,
                  zoom: 14,
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(AppPadding.p12.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home,
                  color: location.isDefault == true
                      ? ColorManager.white
                      : ColorManager.black,
                  size: 24.r,
                ),
                SizedBox(height: AppPadding.p8.h),
                Text(
                  location.savedName ?? translate(AppStrings.home),
                  style: AppStyles.caption12Medium.copyWith(
                    color: location.isDefault == true
                        ? ColorManager.white
                        : ColorManager.black,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  location.subAdministrativeArea ?? '',
                  style: AppStyles.caption12Medium.copyWith(
                    color: location.isDefault == true
                        ? ColorManager.white
                        : ColorManager.darkGrey,
                    fontSize: 10.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
