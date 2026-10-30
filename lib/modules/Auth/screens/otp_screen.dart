import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/enums/status.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Auth/cubit/auth_cubit.dart';
import 'package:thewasher/modules/Auth/cubit/auth_state.dart';
import 'package:thewasher/modules/Auth/widgets/pin_code.dart';
import 'package:thewasher/modules/splash/address_check_screen.dart';
import 'package:thewasher/shared/components/arrow_back.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String fcmToken;
  final bool isSignup;

  const OtpScreen(
      {super.key,
      required this.phone,
      required this.fcmToken,
      required this.isSignup});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late TextEditingController textEditingController;
  final GlobalKey<FormState> pinKey = GlobalKey<FormState>();
  bool pinComplete = false;
  late String otpCode = "";
  bool login = false;

  String fcmToken = '';
  late final CountdownTimerController countdownTimerController;
  late GeneralSingleton generalSingleton;

  @override
  void initState() {
    super.initState();
    generalSingleton = GeneralSingleton();
    textEditingController = TextEditingController();

    _timerCounter();
  }

  _timerCounter() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            AppStyles.darkStatusBarIconsWithTransparentColorStyle,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: ColorManager.primary,
        ),
        leading: !countdownTimerController.isRunning
            ? const ArrowBackShared()
            : null,
      ),
      body: WillPopScope(
        onWillPop:
            countdownTimerController.isRunning ? () async => false : null,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Localizations.localeOf(context).languageCode == "en"
                      ? Image.asset(
                          AssetsManager.registerAnimate,
                        )
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Image.asset(
                            AssetsManager.registerAnimate,
                          ),
                        ),
                ],
              ),
              126.verticalSpace,
              Image.asset(AssetsManager.logoN, height: 60.h, width: 60.w),
              40.verticalSpace,
              Text(translate(AppStrings.verification),
                  style: AppStyles.title24Bold
                      .copyWith(color: ColorManager.darkGrey)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    55.w, AppSize.s12.h, 55.w, AppSize.s24.h),
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
              32.verticalSpace,
              Column(
                children: [
                  BlocListener<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state.loginStatus == RequestStatus.loaded ||
                          state.verifyOTPStatus == RequestStatus.loaded) {
                        popALlAndPushPage(context, const AddressCheckScreen());
                      } else if (state.loginStatus == RequestStatus.failure ||
                          state.verifyOTPStatus == RequestStatus.failure) {
                        showSnackBar(
                          buildContext: context,
                          message: state.loginErrorMessage ??
                              state.verifyOTPErrorMessage ??
                              (Localizations.localeOf(context).languageCode ==
                                      'ar'
                                  ? 'الرمز غير صحيح'
                                  : 'Incorrect code'),
                          icon: Icons.error_outline,
                          backgroundColor: ColorManager.red,
                        );
                      } else if (state.sendOTPStatus == RequestStatus.failure) {
                        showSnackBar(
                          buildContext: context,
                          message: state.sendOTPErrorMessage ??
                              (Localizations.localeOf(context).languageCode ==
                                      'ar'
                                  ? 'حدث خطأ ما. حاول مرة أخرى.'
                                  : 'Something went wrong. Please try again.'),
                          icon: Icons.error_outline,
                          backgroundColor: ColorManager.red,
                        );
                      }
                    },
                    child: ButtonsShared(
                      onPressed: () {
                        if (!(pinComplete && otpCode.isNotEmpty)) return;
                        widget.isSignup
                            ? context.read<AuthCubit>().verifySignupOTP(
                                phone: widget.phone, otp: otpCode)
                            : context.read<AuthCubit>().login(
                                phone: widget.phone,
                                fcmToken: widget.fcmToken,
                                otp: otpCode);
                      },
                      text: translate(AppStrings.verify),
                      colorButton: pinComplete || login
                          ? ColorManager.primary
                          : ColorManager.primaryLight.withValues(alpha: .5),
                      colorBorder: pinComplete || login
                          ? ColorManager.primary
                          : ColorManager.primaryLight.withValues(alpha: .05),
                    ),
                  ),
                  24.verticalSpace,
                  CountdownTimer(
                    controller: countdownTimerController,
                    widgetBuilder: (BuildContext context,
                        CurrentRemainingTime? currentRemainingTime) {
                      return InkWell(
                        onTap: () {
                          widget.isSignup
                              ? context
                                  .read<AuthCubit>()
                                  .resendRegisterOTP(phone: widget.phone)
                              : context
                                  .read<AuthCubit>()
                                  .sendOTP(phone: widget.phone);

                          showSnackBar(
                            buildContext: context,
                            message:
                                (Localizations.localeOf(context).languageCode ==
                                        'ar'
                                    ? 'تم إرسال رمز التحقق بنجاح'
                                    : 'OTP sent successfully'),
                            icon: Icons.error_outline,
                            backgroundColor: ColorManager.green,
                          );
                        },
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
                                  text: translate(AppStrings.didReceiveCode),
                                  style: AppStyles.title16Regular.copyWith(
                                    color: ColorManager.darkGrey,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: translate(AppStrings.resendCode),
                                      style: AppStyles.title16Regular.copyWith(
                                        color: ColorManager.primary,
                                        decoration: TextDecoration.underline,
                                        decorationColor: ColorManager.primary,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
                  AppSize.s40.ph,
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
