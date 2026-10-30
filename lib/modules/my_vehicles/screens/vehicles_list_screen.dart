import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
import 'package:thewasher/modules/my_vehicles/screens/edit_vehicles_screen.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/widget/vehicle_shared.dart';
import 'package:thewasher/utilties/navigator.dart';

class MyVehicles extends StatefulWidget {
  const MyVehicles({super.key});

  @override
  State<MyVehicles> createState() => _MyVehiclesState();
}

class _MyVehiclesState extends State<MyVehicles> {
  int selectedColor = 0;

  void deleteCar(String? sId, int index) {
    AlertHelper.deleteCarAlert(context, sId!, index);
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    final BorderRadius radius = BorderRadius.circular(KRadius.card);
    final int count = sl<VehiclesBloc>().vehiclesList.length;
    // The add button ends the list, so the floating tab bar and the WhatsApp
    // button never cover it.
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        KSpace.xl,
        KSpace.l,
        KSpace.xl,
        MediaQuery.viewPaddingOf(context).bottom + 140,
      ),
      itemCount: count + 1,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: KSpace.m),
      itemBuilder: (BuildContext context, int index) {
        if (index == count) {
          return KButton(
            label: translate(AppStrings.addNewVehicles),
            variant: KButtonVariant.secondary,
            onPressed: () =>
                pushPage(context, EditVehiclesScreen(create: true)),
          );
        }
        selectedColor = colorList.indexWhere(
          (element) =>
              element.colorName ==
              sl<VehiclesBloc>().vehiclesList[index].color!,
        );
        return InkWell(
          borderRadius: radius,
          onTap: () {
            pushPage(
              context,
              EditVehiclesScreen(
                create: false,
                vehicleData: sl<VehiclesBloc>().vehiclesList[index],
              ),
            );
          },
          child: Slidable(
            startActionPane: ActionPane(
              extentRatio: 0.22,
              motion: const StretchMotion(),
              children: <Widget>[
                SlidableAction(
                  autoClose: false,
                  onPressed: (_) {
                    deleteCar(
                      sl<VehiclesBloc>().vehiclesList[index].sId,
                      index,
                    );
                  },
                  backgroundColor: c.error,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_rounded,
                  borderRadius: radius,
                ),
              ],
            ),
            child: VehiclesCard(index: index, selectedColor: selectedColor),
          ),
        );
      },
    );
  }
}
