import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/core/design/components/k_auth_scaffold.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/phone_auth/phone_number_verification_cubit.dart';
import 'package:thewhsherbiker/modules/Auth/screens/update_password.dart';
import 'package:thewhsherbiker/modules/Auth/widget/pin_code.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
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
    phoneNumberVerificationCubit =
        BlocProvider.of<PhoneNumberVerificationCubit>(context);
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

  String _mmss(CurrentRemainingTime t) {
    final int min = t.min ?? 0;
    final int sec = t.sec ?? 0;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      PhoneNumberVerificationCubit,
      PhoneNumberVerificationState
    >(
      bloc: phoneNumberVerificationCubit,
      listener: (context, PhoneNumberVerificationState state) {
        if (state is PhoneNumberVerifiedSuccessfullyState) {
          fcmToken = state.fcmToken;
          log('----FCM token--: ${state.fcmToken}');
          AppShared.setFcmValue(state.fcmToken);
          pushPage(context, UpdatePassword(profile: false));
          debugPrint("hello");
        } else if (state is PhoneNumberVerificationUnknownErrorState) {
          showSnackBar(buildContext: context, message: state.error!);
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
      builder: (BuildContext context, PhoneNumberVerificationState state) {
        final bool verifying =
            state is VerifyPhoneNumberLoadingState ||
            state is PhoneNumberVerifiedSuccessfullyState;
        return KAuthScaffold(
          title: translate(AppStrings.verifyCodeTitle),
          // The phone number is isolated so it stays left-to-right in Arabic.
          subtitle:
              '${translate(AppStrings.verifyCodeSubtitle)} \u2066${widget.phone}\u2069',
          badge: translate(AppStrings.badgeBiker),
          showBack: true,
          onBack: () => pop(context),
          primaryAction: KButton(
            label: translate(AppStrings.verify),
            loading: verifying,
            onPressed: pinComplete ? _verifyPhoneNumber : null,
          ),
          secondaryAction: CountdownTimer(
            controller: countdownTimerController,
            widgetBuilder: (BuildContext context, CurrentRemainingTime? remaining) {
              return KButton(
                variant: KButtonVariant.text,
                label: remaining == null
                    ? translate(AppStrings.resendCode)
                    : '${translate(AppStrings.receiveTheCodeResendAfter)} ${_mmss(remaining)}',
                onPressed: remaining == null
                    ? () => phoneNumberVerificationCubit.resendOTPRequest(
                        phoneNumber: widget.phone,
                      )
                    : null,
              );
            },
          ),
          children: <Widget>[
            Form(
              key: pinKey,
              child: PinCodeWidget(
                codeController: textEditingController,
                onCompleted: (String v) {
                  setState(() {
                    pinComplete = true;
                    otpCode = v;
                  });
                },
              ),
            ),
            if (state is OTPCodeIsInvalidState) ...<Widget>[
              const SizedBox(height: KSpace.m),
              Text(
                translate(AppStrings.codeIsInvalid),
                textAlign: TextAlign.center,
                style: KType.footnote.copyWith(
                  color: KColors.of(context).error,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
