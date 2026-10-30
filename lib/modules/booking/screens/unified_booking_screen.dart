// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_translate/flutter_translate.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:thewasher/core/resources/app_styles.dart';
// import 'package:thewasher/core/resources/color_manager.dart';
// import 'package:thewasher/core/resources/strings_manager.dart';
// import 'package:thewasher/core/resources/values_manager.dart';
// import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
// import 'package:thewasher/modules/Home/bloc/offers/offers_bloc.dart';
// import 'package:thewasher/modules/booking/bolcs/booking_order/booking_order_bloc.dart';
// import 'package:thewasher/modules/booking/data/models/booking_available_model.dart';
// import 'package:thewasher/modules/booking/widgets/add_ons/card_addons.dart';
// import 'package:thewasher/modules/booking/widgets/add_services/services_list.dart';
// import 'package:thewasher/modules/booking/widgets/add_services/subscription_and_services_list.dart';
// import 'package:thewasher/modules/booking/widgets/calender_time_slots_widget.dart';
// import 'package:thewasher/modules/booking/widgets/location/fixed_map.dart';
// import 'package:thewasher/modules/my_vehicles/bloc/car_model/cars_bloc.dart';
// import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
// import 'package:thewasher/modules/my_vehicles/data/model/color_model.dart';
// import 'package:thewasher/modules/my_vehicles/screens/edit_vehicles_screen.dart';
// import 'package:thewasher/modules/my_vehicles/screens/empty_vehicles_screen.dart';
// import 'package:thewasher/modules/plans_and_subscription/bloc/plans_and_subscription/plans_and_subscription_bloc.dart';
// import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
// import 'package:thewasher/shared/components/buttons.dart';
// import 'package:thewasher/shared/components/loading.dart';
// import 'package:thewasher/shared/components/snack_bar.dart';
// import 'package:thewasher/shared/components/text-form-shared.dart';
// import 'package:thewasher/shared/services/service_locator.dart';
// import 'package:thewasher/shared/singleton.dart';
// import 'package:thewasher/shared/widget/vehicle_shared.dart';
// import 'package:thewasher/utilties/navigator.dart';

// class UnifiedBookingScreen extends StatefulWidget {
//   const UnifiedBookingScreen({super.key});

//   @override
//   State<UnifiedBookingScreen> createState() => _UnifiedBookingScreenState();
// }

// class _UnifiedBookingScreenState extends State<UnifiedBookingScreen> {
//   late ScrollController _scrollController;
//   List<CalenderAvailableModel>? _cachedCalender;
//   late CarsBloc carsBloc;
//   GeneralSingleton singleton = GeneralSingleton();

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     carsBloc = CarsBloc();

//     // Initialize data
//     sl<VehiclesBloc>().add(GetVehicles());
//     context.read<BookingOrderBloc>().add(GetCalenderAvalible());
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         controller: _scrollController,
//         child: Column(
//           children: [
//             // Services Section
//             _buildServicesSection(),

//             // Add-ons Section
//             _buildAddOnsSection(),

//             // Car Freshened Section
//             _buildCarFreshenedSection(),

//             // Vehicles Section
//             _buildVehiclesSection(),

//             // Location Section
//             _buildLocationSection(),

//             // Time Selection Section
//             _buildTimeSection(),

//             // Bottom padding
//             SizedBox(height: 100.h),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildServicesSection() {
//     return Container(
//       padding: EdgeInsets.all(AppPadding.p24.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             translate(AppStrings.services),
//             style: AppStyles.title16Bold.copyWith(
//               color: ColorManager.black,
//             ),
//           ),
//           SizedBox(height: AppPadding.p16.h),
//           sl<GetUserProfileBloc>.call().profile.isSubscribed == true
//               ? SubscriptionAndService(
//                   subscription:
//                       sl<PlansAndSubscriptionBloc>.call().subscription,
//                   message: sl<PlansAndSubscriptionBloc>.call().message,
//                 )
//               : const ServicesList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildAddOnsSection() {
//     return Container(
//       padding: EdgeInsets.all(AppPadding.p24.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             translate(AppStrings.addOns),
//             style: AppStyles.title16Bold.copyWith(
//               color: ColorManager.black,
//             ),
//           ),
//           SizedBox(height: AppPadding.p16.h),
//           BlocBuilder<OffersBloc, OffersState>(
//             builder: (context, state) {
//               OffersBloc offersBloc = sl<OffersBloc>();

//               if (offersBloc.addOnsList.isEmpty) {
//                 return Center(
//                   child: Text(translate(AppStrings.noAddonsRequested)),
//                 );
//               }

//               return GridView.count(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 14.w,
//                 mainAxisSpacing: 12.h,
//                 childAspectRatio: (120.w / 190.h),
//                 children: offersBloc.addOnsList.asMap().keys.map((int index) {
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         if (offersBloc.cartAddOnsList
//                             .contains(offersBloc.addOnsList[index])) {
//                           var deleteCartService = offersBloc.cartAddOnsList
//                               .indexOf(offersBloc.addOnsList[index]);
//                           offersBloc.add(DeleteExtraCart(
//                             index: deleteCartService,
//                             extra: offersBloc.addOnsList[index],
//                           ));
//                         } else {
//                           offersBloc.add(AddExtraCart(
//                               extra: offersBloc.addOnsList[index]));
//                         }
//                       });
//                     },
//                     child: CardAddOns(
//                       index: index,
//                       onTap: () {
//                         setState(() {
//                           if (offersBloc.cartAddOnsList
//                               .contains(offersBloc.addOnsList[index])) {
//                             var deleteCartService = offersBloc.cartAddOnsList
//                                 .indexOf(offersBloc.addOnsList[index]);
//                             offersBloc.add(DeleteExtraCart(
//                               index: deleteCartService,
//                               extra: offersBloc.addOnsList[index],
//                             ));
//                           } else {
//                             offersBloc.add(AddExtraCart(
//                                 extra: offersBloc.addOnsList[index]));
//                           }
//                         });
//                       },
//                     ),
//                   );
//                 }).toList(),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCarFreshenedSection() {
//     return Container(
//       padding: EdgeInsets.all(AppPadding.p24.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             translate("Car Freshened"),
//             style: AppStyles.title16Bold.copyWith(
//               color: ColorManager.black,
//             ),
//           ),
//           SizedBox(height: AppPadding.p16.h),
//           Container(
//             padding: EdgeInsets.all(AppPadding.p16.w),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12.r),
//               border:
//                   Border.all(color: ColorManager.lightGray.withOpacity(0.3)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     translate("Add car freshened service"),
//                     style: AppStyles.subtext14Regular.copyWith(
//                       color: ColorManager.black,
//                     ),
//                   ),
//                 ),
//                 Switch(
//                   value: singleton.isCarFreshened,
//                   onChanged: (value) {
//                     setState(() {
//                       singleton.isCarFreshened = value;
//                     });
//                   },
//                   activeColor: ColorManager.primary,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVehiclesSection() {
//     return Container(
//       padding: EdgeInsets.all(AppPadding.p24.w),
//       child: BlocConsumer<VehiclesBloc, VehiclesState>(
//         bloc: sl<VehiclesBloc>(),
//         listener: (context, state) {
//           if (state is GetVehiclesError) {
//             showSnackBar(
//               buildContext: context,
//               message: "error something wrong please try again",
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state is GetVehiclesLoading || state is GetCarModelLoading) {
//             return const LoadingWidget();
//           } else if (state is GetVehiclesError) {
//             return Container();
//           } else if (state is GetVehiclesEmpty) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   translate(AppStrings.yourRecentCars),
//                   style:
//                       AppStyles.title16Bold.copyWith(color: ColorManager.black),
//                 ),
//                 SizedBox(height: 16.h),
//                 EmptyVehiclesScreen(
//                   onPressed: () {
//                     pushPage(context, EditVehiclesScreen(create: true));
//                   },
//                 ),
//               ],
//             );
//           } else {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   translate(AppStrings.yourRecentCars),
//                   style:
//                       AppStyles.title16Bold.copyWith(color: ColorManager.black),
//                 ),
//                 SizedBox(height: 16.h),
//                 SizedBox(
//                   height: 300.h,
//                   child: ListView.separated(
//                     itemCount: sl<VehiclesBloc>().vehiclesList.length,
//                     separatorBuilder: (BuildContext context, int index) {
//                       return SizedBox(height: 7.h);
//                     },
//                     itemBuilder: (context, int index) {
//                       int selectedColor = colorList.indexWhere((element) =>
//                           element.colorName ==
//                           sl<VehiclesBloc>().vehiclesList[index].color!);
//                       return Padding(
//                         padding: EdgeInsets.symmetric(
//                             horizontal: 8.w, vertical: 5.h),
//                         child: InkWell(
//                           onTap: () {
//                             sl<VehiclesBloc>().add(SelectCar(
//                                 vehicle:
//                                     sl<VehiclesBloc>().vehiclesList[index]));
//                           },
//                           child: VehiclesCard(
//                               index: index, selectedColor: selectedColor),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 Center(
//                   child: ButtonDottedShared(
//                     onPressed: () {
//                       pushPage(context, EditVehiclesScreen(create: true));
//                     },
//                     text: translate(AppStrings.addNewVehicles),
//                   ),
//                 ),
//               ],
//             );
//           }
//         },
//       ),
//     );
//   }

//   Widget _buildLocationSection() {
//     return Container(
//       padding: EdgeInsets.all(AppPadding.p24.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             translate(AppStrings.carLocation),
//             style: AppStyles.title16Bold.copyWith(
//               color: ColorManager.black,
//             ),
//           ),
//           SizedBox(height: AppPadding.p16.h),
//           BlocBuilder<LocationBloc, LocationState>(
//             builder: (context, state) {
//               return Column(
//                 children: [
//                   FixedMap(
//                     latLng:
//                         LatLng(blcoPosition.latitude, blcoPosition.longitude),
//                   ),
//                   SizedBox(height: 31.85.h),
//                   Text(
//                     translate(AppStrings.location),
//                     style: AppStyles.title16Bold.copyWith(
//                       color: ColorManager.black,
//                     ),
//                   ),
//                   SizedBox(height: AppPadding.p12.h),
//                   Text(
//                     fullLocationName,
//                     style: AppStyles.title16Regular.copyWith(
//                       color: ColorManager.black,
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   Divider(
//                     color: ColorManager.divider,
//                     thickness: 1,
//                     endIndent: 6.5.w,
//                     indent: 6.5.w,
//                     height: 20.h,
//                   ),
//                   SizedBox(height: AppPadding.p8.h),
//                   Row(
//                     children: [
//                       Text(
//                         translate(AppStrings.notes),
//                         style: AppStyles.title16Bold.copyWith(
//                           color: ColorManager.black,
//                         ),
//                       ),
//                       const Spacer(),
//                       Text(
//                         "(${translate(AppStrings.optinal)})",
//                         style: AppStyles.title16Regular.copyWith(
//                           color: ColorManager.black,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: AppPadding.p12.h),
//                   TextFormShared(
//                     initialValue: singleton.nearByDescription,
//                     onChanged: (value) {
//                       setState(() {
//                         singleton.nearByDescription = value;
//                       });
//                     },
//                     hintText: translate(AppStrings.notes),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimeSection() {
//     return Container(
//       padding: EdgeInsets.all(AppPadding.p24.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             translate(AppStrings.pickATime),
//             style: AppStyles.title16Bold.copyWith(
//               color: ColorManager.black,
//             ),
//           ),
//           SizedBox(height: AppPadding.p16.h),
//           BlocConsumer<BookingOrderBloc, BookingOrderState>(
//             listener: (context, state) {
//               if (state is CalenderAvailableFailed) {
//                 showSnackBar(
//                   buildContext: context,
//                   message: state.errorModel!.en!,
//                 );
//               }
//               if (state is CalenderAvailableSuccess) {
//                 _cachedCalender = state.calenderAvailableModel;
//               }
//             },
//             builder: (context, state) {
//               if (state is CalenderAvailableLoading) {
//                 // Show cached calendar while refreshing
//                 if (_cachedCalender != null && _cachedCalender!.isNotEmpty) {
//                   return CalenderTimeSlotsWidget(
//                     calender: _cachedCalender!,
//                   );
//                 }
//                 return const LoadingWidget();
//               }
//               if (state is CalenderAvailableSuccess) {
//                 final calender = state.calenderAvailableModel;
//                 return calender.isEmpty
//                     ? Center(
//                         child: Text(
//                           translate(AppStrings.noContent),
//                           style: AppStyles.subtext14Regular,
//                         ),
//                       )
//                     : CalenderTimeSlotsWidget(
//                         calender: calender,
//                       );
//               }
//               // For any other state, fall back to cached calendar if available
//               if (_cachedCalender != null && _cachedCalender!.isNotEmpty) {
//                 return CalenderTimeSlotsWidget(
//                   calender: _cachedCalender!,
//                 );
//               }
//               return const SizedBox();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
