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
        return 'KleanO';
      case Flavor.DEV:
        return 'KleanO Dev';
      default:
        return 'title';
    }
  }
}
