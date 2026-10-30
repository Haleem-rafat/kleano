import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
// import 'package:google_maps_webservice/src/places.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/shared/components/alert_helper/alert_helper_main.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/text-form-shared.dart';
import 'package:thewasher/utilties/navigator.dart';

class SavedAlert extends StatelessWidget {
  // PlacesDetailsResponse? detail;
  TextEditingController nameController;
  bool recent;
  int? index;

  SavedAlert(
      {super.key,
      // this.detail,
      required this.nameController,
      required this.recent,
      this.index});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      elevation: 0.6,
      backgroundColor: Colors.transparent,
      insetAnimationCurve: Curves.easeInOut,
      child: _buildChild(context),
    );
  }

  StatefulBuilder _buildChild(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, Function setState) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
              decoration: BoxDecoration(
                color: ColorManager.white,
                border: Border.all(color: ColorManager.darkGrey),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 64.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Name you Location",
                    style: AppStyles.title16Bold
                        .copyWith(color: ColorManager.thirdColor400),
                  ),
                  24.verticalSpace,
                  TextFormShared(
                    hintText: "",
                    controller: nameController,
                  ),
                  16.verticalSpace,
                  BlocConsumer<LocationBloc, LocationState>(
                    listener: (context, state) {
                      if (state is SaveLocationSuccess ||
                          state is SaveRecentLocationSuccess) {
                        pop(context);
                        AlertHelper.successSavedLocation(context,
                            message: translate(
                                AppStrings.yourLocationSavedSuccessfully));
                      } else if (state is SaveLocationFailed ||
                          state is SaveRecentLocationFailed) {
                        debugPrint("sssss $state");
                      }
                    },
                    builder: (context, state) {
                      if (state is SaveLocationLoading ||
                          state is SaveRecentLocationLoading) {
                        return const LoadingWidget();
                      } else {
                        return SizedBox();
                        // return ButtonsShared(
                        //   onPressed: () {
                        //     if (nameController.text.isNotEmpty) {
                        //       if (!recent) {
                        //         sl<LocationBloc>()
                        //           ..add(SaveLocation(
                        //             latitude: detail!
                        //                 .result.geometry!.location.lat
                        //                 .toString(),
                        //             longitude: detail!
                        //                 .result.geometry!.location.lng
                        //                 .toString(),
                        //             streetName: detail!
                        //                 .result.addressComponents[0].longName,
                        //             country: detail!.result.addressComponents
                        //                         .length ==
                        //                     5
                        //                 ? detail!.result.addressComponents[4]
                        //                     .longName
                        //                 : detail!.result.addressComponents[3]
                        //                     .longName,
                        //             subAdministrativeArea: detail!
                        //                 .result.addressComponents[2].longName,
                        //             savedName: nameController.text,
                        //           ))
                        //           ..stream.listen((state) {
                        //             if (state is SaveLocationSuccess) {
                        //               sl<LocationBloc>()
                        //                   .add(GetSavedLocation());
                        //             }
                        //           });
                        //         nameController.text = "";
                        //       } else {
                        //         sl<LocationBloc>().add(SaveRecentLocation(
                        //           id: sl<LocationBloc>()
                        //               .recentLocation[index!]
                        //               .sId!,
                        //           savedName: nameController.text,
                        //           index: index!,
                        //         ));
                        //         nameController.text = "";
                        //       }
                        //     }
                        //   },
                        //   text: "Save Location",
                        //   width: 220,
                        //   height: 52,
                        //   colorText: ColorManager.white,
                        //   colorButton: ColorManager.primary,
                        //   colorBorder: ColorManager.primary,
                        //   showShadow: false,
                        // );
                      }
                    },
                  ),
                ],
              )),
        );
      },
    );
  }
}
