import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/modules/Home/widget/saved_places_tab.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class RecentPlacesTab extends StatelessWidget {
  Completer<GoogleMapController> myController;
  TextEditingController nameController;
  RecentPlacesTab(
      {Key? key, required this.myController, required this.nameController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationBloc, LocationState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (sl<LocationBloc>().recentLocation.isEmpty) {
          return Center(
            child: SvgPicture.asset(AssetsManager.emptyRecentSvg),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              InkWell(
                onTap: () {
                  // sl<LocationBloc>().add(ClearSavedLocation());
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
                  child: Text(
                    translate(AppStrings.clearAll),
                    style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: ColorManager.primary),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: sl<LocationBloc>().recentLocation.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: const Divider(
                        color: ColorManager.divider,
                        thickness: 1,
                      ),
                    );
                  },
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 31.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                                onTap: () {
                                  sl<LocationBloc>().add(GoToLocation(
                                    latitude: sl<LocationBloc>()
                                        .recentLocation[index]
                                        .latitude!,
                                    longitude: sl<LocationBloc>()
                                        .recentLocation[index]
                                        .longitude!,
                                    streetName: sl<LocationBloc>()
                                        .recentLocation[index]
                                        .streetName!,
                                    subAdministrativeArea: sl<LocationBloc>()
                                        .recentLocation[index]
                                        .subAdministrativeArea!,
                                    country: sl<LocationBloc>()
                                        .recentLocation[index]
                                        .country!,
                                    latLng: LatLng(
                                      sl<LocationBloc>()
                                          .recentLocation[index]
                                          .latitude!,
                                      sl<LocationBloc>()
                                          .recentLocation[index]
                                          .longitude!,
                                    ),
                                    myController: myController,
                                    context: context,
                                    myZoom: 14.4746,
                                    current: false,
                                  ));
                                  pop(context);
                                },
                                child: PlaceInfo(
                                  subtitle: sl<LocationBloc>()
                                      .recentLocation[index]
                                      .streetName!,
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              // AlertHelper.savedAlert(
                              //     context, nameController, true,
                              //     index: index);
                            },
                            child: SvgPicture.asset(AssetsManager.bookMarkSVG),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
