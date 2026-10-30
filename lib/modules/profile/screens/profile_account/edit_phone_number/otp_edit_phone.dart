import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_auth_scaffold.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Auth/widgets/pin_code.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/blocs/update_phone/update_phone_bloc.dart';
import 'package:thewasher/modules/profile/blocs/update_profile/update_profile_bloc.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/utilties/navigator.dart';

class OtpEditPhoneScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  const OtpEditPhoneScreen({
    super.key,
    required this.phone,
    required this.verificationId,
  });

  @override
  State<OtpEditPhoneScreen> createState() => _OtpEditPhoneScreenState();
}

class _OtpEditPhoneScreenState extends State<OtpEditPhoneScreen> {
  late TextEditingController textEditingController;
  final GlobalKey<FormState> pinKey = GlobalKey<FormState>();
  bool pinComplete = false;
  late String otpCode = "";
  late UpdateProfileBloc updateProfileBloc;
  late final CountdownTimerController countdownTimerController;
  late UpdatePhoneBloc updatePhoneBloc;

  @override
  void initState() {
    super.initState();
    updateProfileBloc = BlocProvider.of<UpdateProfileBloc>(context);
    textEditingController = TextEditingController();
    countdownTimerController = CountdownTimerController(
      endTime: DateTime.now()
          .add(const Duration(seconds: 120))
          .millisecondsSinceEpoch,
    )..addListener(() {
        setState(() {});
      });

    updatePhoneBloc = UpdatePhoneBloc()
      ..stream.listen((UpdatePhoneState updateState) {
        if (updateState is UpdatePhoneSuccess) {
          if (!mounted) return;
          showSnackBar(
              buildContext: context,
              message: translate(AppStrings.updatedSuccessfully));
          if (!mounted) return;
          BlocProvider.of<GetUserProfileBloc>(context)
              .add(GetUserProfileEvent());
          if (!mounted) return;
          pop(context);
        } else if (updateState is UpdatePhoneFailed) {
          if (!mounted) return;
          showSnackBar(
            buildContext: context,
            message: Localizations.localeOf(context).countryCode == 'ar'
                ? updateState.error!.ar!
                : updateState.error!.en!,
          );
        }
      });
  }

  @override
  void dispose() {
    countdownTimerController.dispose();
    super.dispose();
  }

  String _mmss(CurrentRemainingTime t) =>
      '${(t.min ?? 0).toString().padLeft(2, '0')}:${(t.sec ?? 0).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final bool locked = countdownTimerController.isRunning;
    return PopScope(
      canPop: !locked,
      child: KAuthScaffold(
        title: translate(AppStrings.verifyCodeTitle),
        // The phone number is isolated so it stays left-to-right in Arabic.
        subtitle:
            '${translate(AppStrings.verifyCodeSubtitle)} \u2066${widget.phone}\u2069',
        showBack: !locked,
        onBack: () => pop(context),
        // TODO(kleano): verifying the new number is not wired to the API yet
        // (unchanged from before the redesign).
        primaryAction: KButton(
          label: translate(AppStrings.verify),
          onPressed: pinComplete ? () {} : null,
        ),
        secondaryAction: CountdownTimer(
          controller: countdownTimerController,
          widgetBuilder:
              (BuildContext context, CurrentRemainingTime? remaining) {
            return KButton(
              variant: KButtonVariant.text,
              label: remaining == null
                  ? translate(AppStrings.resendCode)
                  : '${translate(AppStrings.resendCodeIn)} ${_mmss(remaining)}',
              onPressed: remaining == null ? () {} : null,
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
      ),
    );
  }
}
