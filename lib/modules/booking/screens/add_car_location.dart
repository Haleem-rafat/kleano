// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_translate/flutter_translate.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:thewasher/core/resources/app_styles.dart';
// import 'package:thewasher/core/resources/color_manager.dart';
// import 'package:thewasher/core/resources/strings_manager.dart';
// import 'package:thewasher/core/resources/values_manager.dart';
// import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
// import 'package:thewasher/modules/Home/data/model/piked_model.dart';
// import 'package:thewasher/modules/booking/widgets/location/fixed_map.dart';
// import 'package:thewasher/shared/components/text-form-shared.dart';
// import 'package:thewasher/shared/services/service_locator.dart';
// import 'package:thewasher/shared/singleton.dart';

// class AddCarLocation extends StatelessWidget {
//   const AddCarLocation({super.key});

//   @override
//   Widget build(BuildContext context) {
//     PickedLocationModel location =
//         sl.call<LocationBloc>.call().pickedLocationModel;
//     GeneralSingleton singleton = GeneralSingleton();
//     singleton.nearByDescription ?? '';

//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//       },
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
//           child: StatefulBuilder(builder: (context, myState) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: <Widget>[
//                 Text(
//                   translate(AppStrings.carLocation),
//                   style: AppStyles.title16Bold.copyWith(
//                     color: ColorManager.black,
//                   ),
//                 ),
//                 SizedBox(
//                   height: AppPadding.p16.h,
//                 ),
//                 FixedMap(
//                   latLng: LatLng(
//                       location.pickedLocationLat!, location.pickedLocationLng!),
//                 ),
//                 SizedBox(
//                   height: 31.85.h,
//                 ),
//                 Text(
//                   translate(AppStrings.location),
//                   style: AppStyles.title16Bold.copyWith(
//                     color: ColorManager.black,
//                   ),
//                 ),
//                 SizedBox(
//                   height: AppPadding.p12.h,
//                 ),
//                 Text(
//                   location.pickedLocationName!,
//                   style: AppStyles.title16Regular.copyWith(
//                     color: ColorManager.black,
//                   ),
//                 ),
//                 8.verticalSpace,
//                 Divider(
//                   color: ColorManager.divider,
//                   thickness: 1,
//                   endIndent: 6.5.w,
//                   indent: 6.5.w,
//                   height: 20.h,
//                 ),
//                 SizedBox(
//                   height: AppPadding.p8.h,
//                 ),
//                 Row(
//                   children: [
//                     Text(
//                       translate(AppStrings.notes),
//                       style: AppStyles.title16Bold.copyWith(
//                         color: ColorManager.black,
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       "(${translate(AppStrings.optinal)})",
//                       style: AppStyles.title16Regular.copyWith(
//                         color: ColorManager.black,
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(
//                   height: AppPadding.p12.h,
//                 ),
//                 TextFormShared(
//                     initialValue: singleton.nearByDescription,
//                     onChanged: (value) {
//                       myState(() {
//                         singleton.nearByDescription = value;
//                       });
//                     },
//                     hintText: translate(AppStrings.notes))
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }
