// 🔧 FIX: clear time slots immediately when changing to a day with no data
// 🔧 FIX: never keep previous slots for an empty day

import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/booking/data/models/booking_available_model.dart';
import 'package:thewasher/modules/booking/widgets/time_slot_item.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalenderTimeSlotsWidget extends StatefulWidget {
  final List<CalenderAvailableModel> calender;
  const CalenderTimeSlotsWidget({super.key, required this.calender});

  @override
  State<CalenderTimeSlotsWidget> createState() =>
      _CalenderTimeSlotsWidgetState();
}

class _CalenderTimeSlotsWidgetState extends State<CalenderTimeSlotsWidget> {
  late DateTime _focusedDay;
  List<TimeSlot> _currentTimeSlots = [];
  String? _lastRequestedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _updateTimeSlotsForDate(_focusedDay);
  }

  @override
  void didUpdateWidget(covariant CalenderTimeSlotsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.calender != widget.calender) {
      _updateTimeSlotsForDate(_focusedDay);
    }
  }

  void _updateTimeSlotsForDate(DateTime date) {
    final dayData = widget.calender.firstWhere(
      (d) => isSameDay(d.date, date),
      orElse: () =>
          CalenderAvailableModel(date: date, timeSlots: [], isActive: false),
    );

    setState(() {
      _currentTimeSlots = List<TimeSlot>.from(dayData.timeSlots);
    });
  }

  void _handleDateChange(DateTime selectedDate) {
    final normalizedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    if (isSameDay(_focusedDay, normalizedDate)) return;

    final dateString = normalizedDate.toIso8601String().split('T')[0];

    setState(() {
      _focusedDay = normalizedDate;
      _currentTimeSlots = []; // ✅ CLEAR IMMEDIATELY
    });

    context.read<BookingOrderBloc>().add(ClearSelectedTimeSlot());

    final hasCachedData = widget.calender.any(
      (d) => isSameDay(d.date, normalizedDate),
    );

    if (!hasCachedData && _lastRequestedDate != dateString) {
      _lastRequestedDate = dateString;
      context.read<BookingOrderBloc>().add(
        GetCalenderAvalible(date: dateString),
      );
    }

    if (hasCachedData) {
      _updateTimeSlotsForDate(normalizedDate);
    }
  }

  void _handleTimeSlotSelected(TimeSlot slot) {
    if (!slot.isActive || slot.availableBikersCount <= 0) return;

    setState(() {
      _focusedDay = DateTime(
        _focusedDay.year,
        _focusedDay.month,
        _focusedDay.day,
        slot.availableTime.hour,
        slot.availableTime.minute,
      );
      GeneralSingleton().orderTime = _focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EasyInfiniteDateTimeLine(
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 13)),
          focusDate: _focusedDay,
          locale: Localizations.localeOf(context).languageCode,
          activeColor: c.brand,
          onDateChange: _handleDateChange,
        ),
        const SizedBox(height: KSpace.l),
        Text(
          translate(AppStrings.availableAppointmentsBooking),
          style: KType.headline.copyWith(color: c.text),
        ),
        const SizedBox(height: KSpace.s),
        _buildTimeSlotsList(),
      ],
    );
  }

  Widget _buildTimeSlotsList() {
    return BlocBuilder<BookingOrderBloc, BookingOrderState>(
      builder: (_, state) {
        if (state is CalenderAvailableLoading) {
          return const KLoadingState();
        }
        return SizedBox(
          height: KSpace.tapTarget,
          child: _buildTimeSlotListView(),
        );
      },
    );
  }

  Widget _buildTimeSlotListView() {
    final now = DateTime.now().add(const Duration(minutes: 30));

    final slots = _currentTimeSlots.where((slot) {
      final slotTime = DateTime(
        _focusedDay.year,
        _focusedDay.month,
        _focusedDay.day,
        slot.availableTime.hour,
        slot.availableTime.minute,
      );
      return slot.availableBikersCount > 0 && !slotTime.isBefore(now);
    }).toList();

    if (slots.isEmpty) {
      return _buildEmptyTimeSlotsState();
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: slots.length,
      separatorBuilder: (_, _) => const SizedBox(width: KSpace.s),
      itemBuilder: (_, i) {
        final slot = slots[i];
        return TimeSlotItem(
          timeSlot: slot,
          isSelected: _isTimeSlotSelected(slot),
          isDisabled: !slot.isActive,
          onTimeSelected: () => _handleTimeSlotSelected(slot),
        );
      },
    );
  }

  Widget _buildEmptyTimeSlotsState() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        translate(AppStrings.noAvailableTimeSlots),
        style: KType.subhead.copyWith(color: KColors.of(context).textSecondary),
      ),
    );
  }

  bool _isTimeSlotSelected(TimeSlot slot) {
    final orderTime = GeneralSingleton().orderTime;
    if (orderTime == null) return false;

    return isSameDay(orderTime, _focusedDay) &&
        orderTime.hour == slot.availableTime.hour &&
        orderTime.minute == slot.availableTime.minute;
  }
}
