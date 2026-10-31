import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';

typedef StepData = ({String label, KStatus chip, int step});

StepData getStepData(String status) {
  if (status == AppConstants.acceptedByBiker) {
    return (
      label: translate(AppStrings.accepted),
      chip: KStatus.brand,
      step: -1,
    );
  }
  if (status == AppConstants.bikerOnTheWay) {
    return (
      label: translate(AppStrings.onTheWay),
      chip: KStatus.warning,
      step: 0,
    );
  }
  if (status == AppConstants.bikerArrived) {
    return (
      label: translate(AppStrings.arrived),
      chip: KStatus.warning,
      step: 1,
    );
  }
  if (status == AppConstants.onWashing) {
    return (
      label: translate(AppStrings.inProgress),
      chip: KStatus.warning,
      step: 2,
    );
  }
  if (status == AppConstants.completed) {
    return (label: translate(AppStrings.ended), chip: KStatus.success, step: 3);
  }
  return (label: translate(AppStrings.biker), chip: KStatus.neutral, step: -1);
}
