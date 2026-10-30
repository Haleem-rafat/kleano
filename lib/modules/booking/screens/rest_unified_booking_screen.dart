import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/data/models/booking_available_model.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/modules/booking/widgets/add_ons/card_addons.dart';
import 'package:thewasher/modules/booking/widgets/calender_time_slots_widget.dart';
import 'package:thewasher/modules/booking/widgets/location/fixed_map.dart';
import 'package:thewasher/modules/my_vehicles/bloc/car_model/cars_bloc.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
import 'package:thewasher/modules/my_vehicles/screens/edit_vehicles_screen.dart';
import 'package:thewasher/modules/my_vehicles/screens/empty_vehicles_screen.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/components/text-form-shared.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/shared/widget/vehicle_shared.dart';
import 'package:thewasher/utilties/navigator.dart';

class RestUnifiedBookingScreen extends StatefulWidget {
  const RestUnifiedBookingScreen({super.key, this.onNotesFocusChanged});
  final ValueChanged<bool>? onNotesFocusChanged;

  @override
  State<RestUnifiedBookingScreen> createState() =>
      _RestUnifiedBookingScreenState();
}

class _RestUnifiedBookingScreenState extends State<RestUnifiedBookingScreen> {
  List<CalenderAvailableModel> _cachedCalender = [];
  String? _lastRequestedDate;
  bool _isCalendarLoading = false;

  late CarsBloc carsBloc;
  final GeneralSingleton singleton = GeneralSingleton();
  late final FocusNode _notesFocusNode;

  @override
  void initState() {
    super.initState();

    carsBloc = CarsBloc();
    sl<VehiclesBloc>().add(GetVehicles());

    final today = DateTime.now();
    final todayString = today.toIso8601String().split('T')[0];
    _lastRequestedDate = todayString;

    context
        .read<BookingOrderBloc>()
        .add(GetCalenderAvalible(date: todayString));

    _notesFocusNode = FocusNode();
    _notesFocusNode.addListener(() {
      widget.onNotesFocusChanged?.call(_notesFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _notesFocusNode.dispose();
    super.dispose();
  }

  void _mergeCalendar(List<CalenderAvailableModel> newCalender) {
    final Map<DateTime, CalenderAvailableModel> calendarMap = {};

    for (final day in _cachedCalender) {
      final key = DateTime(day.date.year, day.date.month, day.date.day);
      calendarMap[key] = day;
    }

    for (final day in newCalender) {
      final key = DateTime(day.date.year, day.date.month, day.date.day);
      calendarMap[key] = day;
    }

    _cachedCalender = calendarMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (!didPop) return;
        singleton.orderId = null;
        singleton.totalPay = null;
        singleton.orderTime = null;
        singleton.nearByDescription = null;
        singleton.isCarFreshened = false;
        sl<PromoBloc>().add(ClearPromoCodeDetail());
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            SizedBox(height: 12.h),
            _buildAddOnsSection(),
            16.verticalSpace,
            _buildVehiclesSection(),
            16.verticalSpace,
            _buildCarFreshenedSection(),
            16.verticalSpace,
            _buildLocationSection(),
            16.verticalSpace,
            _buildTimeSection(),
            SizedBox(height: 200.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOnsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate(AppStrings.addOns),
            style: AppStyles.title16Bold.copyWith(color: ColorManager.black),
          ),
          SizedBox(height: 12.h),
          BlocBuilder<OffersBloc, OffersState>(
            builder: (context, state) {
              final offersBloc = sl<OffersBloc>();
              if (offersBloc.addOnsList.isEmpty) {
                return Center(
                  child: Text(
                    translate(AppStrings.noAddonsRequested),
                    style: AppStyles.subtext14Regular,
                  ),
                );
              }
              return SizedBox(
                height: 150.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: offersBloc.addOnsList.length,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: 100.w,
                      child: CardAddOns(
                        index: index,
                        onTap: () {
                          if (offersBloc.cartAddOnsList
                              .contains(offersBloc.addOnsList[index])) {
                            final i = offersBloc.cartAddOnsList
                                .indexOf(offersBloc.addOnsList[index]);
                            offersBloc.add(DeleteExtraCart(
                              index: i,
                              extra: offersBloc.addOnsList[index],
                            ));
                          } else {
                            offersBloc.add(
                              AddExtraCart(extra: offersBloc.addOnsList[index]),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: BlocConsumer<VehiclesBloc, VehiclesState>(
        bloc: sl<VehiclesBloc>(),
        listener: (context, state) {
          if (state is GetVehiclesError) {
            showSnackBar(
              buildContext: context,
              message: translate(AppStrings.errorSomethingWrong),
            );
          }
        },
        builder: (context, state) {
          if (state is GetVehiclesLoading || state is GetCarModelLoading) {
            return const LoadingWidget();
          }
          if (state is GetVehiclesEmpty) {
            return EmptyVehiclesScreen(
              onPressed: () {
                pushPage(context, EditVehiclesScreen(create: true));
              },
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                translate(AppStrings.selectYourCar),
                style:
                    AppStyles.title16Bold.copyWith(color: ColorManager.black),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 110.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sl<VehiclesBloc>().vehiclesList.length,
                  separatorBuilder: (_, _) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    final selectedColor = colorList.indexWhere(
                      (e) =>
                          e.colorName ==
                          sl<VehiclesBloc>().vehiclesList[index].color!,
                    );
                    return InkWell(
                      onTap: () {
                        sl<VehiclesBloc>().add(
                          SelectCar(
                            vehicle: sl<VehiclesBloc>().vehiclesList[index],
                          ),
                        );
                      },
                      child: VehiclesCard(
                        cardWidth: 200,
                        index: index,
                        selectedColor: selectedColor,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: ButtonDottedShared(
                  onPressed: () {
                    pushPage(context, EditVehiclesScreen(create: true));
                  },
                  text: translate(AppStrings.addNewVehicles),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate(AppStrings.carLocation),
            style: AppStyles.title16Bold.copyWith(color: ColorManager.black),
          ),
          SizedBox(height: 10.h),
          BlocBuilder<LocationBloc, LocationState>(
            builder: (_, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: SizedBox(
                      height: 130.h,
                      width: double.infinity,
                      child: FixedMap(
                        latLng: LatLng(
                          blcoPosition.latitude,
                          blcoPosition.longitude,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    translate(AppStrings.location),
                    style: AppStyles.title16Bold
                        .copyWith(color: ColorManager.black),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    fullLocationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.title16Regular
                        .copyWith(color: ColorManager.black),
                  ),
                  SizedBox(height: 8.h),
                  TextFormShared(
                    initialValue: singleton.nearByDescription,
                    focusNode: _notesFocusNode,
                    onChanged: (v) => singleton.nearByDescription = v,
                    hintText: translate(AppStrings.notes),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCarFreshenedSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            translate(AppStrings.carFreshened),
            style: AppStyles.title16Bold.copyWith(color: ColorManager.black),
          ),
          SizedBox(height: 12.h),
          SwitchListTile(
            value: singleton.isCarFreshened,
            activeThumbColor: ColorManager.primary,
            title: Text(
              translate(AppStrings.addCarFreshenedService),
              style: AppStyles.subtext14Regular,
            ),
            onChanged: (v) {
              setState(() => singleton.isCarFreshened = v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: BlocListener<BookingOrderBloc, BookingOrderState>(
        listener: (context, state) {
          if (state is CalenderAvailableLoading) {
            setState(() => _isCalendarLoading = true);
          }
          if (state is CalenderAvailableFailed) {
            setState(() => _isCalendarLoading = false);
            showSnackBar(
              buildContext: context,
              message: state.errorModel?.en ?? '',
            );
          }
          if (state is CalenderAvailableSuccess) {
            setState(() {
              _mergeCalendar(state.calenderAvailableModel);
              _isCalendarLoading = false;
              _lastRequestedDate = null;
            });
          }
        },
        child: Stack(
          children: [
            CalenderTimeSlotsWidget(
              key: const ValueKey('calendar_time_slots'),
              calender: _cachedCalender,
            ),
          ],
        ),
      ),
    );
  }
}
