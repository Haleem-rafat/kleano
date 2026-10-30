import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:thewasher/core/utilis/marker_icon.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/Home/component/update_location.dart';
import 'package:thewasher/modules/Home/data/model/address_model.dart';
import 'package:thewasher/modules/Home/data/model/piked_model.dart';
import 'package:thewasher/modules/Home/data/response/saved_location_response.dart';
import 'package:thewasher/repository/home_repo.dart';
import 'package:thewasher/shared/services/location_single_tone.dart';
import 'package:thewasher/shared/services/service_locator.dart';

part 'location_event.dart';
part 'location_state.dart';

LatLng blcoPosition = const LatLng(0, 0);
String blcoCountry = "";
String blcoSubAdministrativeArea = "";
String blcoLocationName = "";
String justLocationName = "";
String fullLocationName = "";
String cityId = "";
String areaId = "";

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  List<AddressModel> savedLocation = [];
  List<AddressModel> recentLocation = [];
  LocationMap locationMap = LocationMap();
  PickedLocationModel pickedLocationModel = PickedLocationModel();

  LocationBloc() : super(LocationInitial()) {
    on<GetSavedLocation>(
        (GetSavedLocation event, Emitter<LocationState> emit) async {
      try {
        debugPrint("Saved Locations ...");
        emit(GetSavedLocationLoading());
        final SavedResponse response = await HomeRepo.getSavedLocations();
        if (response.success) {
          savedLocation = <AddressModel>[];
          // Find the default location from saved locations
          final defaultLocation = response.results!.firstWhere(
            (location) => location.isDefault == true,
            orElse: () => response.results!.first,
          );
          blcoPosition =
              LatLng(defaultLocation.latitude!, defaultLocation.longitude!);
          debugPrint("dsdsaaddaadsdsdas: $blcoPosition");
          justLocationName = defaultLocation.savedName!;
          fullLocationName =
              "${defaultLocation.streetName!} ${defaultLocation.subAdministrativeArea!} ${defaultLocation.country!} ${defaultLocation.savedName!}";
          blcoCountry = defaultLocation.country!;
          blcoSubAdministrativeArea = defaultLocation.subAdministrativeArea!;
          blcoLocationName = defaultLocation.streetName!;
          cityId = defaultLocation.cityId ?? "";
          areaId = defaultLocation.areaId ?? "";
          savedLocation = response.results!;
          emit(GetSavedLocationSuccess(savedLocation: savedLocation));
        } else {
          emit(GetSavedLocationFailed(error: response.error!.first.message));
        }
      } catch (e) {
        emit(GetSavedLocationFailed(error: e.toString()));
      }
    });

    on<SaveLocation>((SaveLocation event, Emitter<LocationState> emit) async {
      try {
        debugPrint("Save Locations ...");
        emit(SaveLocationLoading());
        final SavedResponse response = await HomeRepo.saveLocations(
            event.latitude,
            event.longitude,
            event.streetName,
            event.subAdministrativeArea,
            event.country,
            event.savedName);
        if (response.success) {
          // Get the ID from the saved address and set it as default
          if (response.result?.sId != null) {
            await HomeRepo.setDefaultLocation(response.result!.sId!);
          }
          emit(SaveLocationSuccess(saved: response.result!));
        } else {
          emit(SaveLocationFailed(error: response.error!.first.message));
        }
      } catch (e) {
        emit(SaveLocationFailed(error: e.toString()));
      }
    });

    on<UnSaveLocation>(
        (UnSaveLocation event, Emitter<LocationState> emit) async {
      try {
        debugPrint("Un Save Locations ...");
        emit(UnSaveLocationLoading());
        final bool response = await HomeRepo.unSavedLocations(event.id);
        if (response) {
          if (event.type == "RECENT_LOCATION") {
            savedLocation[event.index].savedName = "";
            recentLocation.insert(0, savedLocation[event.index]);
          }
          savedLocation.removeAt(event.index);
          emit(UnSaveLocationSuccess());
        } else {
          emit(UnSaveLocationFailed(error: "Error"));
        }
      } catch (e) {
        emit(UnSaveLocationFailed(error: e.toString()));
      }
    });

    on<ClearSavedLocation>(
        (ClearSavedLocation event, Emitter<LocationState> emit) async {
      try {
        debugPrint("Clear Save Locations ...");
        emit(ClearSaveLocationLoading());
        final bool response = await HomeRepo.clearSavedLocations();
        if (response) {
          savedLocation.clear();
          emit(ClearSaveLocationSuccess());
        } else {
          emit(ClearSaveLocationFailed(error: "Error"));
        }
      } catch (e) {
        emit(ClearSaveLocationFailed(error: e.toString()));
      }
    });

    on<SavePickedLocation>(
        (SavePickedLocation event, Emitter<LocationState> emit) async {
      try {
        debugPrint("Save Picked Locations ...");
        emit(SavePickedLocationLoading());
        pickedLocationModel = event.pickedLocationModel;
        emit(SavePickedLocationSuccess());
      } catch (e) {
        emit(SavePickedLocationFailed(error: e.toString()));
      }
    });
    on<DeleteLocationById>(
        (DeleteLocationById event, Emitter<LocationState> emit) async {
      try {
        emit(DeleteLocationByIdLoading());
        await HomeRepo.deleteLocationById(event.locationId);
        emit(DeleteLocationByIdSuccess());
      } catch (e) {
        emit(DeleteLocationByIdFailed(error: e.toString()));
      }
    });

    on<GoToLocation>((GoToLocation event, Emitter<LocationState> emit) async {
      try {
        debugPrint("To Locations ...");
        emit(GoToLocationLoading());
        final icon = await MarkerIcon.svgAsset(
            assetName: AssetsManager.pinSvg, context: event.context, size: 24);
        locationMap.search = false;
        locationMap.markers.clear();
        if (!event.current) {
          locationMap.markers.add(Marker(
            markerId: const MarkerId("SomeId"),
            icon: icon,
            position: LatLng(event.latitude, event.longitude),
            infoWindow: InfoWindow(title: event.streetName),
          ));
        }
        sl<LocationBloc>().add(SavePickedLocation(
            pickedLocationModel: PickedLocationModel(
          pickedLocationCountry: event.country,
          pickedLocationName: event.streetName,
          pickedLocationLat: event.latitude,
          pickedLocationLng: event.longitude,
          subAdministrativeArea: event.subAdministrativeArea,
        )));
        locationMap.newLocation = event.latLng;
        sl<OffersBloc>()
          ..add(GetServices(
              lat: event.latitude,
              lng: event.longitude,
              country: event.country))
          ..stream.listen((state) {
            if (state is GetServicesSuccess) {
              sl<OffersBloc>().add(GetAddOns(
                  lat: event.latitude,
                  lng: event.longitude,
                  country: event.country));
            }
          });
        currentLocation(
            event.myController, event.latitude, event.longitude, event.myZoom);
        emit(GoToLocationSuccess());
      } catch (e) {
        emit(GoToLocationFailed(error: e.toString()));
      }
    });

    on<SetDefaultLocation>(
        (SetDefaultLocation event, Emitter<LocationState> emit) async {
      emit(SetDefaultLocationLoading());

      try {
        await HomeRepo.setDefaultLocation(event.locationId);

        // Update the saved locations list to reflect the new default
        for (int i = 0; i < savedLocation.length; i++) {
          savedLocation[i] = AddressModel(
            sId: savedLocation[i].sId,
            latitude: savedLocation[i].latitude,
            longitude: savedLocation[i].longitude,
            streetName: savedLocation[i].streetName,
            subAdministrativeArea: savedLocation[i].subAdministrativeArea,
            country: savedLocation[i].country,
            isSaved: savedLocation[i].isSaved,
            user: savedLocation[i].user,
            createdAt: savedLocation[i].createdAt,
            updatedAt: savedLocation[i].updatedAt,
            type: savedLocation[i].type,
            iV: savedLocation[i].iV,
            savedName: savedLocation[i].savedName,
            isDefault: savedLocation[i].sId == event.locationId,
          );
        }

        emit(SetDefaultLocationSuccess(updatedSavedLocations: savedLocation));
      } catch (e) {
        emit(SetDefaultLocationFailed(error: e.toString()));
      }
    });
  }
}
