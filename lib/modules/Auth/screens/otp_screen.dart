import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/phone_auth/phone_number_verification_cubit.dart';
import 'package:thewhsherbiker/modules/Auth/screens/update_password.dart';
import 'package:thewhsherbiker/modules/Auth/widget/pin_code.dart';
import 'package:thewhsherbiker/shared/components/arrow_back.dart';
import 'package:thewhsherbiker/shared/components/buttons.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String verificationId;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.verificationId,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late TextEditingController textEditingController;
  final GlobalKey<FormState> pinKey = GlobalKey<FormState>();
  bool pinComplete = false;
  late String otpCode = "";
  bool login = false;
  late final PhoneNumberVerificationCubit phoneNumberVerificationCubit;
  String fcmToken = '';
  late final CountdownTimerController countdownTimerController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    phoneNumberVerificationCubit = BlocProvider.of<PhoneNumberVerificationCubit>(context);
    _timerCounter();
  }

  void _timerCounter() {
    countdownTimerController = CountdownTimerController(
      endTime: DateTime.now()
          .add(const Duration(seconds: 120))
          .millisecondsSinceEpoch,
    );
  }

  @override
  void dispose() {
    countdownTimerController.dispose();
    super.dispose();
  }

  void _verifyPhoneNumber() {
    pinComplete
        ? phoneNumberVerificationCubit.verifyPhone(
            context: context,
            signup: true,
            verificationId: widget.verificationId,
            smsCode: otpCode,
          )
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            AppStyles.darkStatusBarIconsWithTransparentColorStyle,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: ColorManager.primary,
        ),
        leading: !countdownTimerController.isRunning
            ? const ArrowBackShared()
            : null,
      ),
      body: PopScope(
        canPop: !countdownTimerController.isRunning,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Localizations.localeOf(context).languageCode == "en"
                      ? SvgPicture.asset(ImageAssets.logoImg)
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: SvgPicture.asset(ImageAssets.logoImg),
                        )
                ],
              ),
              Text(translate(AppStrings.verification),
                  style: AppStyles.title24Bold
                      .copyWith(color: ColorManager.darkGrey)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    55.w, AppSize.s12.h, 55.w, AppSize.s54.h),
                child: Directionality(
                  textDirection: Localizations.localeOf(context).languageCode == 'en' ? TextDirection.ltr: TextDirection.rtl,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: translate(AppStrings.sentVerificationCode),
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.darkGrey,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: " ${widget.phone}",
                          style: AppStyles.title16Regular.copyWith(
                            color: ColorManager.darkGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Form(
                key: pinKey,
                child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: AppPadding.p8.h,
                        horizontal: AppPadding.p30.w),
                    child: PinCodeWidget(
                      codeController: textEditingController,
                      onCompleted: (String v) {
                        setState(() {
                          pinComplete = true;
                          otpCode = v;
                        });
                      },
                    )),
              ),
              SizedBox(
                height: AppSize.s40.h,
              ),
              BlocConsumer<PhoneNumberVerificationCubit,
                  PhoneNumberVerificationState>(
                listener: (context, PhoneNumberVerificationState state) {
                  if (state is PhoneNumberVerifiedSuccessfullyState) {
                    fcmToken = state.fcmToken;
                    log('----FCM token--: ${state.fcmToken}');
                    AppShared.setFcmValue(state.fcmToken);
                    pushPage(context, UpdatePassword(profile: false,));
                    debugPrint("hello");
                  } else if (state
                      is PhoneNumberVerificationUnknownErrorState) {
                    SnackBar(
                      content: Text(
                        state.error!,
                        textAlign: TextAlign.center,
                      ),
                    );
                  } else if (state is OTPResentState) {
                    setState(() {
                      countdownTimerController.endTime = DateTime.now()
                          .add(const Duration(seconds: 120))
                          .millisecondsSinceEpoch;
                    });
                  } else if (state is! OTPAutoRetrievalTimeoutState) {
                    setState(() {
                      countdownTimerController.endTime = DateTime.now()
                          .add(const Duration(seconds: 120))
                          .millisecondsSinceEpoch;
                    });
                  } else if (state is OTPCodeIsInvalidState) {
                    setState(() {
                      login = false;
                      countdownTimerController.dispose();
                      !countdownTimerController.isRunning;
                    });
                  }
                },
                builder: (context, PhoneNumberVerificationState state) {
                  if (state is VerifyPhoneNumberLoadingState ||
                      state is PhoneNumberVerifiedSuccessfullyState) {
                    return const LoadingWidget();
                  }
                  return Column(
                    children: [
                      if (state is AskUserForOTPCodeState ||
                          state is OTPResentState ||
                          state is OTPAutoRetrievalTimeoutState)
                        SizedBox(height: 18.h),
                      if (state is AskUserForOTPCodeState ||
                          state is OTPResentState ||
                          state is OTPAutoRetrievalTimeoutState)
                        CountdownTimer(
                          controller: countdownTimerController,
                          widgetBuilder: (BuildContext context,
                              CurrentRemainingTime? currentRemainingTime) {
                            return InkWell(
                              onTap: currentRemainingTime == null
                                  ? () {
                                      phoneNumberVerificationCubit
                                          .resendOTPRequest(
                                              phoneNumber: widget.phone);
                                    }
                                  : null,
                              child: currentRemainingTime != null
                                  ? Text(
                                      "${translate(AppStrings.receiveTheCodeResendAfter)} 0${currentRemainingTime.min ?? '0'}:${currentRemainingTime.sec != null ? currentRemainingTime.sec! < 10 ? '0${currentRemainingTime.sec}' : currentRemainingTime.sec : ''}",
                                      style: AppStyles.title16Regular.copyWith(
                                        color: ColorManager.darkGrey,
                                      ),
                                    )
                                  : RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        text: translate(
                                            AppStrings.didReceiveCode),
                                        style:
                                            AppStyles.title16Regular.copyWith(
                                          color: ColorManager.darkGrey,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: translate(
                                                AppStrings.resendCode),
                                            style: AppStyles.title16Regular
                                                .copyWith(
                                              color: ColorManager.darkGrey,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                            );
                          },
                        ),
                      SizedBox(
                        height: AppSize.s40.h,
                      ),
                      ButtonsShared(
                        onPressed: _verifyPhoneNumber,
                        textStyle: AppStyles.title16Bold,
                        text: translate(AppStrings.verify),
                        borderRadius: 25,
                        colorButton: pinComplete || login
                            ? ColorManager.primary
                            : ColorManager.primaryLight.withValues(alpha: .5),
                        colorBorder: pinComplete || login
                            ? ColorManager.primary
                            : ColorManager.primaryLight.withValues(alpha: .05),
                      ),
                      SizedBox(
                        height: AppSize.s40.h,
                      ),
                      if (state is OTPCodeIsInvalidState)
                        Text(
                          translate(AppStrings.codeIsInvalid),
                          style: AppStyles.title16Regular
                              .copyWith(color: ColorManager.red),
                        )
                    ],
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
