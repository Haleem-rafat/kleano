import 'package:get_it/get_it.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/about_us/bloc/about_us_bloc.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/my_booking/blocs/my_booking/my_booking_bloc.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/notifications/blocs/notifications/notifications_bloc.dart';
import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
import 'package:thewasher/modules/points/bloc/point_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/modules/tracking_order/blocs/socket_bloc.dart';

final sl = GetIt.instance;

class ServiceLocator {
  void init() {
    //Bloc
    sl.registerLazySingleton(() => LocationBloc());
    sl.registerLazySingleton(() => GetUserProfileBloc());
    sl.registerLazySingleton(() => PlansAndSubscriptionBloc());
    sl.registerLazySingleton(() => OffersBloc());
    sl.registerLazySingleton(() => VehiclesBloc());
    sl.registerLazySingleton(() => PromoBloc());
    sl.registerLazySingleton(() => BookingOrderBloc());
    sl.registerLazySingleton(() => MyBookingBloc());
    sl.registerLazySingleton(() => NotificationsBloc());
    sl.registerLazySingleton(() => SocketBloc());
    sl.registerLazySingleton(() => PointBloc());
    sl.registerLazySingleton(() => AboutUsBloc());
  }
}
