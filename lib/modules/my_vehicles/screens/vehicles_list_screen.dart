import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
import 'package:thewasher/modules/my_vehicles/screens/edit_vehicles_screen.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/widget/vehicle_shared.dart';
import 'package:thewasher/utilties/navigator.dart';

class MyVehicles extends StatefulWidget {
  MyVehicles({
    Key? key,
  }) : super(key: key);

  @override
  State<MyVehicles> createState() => _MyVehiclesState();
}

class _MyVehiclesState extends State<MyVehicles> {
  int selectedColor = 0;

  deleteCar(
    String? sId,
    int index,
  ) {
    AlertHelper.deleteCarAlert(context, sId!, index);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 23.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppPadding.p23.ph,
          Text(
            translate(AppStrings.myVehicles),
            style: AppStyles.title16Bold.copyWith(color: ColorManager.darkGrey),
          ),
          AppPadding.p20.ph,
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.7,
            child: ListView.separated(
              itemCount: sl<VehiclesBloc>().vehiclesList.length,
              separatorBuilder: (BuildContext context, int index) {
                return 7.ph;
              },
              itemBuilder: (context, int index) {
                selectedColor = colorList.indexWhere((element) =>
                    element.colorName ==
                    sl<VehiclesBloc>().vehiclesList[index].color!);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                  child: InkWell(
                    onTap: () {
                      pushPage(
                          context,
                          EditVehiclesScreen(
                              create: false,
                              vehicleData:
                                  sl<VehiclesBloc>().vehiclesList[index]));
                    },
                    child: Slidable(
                      startActionPane: ActionPane(
                        extentRatio: 0.2,
                        motion: const StretchMotion(),
                        children: [
                          SlidableAction(
                              autoClose: false,
                              onPressed: (_) {
                                deleteCar(
                                    sl<VehiclesBloc>().vehiclesList[index].sId,
                                    index);
                              },
                              backgroundColor: ColorManager.red,
                              foregroundColor: ColorManager.white,
                              icon: Icons.delete,
                              label: '',
                              borderRadius: BorderRadius.only(
                                bottomLeft: Localizations.localeOf(context)
                                            .languageCode ==
                                        "en"
                                    ? Radius.circular(15.r)
                                    : Radius.circular(0.r),
                                topLeft: Localizations.localeOf(context)
                                            .languageCode ==
                                        "en"
                                    ? Radius.circular(15.r)
                                    : Radius.circular(0.r),
                                bottomRight: Localizations.localeOf(context)
                                            .languageCode ==
                                        "en"
                                    ? Radius.circular(0.r)
                                    : Radius.circular(15.r),
                                topRight: Localizations.localeOf(context)
                                            .languageCode ==
                                        "en"
                                    ? Radius.circular(0.r)
                                    : Radius.circular(15.r),
                              )),
                        ],
                      ),
                      child: VehiclesCard(
                          index: index, selectedColor: selectedColor),
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: ButtonDottedShared(
              onPressed: () {
                pushPage(context, EditVehiclesScreen(create: true));
              },
              text: translate(AppStrings.addNewVehicles),
            ),
          ),
        ],
      ),
    );
  }
}
