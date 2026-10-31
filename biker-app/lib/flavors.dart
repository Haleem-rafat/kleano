enum Flavor {
  PRO,
  DEV,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.PRO:
        return 'Kleano Biker';
      case Flavor.DEV:
        return 'Kleano Biker Dev';
      default:
        return 'title';
    }
  }
}
