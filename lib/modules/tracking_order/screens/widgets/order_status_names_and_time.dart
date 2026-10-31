import 'package:flutter/material.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/modules/tracking_order/screens/widgets/events_stepper.dart';

class OrderStutesNamesAndTime extends StatelessWidget {
  const OrderStutesNamesAndTime({
    super.key,
    required this.bikerStatesName,
    required this.estimatedTimeBikerStates,
  });

  final List<String> bikerStatesName;
  final List<String> estimatedTimeBikerStates;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int index = 0; index < EventsStepper.stepCount; index++)
          SizedBox(
            height: EventsStepper.rowHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  bikerStatesName[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KType.subhead.copyWith(color: c.text),
                ),
                Expanded(
                  child: Text(
                    estimatedTimeBikerStates[index],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: KType.footnote.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
