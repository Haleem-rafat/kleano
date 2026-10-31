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

class DeleteCarAlert extends StatelessWidget {
  final String sId;
  final int index;
  const DeleteCarAlert({super.key, required this.sId, required this.index});

  @override
  Widget build(BuildContext context) {
    return KDialog(
      icon: SvgPicture.asset(AssetsManager.deleteCarSVG),
      title: translate(AppStrings.deleteCar),
      actions: <Widget>[
        KButton(
          label: translate(AppStrings.deleteCarButton),
          variant: KButtonVariant.destructive,
          onPressed: () {
            sl<VehiclesBloc>().add(DeleteCar(id: sId, index: index));
            pop(context);
          },
        ),
        KButton(
          label: translate(AppStrings.cancel),
          variant: KButtonVariant.text,
          onPressed: () => pop(context),
        ),
      ],
    );
  }
}
