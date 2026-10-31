import 'package:thewasher/flavors.dart';
import 'package:thewasher/core/config/api_keys.dart';

class AppConfig {
  static String baseUrl = F.appFlavor == Flavor.PRO
      ? 'https://kleano-backend.onrender.com/api/'
      : 'https://kleano-backend.onrender.com/api/';
  static String imageBase = '$baseUrl/';
  static String socketUrl = F.appFlavor == Flavor.PRO
      ? 'https://kleano-backend.onrender.com'
      : 'https://kleano-backend.onrender.com';
  static String getAppBaseUrl() => baseUrl;

  // Use secure API keys from ApiKeys class
  static String get kApiKey => ApiKeys.googleApiKey;
  static String get kApiKeyIos => ApiKeys.googleApiKeyIos;
  static String get publishApiKey => ApiKeys.publishApiKey;
  static String get googlePlacecApi => ApiKeys.googlePlacecApi;
}
