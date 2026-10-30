import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<void> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferenceTokenKey);
    if (result != null) token = result;
  }

  static Future<dynamic> setRefreshToken(String newRefreshToken) async {
    AppShared.refreshToken = newRefreshToken;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferencesRefreshTokenKey, newRefreshToken);
  }

  static Future<dynamic> getRefreshToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferencesRefreshTokenKey);
    if (result != null) refreshToken = result;
  }

  static Future<void> logOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(sharedPreferencesName);
    prefs.remove(sharedPreferencesPhone);
  }

  static Future<void> setPhone(String newLang) async {
    AppShared.phone = newLang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferencesPhone, newLang);
  }

  static Future<String?> getPhone() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferencesPhone);
    if (result != null) phone = result;
  }

  static Future<void> setPhoneCode(String newLang) async {
    AppShared.phoneCode = newLang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferencesPhoneCode, newLang);
  }

  static Future<String?> getPhoneCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferencesPhoneCode);
    if (result != null) phoneCode = result;
  }

  static Future<void> setFcmValue(String newLang) async {
    AppShared.fcmValue = newLang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferencesFCMValue, newLang);
  }

  static Future<String?> getFcmValue() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferencesFCMValue);
    if (result != null) fcmValue = result;
  }
   static bool isTokenExpired(String token) {
    print(token);
    var expDate = JwtDecoder.getExpirationDate(token);

    bool isExpired = expDate.isBefore(DateTime.now().add(Duration(minutes: 1)))
        ? true
        : false;

    return isExpired;

    // bool isExpired = JwtDecoder.isExpired(token);
    // return isExpired;
  }

  /////////////////////////////////////////
  static Future<void> setFCM(bool newLang) async {
    AppShared.fcm = newLang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(sharedPreferencesFCM, newLang);
  }

  static Future<bool?> getFCM() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? result = prefs.getBool(sharedPreferencesFCM);
    if (result != null) fcm = result;
  }

  static Future<void> setNotification(bool newLang) async {
    AppShared.notification = newLang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(sharedPreferencesNotification, newLang);
  }

  static Future<bool?> getNotification() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? result = prefs.getBool(sharedPreferencesNotification);
    if (result != null) notification = result;
  }

  ////////////////////////////////////////
  static Future<void> setID(String newLang) async {
    AppShared.id = newLang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferencesID, newLang);
  }

  static Future<String?> getID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferencesID);
    if (result != null) id = result;
  }

  static Future<void> setLoad(String newLang) async {
    AppShared.load = newLang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferencesLoadMore, newLang);
  }

  static Future<String?> getLoad() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferencesLoadMore);
    if (result != null) load = result;
  }

  static Future<void> setGender(String newLang) async {
    AppShared.gender = newLang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferencesGender, newLang);
  }

  static Future<String?> getGender() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferencesGender);
    if (result != null) gender = result;
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
  }

  static Future<void> setSubject(String newLang) async {
    AppShared.subject = newLang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferencesSubject, newLang);
  }

  static Future<String?> getSubject() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferencesSubject);
    if (result != null) subject = result;
  }

  static Future<void> setName(String newLang) async {
    AppShared.name = newLang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferencesName, newLang);
  }

  static Future<String?> getName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferencesName);
    if (result != null) name = result;
  }

  static Future<void> setNameAr(String newLang) async {
    AppShared.nameAr = newLang;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(sharedPreferencesNameAr, newLang);
  }

  static Future<String?> getNameAr() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString(sharedPreferencesNameAr);
    if (result != null) nameAr = result;
  }
}
