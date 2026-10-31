import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_dialog.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/utilties/navigator.dart';

class SavedAlert extends StatelessWidget {
  final TextEditingController nameController;
  final bool recent;
  final int? index;

  const SavedAlert({
    super.key,
    required this.nameController,
    required this.recent,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    return KDialog(
      title: 'Name you Location',
      icon: BlocConsumer<LocationBloc, LocationState>(
        listener: (BuildContext context, LocationState state) {
          if (state is SaveLocationSuccess ||
              state is SaveRecentLocationSuccess) {
            pop(context);
            AlertHelper.successSavedLocation(
              context,
              message: translate(AppStrings.yourLocationSavedSuccessfully),
            );
          } else if (state is SaveLocationFailed ||
              state is SaveRecentLocationFailed) {
            debugPrint('sssss $state');
          }
        },
        builder: (BuildContext context, LocationState state) {
          if (state is SaveLocationLoading ||
              state is SaveRecentLocationLoading) {
            return const KLoadingState();
          }
          return KTextField(label: '', controller: nameController);
        },
      ),
    );
  }
}
