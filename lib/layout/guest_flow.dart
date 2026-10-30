import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/utilties/navigator.dart';

class LoginFlow {
  static int selectedGuestIndex = 0;
  static guestFlowRoutes(context) {
    switch (selectedGuestIndex) {
      case 0:
        pop(context);
        break;
      case 1:
        popALlAndPushPage(
            context,
            MainNavigationScreen(
              selectedIndex: 1,
            ));
        break;
      case 2:
        popALlAndPushPage(
            context,
            MainNavigationScreen(
              selectedIndex: 2,
            ));
        break;
      case 3:
        popALlAndPushPage(
            context,
            MainNavigationScreen(
              selectedIndex: 3,
            ));
        break;
      default:
    }
  }
}
