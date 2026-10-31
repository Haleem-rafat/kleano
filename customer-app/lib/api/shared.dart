import 'package:flutter/foundation.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/my_booking/blocs/my_booking/my_booking_bloc.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/vehicles_model.dart';
import 'package:thewasher/modules/notifications/blocs/notifications/notifications_bloc.dart';
import 'package:thewasher/modules/points/bloc/point_bloc.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';

bool isGuestUser = false;

class AppShared {
  static String sharedPreferenceUserKey = "user";
  static String sharedPreferenceTokenKey = "Token";
  static String sharedPreferencesRefreshTokenKey = "RefreshToken";
  static const String sharedPreferencesPhone = 'phone';
  static const String sharedPreferencesPhoneCode = 'phoneCode';
  static const String sharedPreferencesID = 'id';
  static const String sharedPreferencesName = 'name';
  static const String sharedPreferencesNameAr = 'nameAr';
  static const String sharedPreferencesGender = 'gender';
  static const String sharedPreferencesCountry = 'country';
  static const String sharedPreferencesSubject = 'subjectName';
  static const String sharedPreferencesLoadMore = 'loadMore';
  static const String sharedPreferencesFCM = 'fcm';
  static const String sharedPreferencesFCMValue = 'fcmValue';
  static const String sharedPreferencesNotification = 'Notification';
  static String lang = 'en';
  static String? fcmToken;

  static int language() {
    return lang == 'en' ? 2 : 1;
  }

  static bool isRTL() {
    return language() == 1;
  }

  static String token = "";
  static String refreshToken = "";
  static String phone = "";
  static String phoneCode = "";
  static String id = "";
  static String name = "";
  static String nameAr = "";
  static String gender = "";
  static String country = "";
  static String subject = "";
  static String load = "";
  static String fcmValue = "";
  static bool notification = false;
  static bool fcm = false;

  static Future<void> setToken(String userToken) async {
    AppShared.token = userToken;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferenceTokenKey, userToken);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferenceTokenKey);
    if (result != null) token = result;
    return result;
  }

  static Future<dynamic> setRefreshToken(String newRefreshToken) async {
    AppShared.refreshToken = newRefreshToken;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferencesRefreshTokenKey, newRefreshToken);
  }

  static Future<String?> getRefreshToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferencesRefreshTokenKey);
    if (result != null) refreshToken = result;
    return result;
  }

  static Future<void> logOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(sharedPreferencesName);
    prefs.remove(sharedPreferencesPhone);
  }

  static bool isTokenExpired(String token) {
    // Treat unreadable tokens as expired so they get refreshed, not crash.
    try {
      return JwtDecoder.getExpirationDate(token)
          .isBefore(DateTime.now().add(const Duration(minutes: 1)));
    } catch (_) {
      return true;
    }
  }


  static Future<void> setCountry(String newLang) async {
    AppShared.country = newLang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferencesCountry, newLang);
  }

  static Future<String?> getCountry() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferencesCountry);
    if (result != null) country = result;
    return result;
  }

  /// Clears all local storage data and resets app state.
  ///
  /// This method:
  /// - Clears all SharedPreferences data
  /// - Resets all static variables in AppShared
  /// - Resets the GeneralSingleton data
  /// - Clears all BLoC states
  /// - Clears localization preferences
  ///
  /// Use this when you want to completely reset the app state,
  /// such as after an app update or user logout.
  static Future<void> clearAllData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Reset static variables
    token = "";
    refreshToken = "";
    phone = "";
    phoneCode = "";
    id = "";
    name = "";
    nameAr = "";
    gender = "";
    country = "";
    subject = "";
    load = "";
    fcmValue = "";
    notification = false;
    fcm = false;

    // Reset singleton data
    GeneralSingleton().resetAll();

    // Reset BLoC states
    _resetBlocStates();

    // Clear localization preferences
    await _clearLocalizationPreferences();
  }

  // Reset all BLoC states
  static void _resetBlocStates() {
    try {
      // Clear OffersBloc cart data
      final offersBloc = sl<OffersBloc>();
      offersBloc.cartServicesList.clear();
      offersBloc.cartAddOnsList.clear();
      offersBloc.cartServicesListString.clear();
      offersBloc.cartAddOnsListString.clear();
      offersBloc.total = 0;

      // Clear VehiclesBloc selected vehicle
      final vehiclesBloc = sl<VehiclesBloc>();
      vehiclesBloc.selectedVehicle = VehiclesModel();

      // Clear LocationBloc data
      final locationBloc = sl<LocationBloc>();
      locationBloc.savedLocation.clear();
      locationBloc.recentLocation.clear();

      // Clear BookingOrderBloc data
      final bookingOrderBloc = sl<BookingOrderBloc>();
      bookingOrderBloc.paymentType = 0;
      bookingOrderBloc.isSubscribed = false;

      // Clear other BLoCs as needed
      sl<NotificationsBloc>();
      sl<PointBloc>();
      sl<PromoBloc>();
      sl<MyBookingBloc>();
    } catch (e) {
      // Handle any errors when resetting BLoC states
      debugPrint('Error resetting BLoC states: $e');
    }
  }

  // Clear localization preferences
  static Future<void> _clearLocalizationPreferences() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_locale');
    } catch (e) {
      debugPrint('Error clearing localization preferences: $e');
    }
  }
}
