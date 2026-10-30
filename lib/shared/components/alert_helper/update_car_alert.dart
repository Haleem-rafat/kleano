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

class UpdateCarAlert extends StatelessWidget {
  const UpdateCarAlert({super.key});

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
          child: DecoratedBox(
              decoration: BoxDecoration(
                color: ColorManager.white,
                border: Border.all(color: ColorManager.darkGrey),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  36.w,
                  52.h,
                  36.w,
                  35.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SvgPicture.asset(AssetsManager.carSave2SVG),
                    AppPadding.p8.ph,
                    Text(
                      translate(AppStrings.congratulations),
                      style: AppStyles.title16Bold
                          .copyWith(color: ColorManager.black),
                    ),
                    AppPadding.p8.ph,
                    SizedBox(
                      width: 244.w,
                      child: Text(
                        translate(AppStrings.carSave),
                        textAlign: TextAlign.center,
                        style: AppStyles.subtext14Regular
                            .copyWith(color: ColorManager.black),
                      ),
                    ),
                    AppPadding.p20.ph,
                    ButtonsShared(
                      onPressed: () {
                        sl<VehiclesBloc>().add(GetVehicles());
                        pop(context);
                        pop(context);
                      },
                      text: translate(AppStrings.myVehicles),
                    )
                  ],
                ),
              )),
        );
      },
    );
  }
}
