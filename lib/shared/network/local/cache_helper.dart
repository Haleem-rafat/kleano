class CacheHelper {
  static bool isHost = false;
  static bool isAuth = false;
  static String sharedPreferencesRefreshTokenKey = "RefreshToken";
  static late String token;
  static late String refreshToken;

  static Future<void> setAuth(bool isAuth) async {}

  static Future<void> getAuth() async {}

  static Future<void> getUser() async {}

  static Future<void> saveUser() async {}

  static Future<void> deleteUser() async {}

  static Future<void> getToken() async {}

  static Future<dynamic> setRefreshToken(String newRefreshToken) async {}

  static Future<dynamic> getRefreshToken() async {}
}
