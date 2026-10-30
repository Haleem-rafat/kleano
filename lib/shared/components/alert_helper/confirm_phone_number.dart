import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/utilties/navigator.dart';

class ConfirmPhoneNumber extends StatefulWidget {
  final String phoneNumber;
  final String userName;
  final String? email;
  final bool comeFromSignUpScreen;

  const ConfirmPhoneNumber({
    super.key,
    required this.phoneNumber,
    required this.userName,
    this.email,
    required this.comeFromSignUpScreen,
  });

  @override
  State<ConfirmPhoneNumber> createState() => _ConfirmPhoneNumberState();
}

class _ConfirmPhoneNumberState extends State<ConfirmPhoneNumber> {
  late bool comeFromSignUpScreen;

  @override
  void initState() {
    super.initState();
    comeFromSignUpScreen = widget.comeFromSignUpScreen;
  }

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
                color: ColorManager.white,
                padding: EdgeInsets.fromLTRB(
                  25.w,
                  67.h,
                  25.w,
                  52.5.h,
                ),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  SizedBox(
                    width: 266.w,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: translate(AppStrings.sendVerificationCode),
                        style: AppStyles.titleGray16Regular.copyWith(
                          color: ColorManager.darkGrey,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: " ${widget.phoneNumber} ?",
                            style: AppStyles.titleGray16Regular.copyWith(
                              color: ColorManager.darkGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  48.verticalSpace,
                  32.verticalSpace,
                  GestureDetector(
                    onTap: () => pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      translate(AppStrings.changeNumber),
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.primary,
                        decoration: TextDecoration.underline,
                        decorationColor: ColorManager.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ])));
      },
    );
  }
}
