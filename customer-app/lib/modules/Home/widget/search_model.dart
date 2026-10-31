import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchModel extends StatelessWidget {
  String currentAddress;
  Completer<GoogleMapController> controller;
  void Function() onTap;
  void Function() setOnMap;
  LatLng currentPosition;
  String subAdministrativeArea;
  String country;
  SearchModel({
    super.key,
    required this.currentAddress,
    required this.controller,
    required this.onTap,
    required this.setOnMap,
    required this.currentPosition,
    required this.subAdministrativeArea,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Container(
        //   width: 343.w,
        //   decoration: BoxDecoration(
        //       color: ColorManager.divider.withValues(alpha: 0.23),
        //       borderRadius: BorderRadius.only(
        //         topLeft: Radius.circular(12.r),
        //         topRight: Radius.circular(12.r),
        //       )),
        //   padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
        //   child: Text(
        //     translate(AppStrings.currentLocation),
        //     style:
        //         AppStyles.body14Medium.copyWith(color: ColorManager.darkGrey),
        //   ),
        // ),
        // 8.verticalSpace,
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 18.w),
        //   child: InkWell(
        //     onTap: () {
        //       sl<LocationBloc>().add(GoToLocation(
        //         latitude: currentPosition.latitude,
        //         longitude: currentPosition.longitude,
        //         streetName: currentAddress,
        //         subAdministrativeArea: subAdministrativeArea,
        //         country: country,
        //         latLng: const LatLng(0, 0),
        //         myController: controller,
        //         context: context,
        //         myZoom: 14.4746,
        //         current: true,
        //       ));
        //     },
        //     child: Row(
        //       children: <Widget>[
        //         SvgPicture.asset(AssetsManager.locationSetIcon),
        //         8.horizontalSpace,
        //         Expanded(
        //           child: Text(
        //             currentAddress,
        //             style: AppStyles.caption12Regular
        //                 .copyWith(color: ColorManager.darkGrey),
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        // SizedBox(
        //   height: sl<LocationBloc>().recentLocation.isEmpty
        //       ? 10.h
        //       : sl<LocationBloc>().recentLocation.length < 2
        //           ? 100.h
        //           : 85.h,
        //   child: ListView.separated(
        //     physics: const NeverScrollableScrollPhysics(),
        //     itemCount: sl<LocationBloc>().recentLocation.length > 2
        //         ? 2
        //         : sl<LocationBloc>().recentLocation.length,
        //     padding: EdgeInsets.zero,
        //     separatorBuilder: (BuildContext context, int index) {
        //       return AppPadding.p12.ph;
        //     },
        //     itemBuilder: (context, index) {
        //       return InkWell(
        //         onTap: () {
        //           sl<LocationBloc>().add(GoToLocation(
        //             latitude:
        //                 sl<LocationBloc>().recentLocation[index].latitude!,
        //             longitude:
        //                 sl<LocationBloc>().recentLocation[index].longitude!,
        //             streetName:
        //                 sl<LocationBloc>().recentLocation[index].streetName!,
        //             subAdministrativeArea: sl<LocationBloc>()
        //                 .recentLocation[index]
        //                 .subAdministrativeArea!,
        //             country: sl<LocationBloc>().recentLocation[index].country!,
        //             latLng: LatLng(
        //               sl<LocationBloc>().recentLocation[index].latitude!,
        //               sl<LocationBloc>().recentLocation[index].longitude!,
        //             ),
        //             myController: controller,
        //             context: context,
        //             myZoom: 14.4746,
        //             current: false,
        //           ));
        //         },
        //         child: Padding(
        //           padding: EdgeInsets.symmetric(horizontal: 18.w),
        //           child: sl<LocationBloc>().recentLocation[index].isSaved!
        //               ? ListTile(
        //                   contentPadding: EdgeInsets.zero,
        //                   horizontalTitleGap: 5.w,
        //                   leading:
        //                       SvgPicture.asset(AssetsManager.locationSetIcon),
        //                   title: Text(
        //                     sl<LocationBloc>().recentLocation[index].savedName!,
        //                     style: AppStyles.subtext14Regular
        //                         .copyWith(color: ColorManager.darkGrey),
        //                   ),
        //                   subtitle: Text(
        //                     sl<LocationBloc>()
        //                         .recentLocation[index]
        //                         .streetName!,
        //                     style: AppStyles.subtext14Regular
        //                         .copyWith(color: ColorManager.lightGray),
        //                   ),
        //                 )
        //               : Row(
        //                   children: <Widget>[
        //                     SvgPicture.asset(AssetsManager.locationSetIcon),
        //                     8.horizontalSpace,
        //                     Expanded(
        //                       child: Text(
        //                         sl<LocationBloc>()
        //                             .recentLocation[index]
        //                             .streetName!,
        //                         style: AppStyles.caption12Regular
        //                             .copyWith(color: ColorManager.darkGrey),
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
        InkWell(
          onTap: onTap,
          child: Container(
            width: 343.w,
            decoration: BoxDecoration(
              color: ColorManager.divider.withValues(alpha: 0.23),
            ),
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 9.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  translate(AppStrings.searchLocation),
                  style: AppStyles.body14Medium
                      .copyWith(color: ColorManager.darkGrey),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18.w,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: const Divider(
            color: ColorManager.divider,
            thickness: 1,
          ),
        ),
        16.verticalSpace,
        InkWell(
          onTap: setOnMap,
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Text(
                translate(AppStrings.setLocationMap),
                style: AppStyles.body14Medium
                    .copyWith(color: ColorManager.darkGrey),
              ),
            ),
          ),
        ),
        21.verticalSpace,
      ],
    );
  }
}
