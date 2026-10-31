import 'package:dio/dio.dart';
import 'package:thewasher/api/api_path.dart';
import 'package:thewasher/api/api_service.dart';
import 'package:thewasher/modules/Home/data/response/add_ons_response.dart';
import 'package:thewasher/modules/Home/data/response/banner_response.dart';
import 'package:thewasher/modules/Home/data/response/saved_location_response.dart';
import 'package:thewasher/modules/Home/data/response/services_response.dart';

class HomeRepo {
//m3ana
  static Future<SavedResponse> getSavedLocations() async {
    final Response<dynamic>? response = await ApiService.getApi(
      ApiPaths.savedLocation,
      isAuth: true,
    );

    return SavedResponse(
      json: response?.data,
      isList: true,
    );
  }

//m3ana
  static Future<bool> unSavedLocations(String savedId) async {
    final Response<dynamic>? response = await ApiService.patchApi(
      "${ApiPaths.savedLocation}/clear/$savedId",
      isAuth: true,
    );

    return response!.data['success'];
  }

//m3ana
  static Future<bool> clearSavedLocations() async {
    final Response<dynamic>? response = await ApiService.patchApi(
      "${ApiPaths.savedLocation}/clear/all",
      isAuth: true,
    );

    return response!.data['success'];
  }

  static Future<bool> setDefaultLocation(String locationId) async {
    final Response<dynamic>? response = await ApiService.patchApi(
      "/locations/saved-locations/$locationId/default",
      isAuth: true,
    );

    return response!.data['success'];
  }

  static Future<void> deleteLocationById(String locationId) async {
    var response = await ApiService.patchApi(
      "/locations/saved-locations/clear/$locationId",
      isAuth: true,
    );
  }

  static Future<SavedResponse> saveLocations(
      String latitude,
      String longitude,
      String streetName,
      String subAdministrativeArea,
      String country,
      String savedName) async {
    final Response<dynamic>? response = await ApiService.postApi(
      ApiPaths.savedLocation,
      body: <String, dynamic>{
        "latitude": latitude,
        "longitude": longitude,
        "streetName": streetName,
        "subAdministrativeArea": subAdministrativeArea,
        "country": country,
        "savedName": savedName,
      },
      isAuth: true,
    );

    return SavedResponse(
      json: response?.data,
    );
  }

  static Future<ServicesResponse> getServices(
      double lat, double lng, String country, String? serviceType) async {
    final Response<dynamic>? response = await ApiService.getApi(
      "${ApiPaths.washingServices}/all?latitude=${lat.toStringAsFixed(6)}&longitude=${lng.toStringAsFixed(6)}&country=${Uri.encodeQueryComponent(country)}${serviceType != null ? '&type=$serviceType' : ''}",
      isAuth: true,
    );

    return ServicesResponse(
      json: response?.data,
      isList: true,
    );
  }

  static Future<AddOnsResponse> getAddOns(
      double lat, double lng, String country) async {
    final Response<dynamic>? response = await ApiService.getApi(
      "${ApiPaths.washingAddOns}/all?latitude=${lat.toStringAsFixed(6)}&longitude=${lng.toStringAsFixed(6)}&country=${Uri.encodeQueryComponent(country)}",
      isAuth: true,
    );

    return AddOnsResponse(
      json: response?.data,
      isList: true,
    );
  }

  static Future<ServicesResponse> getGuestServices(
      double lat, double lng, String country) async {
    final Response<dynamic>? response = await ApiService.getApi(
      "${ApiPaths.washingGuestServices}/all?latitude=${lat.toStringAsFixed(6)}&longitude=${lng.toStringAsFixed(6)}&country=${Uri.encodeQueryComponent(country)}",
      isAuth: false,
    );

    return ServicesResponse(
      json: response?.data,
      isList: true,
    );
  }

  static Future<AddOnsResponse> getGuestAddOns(
      double lat, double lng, String country) async {
    final Response<dynamic>? response = await ApiService.getApi(
      "${ApiPaths.washingGuestAddOns}/all?latitude=${lat.toStringAsFixed(6)}&longitude=${lng.toStringAsFixed(6)}&country=${Uri.encodeQueryComponent(country)}",
      isAuth: false,
    );

    return AddOnsResponse(
      json: response?.data,
      isList: true,
    );
  }

  static Future<BannersResponse> getAllBanners() async {
    final Response<dynamic>? response = await ApiService.getApi(
      ApiPaths.banners,
      isAuth: false,
    );

    return BannersResponse(
      json: response?.data,
    );
  }
}
