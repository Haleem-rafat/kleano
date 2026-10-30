import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class SavedPlacesTab extends StatelessWidget {
  Completer<GoogleMapController> myController;

  SavedPlacesTab({Key? key, required this.myController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationBloc, LocationState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (sl<LocationBloc>().savedLocation.isEmpty) {
          return Center(
            child: SvgPicture.asset(AssetsManager.emptySavedSvg),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              InkWell(
                onTap: () {
                  AlertHelper.clearPlaceAlert(
                    context,
                    () {
                      sl<LocationBloc>()
                        ..add(ClearSavedLocation())
                        ..stream.listen((state) {
                          if (state is ClearSaveLocationSuccess) {
                            sl<LocationBloc>().add(GetRecentLocation());
                          }
                        });
                    },
                    translate(AppStrings.deleteAllSaved),
                  );
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
                  itemCount: sl<LocationBloc>().savedLocation.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
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
                                        .savedLocation[index]
                                        .latitude!,
                                    longitude: sl<LocationBloc>()
                                        .savedLocation[index]
                                        .longitude!,
                                    streetName: sl<LocationBloc>()
                                        .savedLocation[index]
                                        .streetName!,
                                    subAdministrativeArea: sl<LocationBloc>()
                                        .savedLocation[index]
                                        .subAdministrativeArea!,
                                    country: sl<LocationBloc>()
                                        .savedLocation[index]
                                        .country!,
                                    latLng: LatLng(
                                      sl<LocationBloc>()
                                          .savedLocation[index]
                                          .latitude!,
                                      sl<LocationBloc>()
                                          .savedLocation[index]
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
                                  title: sl<LocationBloc>()
                                      .savedLocation[index]
                                      .savedName!,
                                  subtitle: sl<LocationBloc>()
                                      .savedLocation[index]
                                      .streetName!,
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              AlertHelper.clearPlaceAlert(
                                context,
                                () {
                                  sl<LocationBloc>().add(UnSaveLocation(
                                    id: sl<LocationBloc>()
                                        .savedLocation[index]
                                        .sId!,
                                    type: sl<LocationBloc>()
                                        .savedLocation[index]
                                        .type,
                                    index: index,
                                  ));
                                },
                                translate(AppStrings.deleteSaved),
                              );
                            },
                            child: SvgPicture.asset(
                                AssetsManager.bookMarkFilledLogo),
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

class PlaceInfo extends StatelessWidget {
  final String? title;
  final String subtitle;
  const PlaceInfo({
    super.key,
    this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        SvgPicture.asset(
          AssetsManager.locationSetIcon,
        ),
        8.horizontalSpace,
        Expanded(
          child: title != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title!,
                      style: AppStyles.subtext14Regular.copyWith(
                        color: ColorManager.darkGrey,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.subtext14Regular.copyWith(
                        color: ColorManager.medGray,
                      ),
                    ),
                  ],
                )
              : Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.subtext14Regular.copyWith(
                    color: ColorManager.medGray,
                  ),
                ),
        )
      ],
    );
  }
}
