import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/my_vehicles/bloc/vehicles_bloc.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class DeleteCarAlert extends StatelessWidget {
  String sId;
  int index;
  DeleteCarAlert({super.key, required this.sId, required this.index});

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
                  SvgPicture.asset(AssetsManager.deleteCarSVG),
                  AppPadding.p24.ph,
                  Text(
                    translate(AppStrings.deleteCar),
                    style: AppStyles.title16Regular.copyWith(color: ColorManager.darkGrey),
                    textAlign: TextAlign.center,
                  ),
                  AppPadding.p20.ph,
                  ButtonsShared(
                    onPressed: () {
                      sl<VehiclesBloc>().add(DeleteCar(id: sId, index: index));
                      pop(context);
                    },
                    text: translate(AppStrings.deleteCarButton),
                    width: 220,
                    colorButton: ColorManager.red,
                    colorBorder: ColorManager.red,
                  ),
                  24.5.verticalSpace,
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
                          decorationColor: ColorManager.medGray),
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }
}
