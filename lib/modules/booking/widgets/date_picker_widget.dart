import 'package:flutter/material.dart';
import 'package:thewasher/modules/booking/widgets/action_bottom_sheet.dart';

class DatePickerWidget extends StatelessWidget {
  final Function(DateTime) onDateSelected;

  const DatePickerWidget({super.key, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    DateTime selectedDate = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CalendarDatePicker(
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2101),
          onDateChanged: (date) {
            onDateSelected(date);
          },
        ),
        ActionsBottom(
          onDateSelected: () {
            onDateSelected(selectedDate);
          },
        )
      ],
    );
  }
}
