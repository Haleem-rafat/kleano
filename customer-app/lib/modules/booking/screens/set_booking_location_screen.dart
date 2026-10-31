import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/data/model/address_model.dart';
import 'package:thewasher/modules/Home/screens/home_screen.dart';
import 'package:thewasher/modules/booking/screens/saved_locations_screen.dart';
import 'package:thewasher/modules/booking/widgets/location/saved_location_row.dart';
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
  LatLng _selectedLocation = const LatLng(
    24.7136,
    46.6753,
  ); // Default Riyadh coordinates
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
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        ),
      );
    });
  }

  void _selectOnMap(LatLng position) {
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
            BitmapDescriptor.hueViolet,
          ),
        ),
      );
    });
  }

  void _selectSaved(AddressModel location) {
    // Set this location as selected
    context.read<LocationBloc>().add(
      SetDefaultLocation(locationId: location.sId!),
    );
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
            BitmapDescriptor.hueViolet,
          ),
        ),
      );
    });

    // Animate map to new location
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _selectedLocation, zoom: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(translate(AppStrings.setBookingLocation)),
      ),
      body: BlocConsumer<LocationBloc, LocationState>(
        listener: (BuildContext context, LocationState state) {
          if (state is SetDefaultLocationSuccess) {
            // Navigate to main navigation screen with index 0 and pop all previous pages
            popALlAndPushPage(context, MainNavigationScreen(selectedIndex: 0));
          }
        },
        builder: (BuildContext context, LocationState state) {
          if (state is LocationInitial ||
              state is GetSavedLocationLoading ||
              state is SetDefaultLocationLoading) {
            return const KSkeleton.list();
          }
          if (state is GetSavedLocationFailed ||
              state is SetDefaultLocationFailed) {
            return KErrorState(
              message: translate(AppStrings.failedToLoadLocations),
              onRetry: () =>
                  context.read<LocationBloc>().add(GetSavedLocation()),
            );
          }

          final List<AddressModel> locations = context
              .read<LocationBloc>()
              .savedLocation;
          // Find default location and initialize map
          if (_selectedAddress == null && locations.isNotEmpty) {
            final AddressModel defaultLocation = locations.firstWhere(
              (AddressModel location) => location.isDefault == true,
              orElse: () => locations.first,
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _initializeMapWithDefaultLocation(defaultLocation);
            });
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(
              KSpace.xl,
              KSpace.l,
              KSpace.xl,
              MediaQuery.viewPaddingOf(context).bottom + KSpace.xxl,
            ),
            children: <Widget>[
              Text(
                translate(AppStrings.upcomingBookingLocation),
                style: KType.title.copyWith(color: c.text),
              ),
              const SizedBox(height: KSpace.m),
              _buildSelectedCard(c),
              const SizedBox(height: KSpace.xxl),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      translate(AppStrings.savedPlaces),
                      style: KType.title.copyWith(color: c.text),
                    ),
                  ),
                  KButton(
                    label: translate(AppStrings.manageLocations),
                    variant: KButtonVariant.text,
                    expand: false,
                    onPressed: () =>
                        pushPage(context, const SavedLocationsScreen()),
                  ),
                ],
              ),
              const SizedBox(height: KSpace.s),
              _buildSavedCard(c, locations),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSelectedCard(KColors c) {
    return KCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 200,
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
                controller.moveCamera(
                  CameraUpdate.newLatLng(_selectedLocation),
                );
              },
              onTap: _selectOnMap,
            ),
          ),
          KListRow(
            leading: SvgPicture.asset(
              AssetsManager.locationIconLogo,
              colorFilter: ColorFilter.mode(c.brand, BlendMode.srcIn),
            ),
            title: _selectedAddress?.savedName?.isNotEmpty == true
                ? _selectedAddress!.savedName!
                : _selectedAddress?.streetName ??
                      translate(AppStrings.selectedLocation),
            subtitle:
                _selectedAddress?.streetName ??
                translate(AppStrings.addressNotAvailable),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCard(KColors c, List<AddressModel> locations) {
    return KCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          for (final AddressModel location in locations) ...<Widget>[
            SavedLocationRow(
              location: location,
              trailing: location.isDefault == true
                  ? Icon(Icons.check_rounded, color: c.brand)
                  : null,
              onTap: () => _selectSaved(location),
            ),
            Divider(
              height: 1,
              indent: SavedLocationRow.dividerIndent,
              color: c.separator,
            ),
          ],
          KListRow(
            leading: SizedBox.square(
              dimension: 24,
              child: Center(
                child: SvgPicture.asset(
                  AssetsManager.plusLogo,
                  width: KSpace.l,
                  height: KSpace.l,
                  colorFilter: ColorFilter.mode(c.brand, BlendMode.srcIn),
                ),
              ),
            ),
            title: translate(AppStrings.addAddress),
            showChevron: true,
            onTap: () => pushPage(context, const HomeScreen()),
          ),
        ],
      ),
    );
  }
}
