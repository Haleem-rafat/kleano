import 'package:thewhsherbiker/flavors.dart';

class AppConfig {
  static String baseUrl = F.appFlavor == Flavor.PRO
      ? 'https://kleano-backend.onrender.com/api/'
      : 'https://kleano-backend.onrender.com/api/';
  static String imageBase = '$baseUrl/';
  static String getAppBaseUrl() => baseUrl;

  static String socketBaseUrl = F.appFlavor == Flavor.PRO
      ? 'https://kleano-backend.onrender.com/'
      : 'https://kleano-backend.onrender.com/';
  static String getSocketBaseUrl() => socketBaseUrl;
  static String kApiKey = F.appFlavor == Flavor.DEV
      ? "AIzaSyBMQiXvjgbjEKXY5PgP9xhoVxDLxeYjYlw"
      : "AIzaSyBMQiXvjgbjEKXY5PgP9xhoVxDLxeYjYlw";

  static String kApiKeyIos = F.appFlavor == Flavor.DEV
      ? "AIzaSyBqS-h09VgMhT_UWrt0jK8bRg26x9vF-Tk"
      : "AIzaSyBqS-h09VgMhT_UWrt0jK8bRg26x9vF-Tk";
}
