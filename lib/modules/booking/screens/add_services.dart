import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewasher/modules/booking/widgets/add_services/services_list.dart';
import 'package:thewasher/modules/booking/widgets/add_services/subscription_and_services_list.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';

class AddServices extends StatefulWidget {
  const AddServices({super.key});

  @override
  State<AddServices> createState() => _AddServicesState();
}

class _AddServicesState extends State<AddServices> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlansAndSubscriptionBloc, PlansAndSubscriptionState>(
      builder: (context, state) {
        // Check if user is subscribed
        final isSubscribed =
            sl<GetUserProfileBloc>.call().profile.isSubscribed == true;

        // If user is subscribed, show subscription and services
        print("jknsfjksn ${isSubscribed}");
        if (isSubscribed) {
          // Handle different subscription states
          if (state is SubscriptioByLocationSuccessState) {
            return SubscriptionAndService(
              subscription: state.subscription,
              message: state.message,
            );
          } else if (state is SubscriptionByLocationLoading) {
            // Show loading state while fetching subscription
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SubscriptionByLocationFailed) {
            // If subscription fetch failed, show services list as fallback
            return const ServicesList();
          } else {
            // Default case - use bloc's subscription data
            return SubscriptionAndService(
              subscription: sl<PlansAndSubscriptionBloc>.call().subscription,
              message: sl<PlansAndSubscriptionBloc>.call().message,
            );
          }
        } else {
          // User is not subscribed, show services list
          return const ServicesList();
        }
      },
    );
  }
}
