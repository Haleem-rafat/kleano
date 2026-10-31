import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/data/model/piked_model.dart';
import 'package:thewasher/modules/booking/screens/booking_main_screen.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class LocationConfirmation extends StatelessWidget {
  const LocationConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    final PickedLocationModel location = sl<LocationBloc>().pickedLocationModel;
    return KDialog(
      icon: Lottie.asset(
        'assets/car_lottie.json',
        repeat: true,
        width: 176,
        height: 112,
      ),
      title: translate(AppStrings.yourSureYouLocation),
      actions: <Widget>[
        BlocConsumer<PlansAndSubscriptionBloc, PlansAndSubscriptionState>(
          listener: (BuildContext context, PlansAndSubscriptionState state) {
            if (state is SubscriptioByLocationSuccessState) {
              pushPage(context, const BookingMainScreen());
            }
            if (state is SubscriptionByLocationFailed) {
              pop(context);
              showSnackBar(buildContext: context, message: state.error);
            }
          },
          builder: (BuildContext context, PlansAndSubscriptionState state) {
            return KButton(
              label: translate(AppStrings.continueText),
              loading: state is SubscriptionByLocationLoading,
              onPressed: () {
                if (context.read<GetUserProfileBloc>().profile.isSubscribed!) {
                  context.read<PlansAndSubscriptionBloc>().add(
                    GetSubscriptionUserByLocation(
                      latitude: location.pickedLocationLat!,
                      longitude: location.pickedLocationLng!,
                      country: location.pickedLocationCountry!,
                    ),
                  );
                } else {
                  pushPage(context, const BookingMainScreen());
                }
              },
            );
          },
        ),
        KButton(
          label: translate(AppStrings.changeLocation),
          variant: KButtonVariant.text,
          onPressed: () => pop(context),
        ),
      ],
    );
  }
}
