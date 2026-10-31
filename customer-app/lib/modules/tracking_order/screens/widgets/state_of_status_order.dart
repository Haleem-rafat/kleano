import 'package:flutter/material.dart';
import 'package:thewasher/core/design/components/k_status_chip.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/functions/check_step_data.dart';

class StateOfStatusOrder extends StatelessWidget {
  final String status;
  const StateOfStatusOrder({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final StepData stepData = getStepData(status);
    return KStatusChip(label: stepData.label, status: stepData.chip);
  }
}
