import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Home/bloc/location/location_bloc.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/utilties/navigator.dart';

class ClearPlaceAlert extends StatelessWidget {
  Function() delete;
  String name;

  ClearPlaceAlert({Key? key, required this.delete, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 40.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r),
      ),
      elevation: 0.6,
      backgroundColor: Colors.transparent,
      insetAnimationCurve: Curves.easeInOut,
      child: _buildChild(context),
    );
  }

  _buildChild(BuildContext context) {
    return StatefulBuilder(
      builder: (BuildContext context, Function setState) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Container(
              decoration: BoxDecoration(
                color: ColorManager.white,
                border: Border.all(color: ColorManager.darkGrey),
              ),
              padding: EdgeInsets.fromLTRB(
                AppPadding.p20.w,
                AppPadding.p61.h,
                AppPadding.p20.w,
                AppPadding.p41.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  AppPadding.p24.ph,
                  Text(
                    name,
                    style: AppStyles.title16Regular
                        .copyWith(color: ColorManager.darkGrey),
                    textAlign: TextAlign.center,
                  ),
                  AppPadding.p20.ph,
                  Center(
                    child: BlocConsumer<LocationBloc, LocationState>(
                      listener: (context, state) {
                        if (state is UnSaveLocationSuccess ||
                            state is ClearSaveLocationSuccess) {
                          pop(context);
                        }
                      },
                      builder: (context, state) {
                        if (state is ClearSaveLocationLoading ||
                            state is UnSaveLocationLoading) {
                          return const LoadingWidget();
                        } else {
                          return ButtonsShared(
                            height: 50.h,
                            width: 220.w,
                            onPressed: () {
                              delete();
                            },
                            colorButton: ColorManager.red,
                            colorText: ColorManager.white,
                            colorBorder: ColorManager.red,
                            text: translate(AppStrings.delete),
                          );
                        }
                      },
                    ),
                  ),
                  AppPadding.p20.ph,
                  GestureDetector(
                    onTap: () {
                      pop(context);
                    },
                    child: Text(
                      translate(AppStrings.cancel),
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.medGray,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w500,
                        decorationColor: ColorManager.medGray,
                      ),
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }
}
