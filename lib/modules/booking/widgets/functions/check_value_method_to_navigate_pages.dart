import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';

bool checkSetValue(int index) {
  final offersBloc = sl<OffersBloc>();
  switch (index) {
    case 0:
      return offersBloc.hasMainService ||
              (sl<PlansAndSubscriptionBloc>().state
                      is! SubscriptionByLocationLoading &&
                  sl<GetUserProfileBloc>.call().profile.isSubscribed == true &&
                  sl<PlansAndSubscriptionBloc>.call().message.isEmpty)
          ? true
          : false;
    case 1:
      return true;
    case 2:
      return sl<VehiclesBloc>.call().selectedVehicle.sId != null ? true : false;
    case 3:
      return true;
    case 4:
      // Valid only when a time has been selected
      return GeneralSingleton().orderTime != null ? true : false;
    default:
      return false;
  }
}
