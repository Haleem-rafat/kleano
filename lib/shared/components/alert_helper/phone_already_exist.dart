import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class PhoneAlreadyExist extends StatefulWidget {
  final String phoneNumber;
  const PhoneAlreadyExist({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<PhoneAlreadyExist> createState() => _PhoneAlreadyExistState();
}

class _PhoneAlreadyExistState extends State<PhoneAlreadyExist> {
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
              padding: EdgeInsets.fromLTRB(
                14.76.w,
                17.81.h,
                14.76.w,
                41.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 286.48.w,
                    height: 150.h,
                    child:
                        Stack(alignment: Alignment.center, children: <Widget>[
                      Positioned(
                          top: 0,
                          left: 0,
                          child: SvgPicture.asset(AssetsManager.vectorLayout)),
                      Positioned(
                        top: 50.h,
                        left: 40.w,
                        right: 30.w,
                        child: SizedBox(
                          width: 150.w,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text:
                                  translate(AppStrings.thisNumberAlreadyExists),
                              style: AppStyles.titleGray16Regular.copyWith(
                                color: ColorManager.darkGrey,
                              ),
                              children: <TextSpan>[
                                TextSpan(
                                  text: widget.phoneNumber,
                                  style: AppStyles.titleGray16Regular.copyWith(
                                    color: ColorManager.darkGrey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  GestureDetector(
                    onTap: () => pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      translate(AppStrings.backToHome),
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.medGray,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              )),
        );
      },
    );
  }
}
