import 'package:get_it/get_it.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/notification/bloc/notification_bloc.dart';
import 'package:thewhsherbiker/modules/order/bloc/order_bloc.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';

final sl = GetIt.instance;

class ServiceLocator {
  void init() {
    //Bloc
    sl.registerLazySingleton(() => AuthBloc());
    sl.registerLazySingleton(() => ProfileBloc());
    sl.registerLazySingleton(() => HomeBloc());
    sl.registerLazySingleton(() => NotificationBloc());
    sl.registerLazySingleton(() => OrderBloc());
  }
}
