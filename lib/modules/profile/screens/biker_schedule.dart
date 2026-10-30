import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/fonts_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/biker_schedule_model.dart';
import 'package:thewhsherbiker/shared/components/shimmering/basic_container_shimmering.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart' as nav;

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

  String _getDayName(String day) {
    // Map day names to display format
    final dayMap = <String, String>{
      'SATURDAY': 'Saturday',
      'SUNDAY': 'Sunday',
      'MONDAY': 'Monday',
      'TUESDAY': 'Tuesday',
      'WEDNESDAY': 'Wednesday',
      'THURSDAY': 'Thursday',
      'FRIDAY': 'Friday',
    };

    // Return formatted day name
    return dayMap[day.toUpperCase()] ?? day;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          systemOverlayStyle: AppStyles.darkStatusBarIconsWithWhiteColorStyle,
          automaticallyImplyLeading: false,
          backgroundColor: ColorManager.white,
          forceMaterialTransparency: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12.r),
                bottomRight: Radius.circular(12.r),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: ColorManager.black.withOpacity(.08),
                  blurRadius: 6.r,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () => nav.pop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 20.r,
                          color: ColorManager.darkGrey,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      translate(AppStrings.mySchedule),
                      style: AppStyles.title16Bold.copyWith(
                        color: ColorManager.darkGrey,
                        fontSize: FontSize.s18.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        bloc: sl<ProfileBloc>(),
        builder: (BuildContext context, ProfileState state) {
          if (state is BikerGetScheduleLoading) {
            return _buildShimmerLoading();
          } else if (state is BikerGetScheduleFailed) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    state.error,
                    style: AppStyles.title16Regular.copyWith(
                      color: ColorManager.red,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      sl<ProfileBloc>().add(BikerGetSchedule());
                    },
                    child: Text(translate(AppStrings.retryAgain)),
                  ),
                ],
              ),
            );
          } else if (state is BikerGetScheduleSuccess) {
            final schedule = state.schedule;
            final groupedShifts = _groupShiftsByDay(schedule.shifts);
            final orderedDays = _getOrderedDays(groupedShifts);

            if (schedule.shifts.isEmpty) {
              return Center(
                child: Text(
                  translate('noSchedule'),
                  style: AppStyles.title16Regular.copyWith(
                    color: ColorManager.medGray,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 16.h),
              itemCount: orderedDays.length,
              itemBuilder: (BuildContext context, int index) {
                final day = orderedDays[index];
                final shifts = groupedShifts[day]!;
                final isWeekend = schedule.weekends.contains(day);
                return _buildDaySection(day, shifts, isWeekend);
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDaySection(String day, List<Shift> shifts, bool isWeekend) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppSize.s12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorManager.black.withOpacity(.06),
            blurRadius: 6.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isWeekend
                  ? ColorManager.primary.withOpacity(0.15)
                  : ColorManager.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSize.s12),
                topRight: Radius.circular(AppSize.s12),
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  _getDayName(day),
                  style: AppStyles.title16Bold.copyWith(
                    color: ColorManager.primary,
                    fontSize: FontSize.s16.sp,
                  ),
                ),
                if (isWeekend) ...[
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: ColorManager.primary,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Weekend',
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.white,
                        fontSize: FontSize.s10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: ColorManager.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${shifts.length}',
                    style: AppStyles.title16Regular.copyWith(
                      color: ColorManager.white,
                      fontSize: FontSize.s12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: shifts.length,
            separatorBuilder: (BuildContext context, int index) => Divider(
              height: 1,
              thickness: 1,
              color: ColorManager.divider,
              indent: 16.w,
              endIndent: 16.w,
            ),
            itemBuilder: (BuildContext context, int index) {
              final shift = shifts[index];
              return _buildShiftItem(shift);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShiftItem(Shift shift) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: ColorManager.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              _convertTo12HourFormat(shift.timeSlot),
              style: AppStyles.title16Bold.copyWith(
                color: ColorManager.primary,
                fontSize: FontSize.s14.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _getLocalizedName(shift.city.name),
                  style: AppStyles.title16Regular.copyWith(
                    color: ColorManager.darkGrey,
                    fontSize: FontSize.s14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _getLocalizedName(shift.area.name),
                  style: AppStyles.title16Regular.copyWith(
                    color: ColorManager.medGray,
                    fontSize: FontSize.s12.sp,
                  ),
                ),
              ],
            ),
          ),
          if (shift.priorityLevel > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: ColorManager.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                'P${shift.priorityLevel}',
                style: AppStyles.title16Regular.copyWith(
                  color: ColorManager.primary,
                  fontSize: FontSize.s10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 16.h),
      itemCount: 5, // Show 5 day sections in shimmer
      itemBuilder: (BuildContext context, int index) {
        return _buildShimmerDaySection();
      },
    );
  }

  Widget _buildShimmerDaySection() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(AppSize.s12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorManager.black.withOpacity(.06),
            blurRadius: 6.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Day header shimmer
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: ColorManager.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSize.s12),
                topRight: Radius.circular(AppSize.s12),
              ),
            ),
            child: Row(
              children: <Widget>[
                BasicContainerShemmering(
                  height: 20.h,
                  width: 100.w,
                  radius: 8,
                ),
                SizedBox(width: 8.w),
                BasicContainerShemmering(
                  height: 20.h,
                  width: 60.w,
                  radius: 8,
                ),
                SizedBox(width: 8.w),
                BasicContainerShemmering(
                  height: 20.h,
                  width: 30.w,
                  radius: 12,
                ),
              ],
            ),
          ),
          // Shifts shimmer
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Column(
              children: List.generate(3, (index) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    children: <Widget>[
                      BasicContainerShemmering(
                        height: 32.h,
                        width: 80.w,
                        radius: 8,
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            BasicContainerShemmering(
                              height: 16.h,
                              width: double.infinity,
                              radius: 4,
                            ),
                            SizedBox(height: 8.h),
                            BasicContainerShemmering(
                              height: 14.h,
                              width: 120.w,
                              radius: 4,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      BasicContainerShemmering(
                        height: 24.h,
                        width: 30.w,
                        radius: 6,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
