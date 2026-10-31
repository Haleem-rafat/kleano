import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/widgets/calender_time_slots_widget.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/modules/booking/data/models/booking_available_model.dart';

class SelectTimeBooking extends StatefulWidget {
  const SelectTimeBooking({super.key});

  @override
  State<SelectTimeBooking> createState() => _SelectTimeBookingState();
}

class _SelectTimeBookingState extends State<SelectTimeBooking> {
  List<CalenderAvailableModel>? _cachedCalender;
  @override
  void initState() {
    super.initState();
    context.read<BookingOrderBloc>().add(GetCalenderAvalible());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            translate(AppStrings.pickATime),
            style: AppStyles.title16Bold.copyWith(color: ColorManager.black),
          ),
          SizedBox(height: AppPadding.p16.h),
          BlocConsumer<BookingOrderBloc, BookingOrderState>(
            listener: (context, state) {
              if (state is CalenderAvailableFailed) {
                showSnackBar(
                  buildContext: context,
                  message: state.errorModel!.en!,
                );
              }
              if (state is CalenderAvailableSuccess) {
                // Merge new calendar data with existing cached data
                final newCalender = state.calenderAvailableModel;
                if (_cachedCalender == null || _cachedCalender!.isEmpty) {
                  _cachedCalender = newCalender;
                } else {
                  // Merge: replace existing dates with new data, keep others
                  final Map<DateTime, CalenderAvailableModel> calendarMap = {};

                  // Add existing cached data
                  for (var day in _cachedCalender!) {
                    final dateKey = DateTime(
                      day.date.year,
                      day.date.month,
                      day.date.day,
                    );
                    calendarMap[dateKey] = day;
                  }

                  // Update/Add new data
                  for (var day in newCalender) {
                    final dateKey = DateTime(
                      day.date.year,
                      day.date.month,
                      day.date.day,
                    );
                    calendarMap[dateKey] = day;
                  }

                  _cachedCalender = calendarMap.values.toList()
                    ..sort((a, b) => a.date.compareTo(b.date));
                }
              }
            },
            builder: (context, state) {
              if (state is CalenderAvailableLoading) {
                // Show cached calendar while refreshing
                if (_cachedCalender != null && _cachedCalender!.isNotEmpty) {
                  return CalenderTimeSlotsWidget(
                    key: const ValueKey('calendar_time_slots'),
                    calender: _cachedCalender!,
                  );
                }
                return const LoadingWidget();
              }
              if (state is CalenderAvailableSuccess) {
                // Use merged cached calendar which includes all fetched dates
                final calender =
                    _cachedCalender ?? state.calenderAvailableModel;
                return CalenderTimeSlotsWidget(
                  key: const ValueKey('calendar_time_slots'),
                  calender: calender,
                );
              }
              // For any other state, fall back to cached calendar if available
              if (_cachedCalender != null && _cachedCalender!.isNotEmpty) {
                return CalenderTimeSlotsWidget(
                  key: const ValueKey('calendar_time_slots'),
                  calender: _cachedCalender!,
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
