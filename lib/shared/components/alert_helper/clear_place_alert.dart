import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/utilties/navigator.dart';

class ClearPlaceAlert extends StatelessWidget {
  final void Function() delete;
  final String name;

  const ClearPlaceAlert({super.key, required this.delete, required this.name});

  @override
  Widget build(BuildContext context) {
    return KDialog(
      title: name,
      actions: <Widget>[
        BlocConsumer<LocationBloc, LocationState>(
          listener: (BuildContext context, LocationState state) {
            if (state is UnSaveLocationSuccess ||
                state is ClearSaveLocationSuccess) {
              pop(context);
            }
          },
          builder: (BuildContext context, LocationState state) {
            return KButton(
              label: translate(AppStrings.delete),
              variant: KButtonVariant.destructive,
              loading:
                  state is ClearSaveLocationLoading ||
                  state is UnSaveLocationLoading,
              onPressed: delete,
            );
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
