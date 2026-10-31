import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/design/adaptive_screen.dart';
import 'package:thewhsherbiker/core/design/components/k_card.dart';
import 'package:thewhsherbiker/core/design/components/k_list_row.dart';
import 'package:thewhsherbiker/core/design/components/k_states.dart';
import 'package:thewhsherbiker/core/design/components/k_status_chip.dart';
import 'package:thewhsherbiker/core/design/liquid_glass.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/biker_schedule_model.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

class BikerSchedule extends StatefulWidget {
  const BikerSchedule({super.key});

  @override
  State<BikerSchedule> createState() => _BikerScheduleState();
}

class _BikerScheduleState extends State<BikerSchedule> {
  @override
  void initState() {
    super.initState();
    sl<ProfileBloc>().add(BikerGetSchedule());
  }

  /// The backend's day ('SATURDAY') in the app's language.
  String _getDayName(String day) {
    final String? key = switch (day.toUpperCase()) {
      'SATURDAY' => AppStrings.saturday,
      'SUNDAY' => AppStrings.sunday,
      'MONDAY' => AppStrings.monday,
      'TUESDAY' => AppStrings.tuesday,
      'WEDNESDAY' => AppStrings.wednesday,
      'THURSDAY' => AppStrings.thursday,
      'FRIDAY' => AppStrings.friday,
      _ => null,
    };
    return key == null ? day : tr(context, key);
  }

  String _getLocalizedName(Name? name) {
    if (name == null) return '';
    final locale = LocalizedApp.of(context).delegate.currentLocale;
    if (locale.languageCode == 'ar') {
      return name.ar ?? name.en ?? '';
    }
    return name.en ?? name.ar ?? '';
  }

  String _convertTo12HourFormat(String time24Hour) {
    try {
      final parts = time24Hour.split(':');
      if (parts.length != 2) return time24Hour;

      final hour = int.parse(parts[0]);
      final minute = parts[1];

      if (hour == 0) {
        return '12:$minute AM';
      } else if (hour < 12) {
        return '$hour:$minute AM';
      } else if (hour == 12) {
        return '12:$minute PM';
      } else {
        return '${hour - 12}:$minute PM';
      }
    } catch (e) {
      return time24Hour;
    }
  }

  Map<String, List<Shift>> _groupShiftsByDay(List<Shift> shifts) {
    final Map<String, List<Shift>> grouped = {};
    for (final shift in shifts) {
      final day = shift.day;
      if (!grouped.containsKey(day)) {
        grouped[day] = [];
      }
      grouped[day]!.add(shift);
    }
    // Sort shifts by time slot within each day
    for (final day in grouped.keys) {
      grouped[day]!.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));
    }
    return grouped;
  }

  List<String> _getOrderedDays(Map<String, List<Shift>> groupedShifts) {
    const dayOrder = [
      'SATURDAY',
      'SUNDAY',
      'MONDAY',
      'TUESDAY',
      'WEDNESDAY',
      'THURSDAY',
      'FRIDAY'
    ];
    return dayOrder.where((day) => groupedShifts.containsKey(day)).toList();
  }

  static bool _isScheduleState(ProfileState state) =>
      state is BikerGetScheduleLoading ||
      state is BikerGetScheduleSuccess ||
      state is BikerGetScheduleFailed;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: GlassAppBar(
        title: Text(
          tr(context, AppStrings.mySchedule),
          style: KType.headline.copyWith(color: c.text),
        ),
      ),
      body: AdaptiveContent(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          bloc: sl<ProfileBloc>(),
          buildWhen: (ProfileState previous, ProfileState current) =>
              _isScheduleState(current),
          builder: (BuildContext context, ProfileState state) {
            if (state is BikerGetScheduleFailed) {
              return KErrorState(
                message: state.error,
                onRetry: () => sl<ProfileBloc>().add(BikerGetSchedule()),
              );
            }
            if (state is! BikerGetScheduleSuccess) {
              return const KSkeleton.list();
            }
            final BikerScheduleModel schedule = state.schedule;
            if (schedule.shifts.isEmpty) {
              return KEmptyState(
                icon: Icons.calendar_today_outlined,
                title: translate(AppStrings.noSchedule),
              );
            }
            final Map<String, List<Shift>> groupedShifts = _groupShiftsByDay(
              schedule.shifts,
            );
            final List<String> orderedDays = _getOrderedDays(groupedShifts);
            return ListView.separated(
              padding: const EdgeInsets.all(KSpace.l),
              itemCount: orderedDays.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: KSpace.l),
              itemBuilder: (BuildContext context, int index) {
                final String day = orderedDays[index];
                return _buildDaySection(
                  day,
                  groupedShifts[day]!,
                  schedule.weekends.contains(day),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDaySection(String day, List<Shift> shifts, bool isWeekend) {
    final KColors c = KColors.of(context);
    return KCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(KSpace.l),
            child: Wrap(
              spacing: KSpace.s,
              runSpacing: KSpace.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text(
                  _getDayName(day),
                  style: KType.headline.copyWith(color: c.text),
                ),
                if (isWeekend)
                  KStatusChip(
                    label: tr(context, AppStrings.weekend),
                    status: KStatus.brand,
                  ),
                KStatusChip(label: '${shifts.length}', status: KStatus.neutral),
              ],
            ),
          ),
          for (final Shift shift in shifts) ...<Widget>[
            Divider(height: 1, color: c.separator),
            KListRow(
              leading: KStatusChip(
                label: _convertTo12HourFormat(shift.timeSlot),
                status: KStatus.brand,
              ),
              title: _getLocalizedName(shift.city.name),
              subtitle: _getLocalizedName(shift.area.name),
              trailing: shift.priorityLevel > 0
                  ? KStatusChip(
                      label: 'P${shift.priorityLevel}',
                      status: KStatus.neutral,
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
