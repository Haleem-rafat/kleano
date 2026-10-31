import 'package:flutter/material.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/modules/booking/data/models/booking_available_model.dart';
import 'package:thewasher/utilties/app_date_formatter.dart';

class TimeSlotItem extends StatelessWidget {
  final TimeSlot? timeSlot;
  final VoidCallback onTimeSelected;
  final bool isSelected;
  final bool isDisabled;

  const TimeSlotItem({
    super.key,
    this.timeSlot,
    required this.onTimeSelected,
    this.isSelected = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: !isDisabled,
      child: Material(
        color: isSelected ? c.brand : c.surface,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isDisabled ? null : onTimeSelected,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 88),
            child: Center(
              widthFactor: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: KSpace.l),
                child: Text(
                  AppDateFormatter.dateToStringHHMMA(
                    timeSlot!.availableTime,
                    "en",
                  ),
                  style: KType.subhead.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : isDisabled
                        ? c.textSecondary
                        : c.text,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
