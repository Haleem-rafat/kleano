import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class UpdateCarAlert extends StatelessWidget {
  const UpdateCarAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return KDialog(
      icon: SvgPicture.asset(AssetsManager.carSave2SVG),
      title: translate(AppStrings.congratulations),
      message: translate(AppStrings.carSave),
      actions: <Widget>[
        KButton(
          label: translate(AppStrings.myVehicles),
          onPressed: () {
            sl<VehiclesBloc>().add(GetVehicles());
            pop(context);
            pop(context);
          },
        ),
      ],
    );
  }
}
