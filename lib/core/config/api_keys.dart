import 'package:thewasher/flavors.dart';

class ApiKeys {
  // Google Maps API Keys
  static String get googleApiKey {
    return F.appFlavor == Flavor.DEV
        ? const String.fromEnvironment('DEV_GOOGLE_API_KEY',
            defaultValue: 'AIzaSyBMQiXvjgbjEKXY5PgP9xhoVxDLxeYjYlw')
        : const String.fromEnvironment('PROD_GOOGLE_API_KEY',
            defaultValue: 'AIzaSyBUEaO_7lsxyNpQ4DqxI9CxACmTopgpR14');
  }

  static String get googlePlacecApi {
    return "AIzaSyDAJbdII2kSw5Y8AwuDUT6lt0_ORni6ArI";
  }

  static String get googleApiKeyIos {
    return F.appFlavor == Flavor.DEV
        ? const String.fromEnvironment('DEV_GOOGLE_API_KEY_IOS',
            defaultValue: 'AIzaSyDl8t-bqMb-Rc0QlaJyGg9opcYpN3fyzOk')
        : const String.fromEnvironment('PROD_GOOGLE_API_KEY_IOS',
            defaultValue: 'AIzaSyD7eeF9ETvHwPlih3u5Jo5FWhUmfjf4k2s');
  }

  // Payment API Keys
  static String get publishApiKey {
    return F.appFlavor == Flavor.DEV
        ? const String.fromEnvironment('DEV_PUBLISH_API_KEY',
            defaultValue: 'pk_test_12D7Yngr4ar6ZATfNB1tAyp5EaYScHkexAif6nap')
        : const String.fromEnvironment('PROD_PUBLISH_API_KEY',
            defaultValue: 'pk_live_isaCQRHRVDPTumBkfBMYVGqZVokojDd8w2bgn6Fn');
  }
}
