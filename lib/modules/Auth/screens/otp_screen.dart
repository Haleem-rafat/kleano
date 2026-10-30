import 'package:flutter/material.dart';
import 'package:thewasher/core/design/components/k_auth_scaffold.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/enums/status.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Auth/cubit/auth_cubit.dart';
import 'package:thewasher/modules/Auth/cubit/auth_state.dart';
import 'package:thewasher/modules/Auth/widgets/pin_code.dart';
import 'package:thewasher/modules/splash/address_check_screen.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/navigator.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String fcmToken;
  final bool isSignup;

  const OtpScreen({
    super.key,
    required this.phone,
    required this.fcmToken,
    required this.isSignup,
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

  String _mmss(CurrentRemainingTime t) =>
      '${(t.min ?? 0).toString().padLeft(2, '0')}:${(t.sec ?? 0).toString().padLeft(2, '0')}';

  void _verify() {
    if (!(pinComplete && otpCode.isNotEmpty)) return;
    widget.isSignup
        ? context.read<AuthCubit>().verifySignupOTP(
            phone: widget.phone,
            otp: otpCode,
          )
        : context.read<AuthCubit>().login(
            phone: widget.phone,
            fcmToken: widget.fcmToken,
            otp: otpCode,
          );
  }

  void _resend() {
    widget.isSignup
        ? context.read<AuthCubit>().resendRegisterOTP(phone: widget.phone)
        : context.read<AuthCubit>().sendOTP(phone: widget.phone);
    setState(() {
      countdownTimerController.endTime = DateTime.now()
          .add(const Duration(seconds: 120))
          .millisecondsSinceEpoch;
      countdownTimerController.start();
    });
    showSnackBar(
      buildContext: context,
      message: Localizations.localeOf(context).languageCode == 'ar'
          ? 'تم إرسال رمز التحقق بنجاح'
          : 'Verification code sent',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.loginStatus == RequestStatus.loaded ||
            state.verifyOTPStatus == RequestStatus.loaded) {
          popALlAndPushPage(context, const AddressCheckScreen());
        } else if (state.loginStatus == RequestStatus.failure ||
            state.verifyOTPStatus == RequestStatus.failure) {
          showSnackBar(
            buildContext: context,
            message:
                state.loginErrorMessage ??
                state.verifyOTPErrorMessage ??
                (Localizations.localeOf(context).languageCode == 'ar'
                    ? 'الرمز غير صحيح'
                    : 'Incorrect code'),
            icon: Icons.error_outline,
            backgroundColor: KColors.of(context).error,
          );
        } else if (state.sendOTPStatus == RequestStatus.failure) {
          showSnackBar(
            buildContext: context,
            message:
                state.sendOTPErrorMessage ??
                (Localizations.localeOf(context).languageCode == 'ar'
                    ? 'حدث خطأ ما. حاول مرة أخرى.'
                    : 'Something went wrong. Please try again.'),
            icon: Icons.error_outline,
            backgroundColor: KColors.of(context).error,
          );
        }
      },
      builder: (BuildContext context, AuthState state) {
        return KAuthScaffold(
          title: translate(AppStrings.verifyCodeTitle),
          // The phone number is isolated so it stays left-to-right in Arabic.
          subtitle:
              '${translate(AppStrings.verifyCodeSubtitle)} \u2066${widget.phone}\u2069',
          showBack: true,
          onBack: () => pop(context),
          primaryAction: KButton(
            label: translate(AppStrings.verify),
            loading:
                state.loginStatus == RequestStatus.loading ||
                state.verifyOTPStatus == RequestStatus.loading,
            onPressed: pinComplete ? _verify : null,
          ),
          secondaryAction: CountdownTimer(
            controller: countdownTimerController,
            widgetBuilder: (BuildContext context, CurrentRemainingTime? remaining) {
              // Resend only once the timer has finished (no SMS spam).
              return KButton(
                variant: KButtonVariant.text,
                label: remaining == null
                    ? translate(AppStrings.resendCode)
                    : '${translate(AppStrings.resendCodeIn)} ${_mmss(remaining)}',
                onPressed: remaining == null ? _resend : null,
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
          ],
        );
      },
    );
  }
}
