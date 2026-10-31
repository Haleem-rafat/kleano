import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/screens/set_booking_location_screen.dart';
import 'package:thewasher/utilties/navigator.dart';

class ButtonChangeLocation extends StatelessWidget {
  const ButtonChangeLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return KButton(
      label: translate(AppStrings.changeLocation),
      variant: KButtonVariant.secondary,
      expand: false,
      onPressed: () => pushPage(context, SetBookingLocationScreen()),
    );
  }
}
