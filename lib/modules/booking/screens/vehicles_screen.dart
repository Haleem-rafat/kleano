import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/car_model/cars_bloc.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
import 'package:thewasher/modules/my_vehicles/screens/edit_vehicles_screen.dart';
import 'package:thewasher/modules/my_vehicles/screens/empty_vehicles_screen.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/widget/vehicle_shared.dart';
import 'package:thewasher/utilties/navigator.dart';

class VehiclesBookingScreen extends StatefulWidget {
  const VehiclesBookingScreen({Key? key}) : super(key: key);

  @override
  State<VehiclesBookingScreen> createState() => _VehiclesBookingScreenState();
}

class _VehiclesBookingScreenState extends State<VehiclesBookingScreen> {
  int selectedColor = 0;
  late CarsBloc carsBloc;

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
    super.initState();
    carsBloc = CarsBloc();
    sl<VehiclesBloc>().add(GetVehicles());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VehiclesBloc, VehiclesState>(
      bloc: sl<VehiclesBloc>(),
      listener: (context, state) {
        if (state is GetVehiclesError) {
          showSnackBar(
            buildContext: context,
            message: "error something wrong please try again",
          );
        }
      },
      builder: (context, state) {
        if (state is GetVehiclesLoading || state is GetCarModelLoading) {
          return const LoadingWidget();
        } else if (state is GetVehiclesError) {
          return Container();
        } else if (state is GetVehiclesEmpty) {
          return EmptyVehiclesScreen(
            onPressed: () {
              pushPage(context, EditVehiclesScreen(create: true));
            },
          );
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 23.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  translate(AppStrings.yourRecentCars),
                  style:
                      AppStyles.title16Bold.copyWith(color: ColorManager.black),
                ),
                SizedBox(
                  height: 16.h,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2.1,
                  child: ListView.separated(
                    itemCount: sl<VehiclesBloc>().vehiclesList.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: 7.h,
                      );
                    },
                    itemBuilder: (context, int index) {
                      selectedColor = colorList.indexWhere((element) =>
                          element.colorName ==
                          sl<VehiclesBloc>().vehiclesList[index].color!);
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 5.h),
                        child: InkWell(
                          onTap: () {
                            sl<VehiclesBloc>().add(SelectCar(
                                vehicle:
                                    sl<VehiclesBloc>().vehiclesList[index]));
                          },
                          child: VehiclesCard(
                              index: index, selectedColor: selectedColor),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),
                Center(
                  child: ButtonDottedShared(
                    onPressed: () {
                      pushPage(context, EditVehiclesScreen(create: true));
                    },
                    text: translate(AppStrings.addNewVehicles),
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}
