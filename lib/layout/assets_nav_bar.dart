import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

String getNavBarIconAsset(int index) {
  switch (index) {
    case 0:
      return AssetsManager.tabBarHomeIconLogo;
    case 1:
      return AssetsManager.vehiclesIconLogo;
    case 2:
      return AssetsManager.bookingsIconLogo;
    case 3:
      return "assets/svg/hot-sale.svg";
    case 4:
    default:
      return AssetsManager.profileIconLogo;
  }
}

String getNavBarIconSelectedAsset(int index) {
  switch (index) {
    case 0:
      return AssetsManager.tabBarHomeSelectedIconLogo;
    case 1:
      return AssetsManager.vehiclesSelectedIconLogo;
    case 2:
      return AssetsManager.bookingsSelectedIconLogo;
    case 3:
      return "assets/svg/hot-sale.svg";
    case 4:
    default:
      return AssetsManager.profileSelectedIconLogo;
  }
}

String getNavBarTitle(int index) {
  switch (index) {
    case 0:
      return AppStrings.home;
    case 1:
      return AppStrings.vehicles;
    case 2:
      return AppStrings.bookings;
    case 3:
      return AppStrings.plans;
    case 4:
      return AppStrings.profile;
    default:
      return "";
  }
}
