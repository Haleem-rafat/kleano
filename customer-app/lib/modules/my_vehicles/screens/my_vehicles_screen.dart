import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/app_bar.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/car_model/cars_bloc.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/screens/edit_vehicles_screen.dart';
import 'package:thewasher/modules/my_vehicles/screens/empty_vehicles_screen.dart';
import 'package:thewasher/modules/my_vehicles/screens/vehicles_list_screen.dart';
import 'package:thewasher/modules/my_vehicles/widgets/guest_my_vehicles.dart';
import 'package:thewasher/modules/my_vehicles/widgets/vehicles_shimmer_loading.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class MyVehiclesScreen extends StatefulWidget {
  const MyVehiclesScreen({super.key});

  @override
  State<MyVehiclesScreen> createState() => _MyVehiclesScreenState();
}

class _MyVehiclesScreenState extends State<MyVehiclesScreen> {
  late CarsBloc carsBloc;
  bool guest = false;

  // saveCarList() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   if (!prefs.containsKey("carList")) {
  //     carsBloc
  //       ..add(GetCarModel())
  //       ..stream.listen((state) {
  //         if (state is GetCarModelSuccess) {
  //           prefs.setStringList("carList", state.carModel);
  //         }
  //       });
  //   }
  // }

  @override
  void initState() {
    carsBloc = BlocProvider.of<CarsBloc>(context);

    if (AppShared.token.isNotEmpty) {
      // saveCarList();
      sl<VehiclesBloc>().add(GetVehicles());
    } else {
      setState(() {
        guest = true;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.lightStatusBarIconsWithTransparentColorStyle,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(AppSize.s375, 60.h),
          child: AppBarShared(
            titleAppBar: translate(AppStrings.myVehicles),
          ),
        ),
        body: isGuestUser
            ? GuestMyVehicles()
            : BlocConsumer<VehiclesBloc, VehiclesState>(
                bloc: sl<VehiclesBloc>(),
                listener: (context, VehiclesState state) {
                  if (state is GetVehiclesError) {
                    showSnackBar(
                      buildContext: context,
                      message: "error something wrong please try again",
                    );
                  }
                },
                builder: (context, VehiclesState state) {
                  if (state is GetVehiclesLoading ||
                      state is GetCarModelLoading) {
                    return const VehiclesShimmerLoading();
                  } else if (state is GetVehiclesError) {
                    return Container();
                  } else if ((state is GetVehiclesEmpty) && !guest) {
                    return EmptyVehiclesScreen(
                      onPressed: () {
                        pushPage(context, EditVehiclesScreen(create: true));
                      },
                    );
                  } else if (guest) {
                    return EmptyVehiclesScreen(
                      onPressed: () {
                        AlertHelper.guestAlert(context);
                      },
                    );
                  } else {
                    return MyVehicles();
                  }
                },
              ),
      ),
    );
  }
}
