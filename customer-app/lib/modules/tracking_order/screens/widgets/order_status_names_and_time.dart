import 'package:flutter/material.dart';
import 'package:thewasher/core/design/tokens.dart';

/// The timeline under the stage bar: each stage, its time, and a mark for
/// done, happening next or still to come.
class OrderStutesNamesAndTime extends StatelessWidget {
  const OrderStutesNamesAndTime({
    super.key,
    required this.step,
    required this.bikerStatesName,
    required this.estimatedTimeBikerStates,
  });

  /// Index of the latest reached stage; -1 means none yet.
  final int step;
  final List<String> bikerStatesName;
  final List<String> estimatedTimeBikerStates;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int index = 0; index < bikerStatesName.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: KSpace.m),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  index <= step
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: KSpace.xl,
                  color: index <= step
                      ? c.success
                      : index == step + 1
                      ? c.brand
                      : c.separator,
                ),
                const SizedBox(width: KSpace.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        bikerStatesName[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KType.subhead.copyWith(
                          color: index <= step + 1 ? c.text : c.textSecondary,
                          fontWeight: index == step ? FontWeight.w600 : null,
                        ),
                      ),
                      if (estimatedTimeBikerStates[index].isNotEmpty)
                        Text(
                          estimatedTimeBikerStates[index],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: KType.footnote.copyWith(
                            color: c.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
