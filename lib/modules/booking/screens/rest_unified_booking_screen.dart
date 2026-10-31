import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_card.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/shared/components/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
import 'package:thewasher/modules/booking/data/models/booking_available_model.dart';
import 'package:thewasher/modules/profile/blocs/promo_code/promo_bloc.dart';
import 'package:thewasher/modules/booking/widgets/calender_time_slots_widget.dart';
import 'package:thewasher/modules/booking/screens/set_booking_location_screen.dart';
import 'package:thewasher/modules/booking/widgets/location/fixed_map.dart';
import 'package:thewasher/modules/my_vehicles/bloc/car_model/cars_bloc.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
import 'package:thewasher/modules/my_vehicles/screens/edit_vehicles_screen.dart';
import 'package:thewasher/modules/my_vehicles/screens/empty_vehicles_screen.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
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

  late CarsBloc carsBloc;
  final GeneralSingleton singleton = GeneralSingleton();
  late final FocusNode _notesFocusNode;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();

    carsBloc = CarsBloc();
    sl<VehiclesBloc>().add(GetVehicles());

    final today = DateTime.now();
    final todayString = today.toIso8601String().split('T')[0];

    context.read<BookingOrderBloc>().add(
      GetCalenderAvalible(date: todayString),
    );

    _notesController = TextEditingController(text: singleton.nearByDescription)
      ..addListener(() => singleton.nearByDescription = _notesController.text);
    _notesFocusNode = FocusNode();
    _notesFocusNode.addListener(() {
      widget.onNotesFocusChanged?.call(_notesFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _notesFocusNode.dispose();
    _notesController.dispose();
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: KSpace.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildVehiclesSection(),
              const SizedBox(height: KSpace.xxl),
              _buildTimeSection(),
              const SizedBox(height: KSpace.xxl),
              _buildLocationSection(),
              const SizedBox(height: KSpace.xxl),
              _buildExtrasSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KSpace.m),
      child: Text(
        text,
        style: KType.title.copyWith(color: KColors.of(context).text),
      ),
    );
  }

  Widget _buildVehiclesSection() {
    return BlocConsumer<VehiclesBloc, VehiclesState>(
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
          return const KSkeleton.details();
        }
        if (state is GetVehiclesEmpty) {
          return EmptyVehiclesScreen(
            onPressed: () {
              pushPage(context, EditVehiclesScreen(create: true));
            },
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _title(translate(AppStrings.selectYourCar)),
            SizedBox(
              height: 212,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sl<VehiclesBloc>().vehiclesList.length,
                separatorBuilder: (_, _) => const SizedBox(width: KSpace.m),
                itemBuilder: (context, index) {
                  final selectedColor = colorList.indexWhere(
                    (e) =>
                        e.colorName ==
                        sl<VehiclesBloc>().vehiclesList[index].color!,
                  );
                  return InkWell(
                    borderRadius: BorderRadius.circular(KRadius.card),
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
            const SizedBox(height: KSpace.s),
            KButton(
              label: translate(AppStrings.addNewVehicles),
              variant: KButtonVariant.text,
              onPressed: () {
                pushPage(context, EditVehiclesScreen(create: true));
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationSection() {
    final KColors c = KColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(translate(AppStrings.carLocation)),
        BlocBuilder<LocationBloc, LocationState>(
          builder: (_, _) {
            return KCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FixedMap(
                    height: 130,
                    latLng: LatLng(
                      blcoPosition.latitude,
                      blcoPosition.longitude,
                    ),
                  ),
                  KListRow(
                    leading: SvgPicture.asset(
                      AssetsManager.locationIconLogo,
                      colorFilter: ColorFilter.mode(c.brand, BlendMode.srcIn),
                    ),
                    title: translate(AppStrings.location),
                    subtitle: fullLocationName,
                    trailing: Text(
                      translate(AppStrings.changeLocation),
                      style: KType.subhead.copyWith(
                        color: c.brand,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Prices depend on the place: choosing one goes back to
                    // Home, which loads that place's services.
                    onTap: () =>
                        pushPage(context, const SetBookingLocationScreen()),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: KSpace.m),
        KTextField(
          label: translate(AppStrings.notes),
          hint: translate(AppStrings.notes),
          controller: _notesController,
          focusNode: _notesFocusNode,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }

  Widget _buildExtrasSection() {
    final KColors c = KColors.of(context);
    final OffersBloc offersBloc = sl<OffersBloc>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _title(translate(AppStrings.addOns)),
        BlocBuilder<OffersBloc, OffersState>(
          builder: (context, state) {
            return KCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (
                    int index = 0;
                    index < offersBloc.addOnsList.length;
                    index++
                  ) ...[
                    _buildAddOnRow(c, offersBloc, index),
                    Divider(
                      height: 1,
                      indent: KSpace.l + 44 + KSpace.m,
                      color: c.separator,
                    ),
                  ],
                  SwitchListTile.adaptive(
                    value: singleton.isCarFreshened,
                    activeTrackColor: c.brand,
                    title: Text(
                      translate(AppStrings.addCarFreshenedService),
                      style: KType.body.copyWith(color: c.text),
                    ),
                    subtitle: Text(
                      translate(AppStrings.carFreshened),
                      style: KType.subhead.copyWith(color: c.textSecondary),
                    ),
                    onChanged: (v) {
                      setState(() => singleton.isCarFreshened = v);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddOnRow(KColors c, OffersBloc offersBloc, int index) {
    final addOn = offersBloc.addOnsList[index];
    final bool selected = offersBloc.cartAddOnsList.contains(addOn);
    void toggle() {
      if (selected) {
        offersBloc.add(
          DeleteExtraCart(
            index: offersBloc.cartAddOnsList.indexOf(addOn),
            extra: addOn,
          ),
        );
      } else {
        offersBloc.add(AddExtraCart(extra: addOn));
      }
    }

    return KListRow(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(KRadius.field),
        child: ColoredBox(
          color: c.fill,
          child: ImageShared(
            image: addOn.icon?.iconLink ?? '',
            height: 44,
            width: 44,
          ),
        ),
      ),
      title: addOn.name ?? '',
      subtitle: '+ ${addOn.price ?? ''} ${translate(AppStrings.sAR)}',
      trailing: Checkbox.adaptive(
        value: selected,
        activeColor: c.brand,
        onChanged: (_) => toggle(),
      ),
      onTap: toggle,
    );
  }

  Widget _buildTimeSection() {
    return BlocListener<BookingOrderBloc, BookingOrderState>(
      listener: (context, state) {
        if (state is CalenderAvailableFailed) {
          showSnackBar(
            buildContext: context,
            message: state.errorModel?.en ?? '',
          );
        }
        if (state is CalenderAvailableSuccess) {
          setState(() {
            _mergeCalendar(state.calenderAvailableModel);
          });
        }
      },
      child: CalenderTimeSlotsWidget(
        key: const ValueKey('calendar_time_slots'),
        calender: _cachedCalender,
      ),
    );
  }
}
