import 'package:thewasher/core/services/appsflyer_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:thewasher/core/services/fcm_token.dart';
import 'package:flutter/material.dart';
import 'package:thewasher/core/design/components/k_auth_scaffold.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/enums/status.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Auth/cubit/auth_cubit.dart';
import 'package:thewasher/modules/Auth/cubit/auth_state.dart';
import 'package:thewasher/modules/Auth/screens/otp_screen.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/utilties/phone_number.dart';
import 'package:thewasher/utilties/validator.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController loginController = TextEditingController();
  CountryCode? countryCode;
  final FlCountryCodePicker countryPicker = const FlCountryCodePicker();
  final _loginFormKey = GlobalKey<FormState>();
  bool islLoading = false;
  bool login = false;
  int count = 1;
  String? fcmToken;
  late FocusNode phoneFocusNode;

  @override
  void initState() {
    super.initState();
    phoneFocusNode = FocusNode();
    _initializeFCM();
  }

  Future<void> _initializeFCM() async {
    // Push is optional for logging in: never let Firebase errors block it.
    try {
      await FirebaseMessaging.instance.requestPermission();
    } catch (e) {
      debugPrint('Notification permission unavailable: $e');
    }
    fcmToken = await FcmToken.get();
  }

  @override
  void dispose() {
    phoneFocusNode.dispose();
    loginController.dispose();
    super.dispose();
  }

  void _selectCountryCode() async {
    final CountryCode? code = await countryPicker.showPicker(context: context);
    setState(() {
      countryCode = code;
    });
  }

  /// The full international number sent to the backend.
  String _fullPhone() =>
      buildInternationalPhone(
        dialCode: countryCode?.dialCode ?? AppConstants.defaultDialCode,
        input: loginController.text,
      );

  void _submit() {
    if (_loginFormKey.currentState!.validate()) {
      context.read<AuthCubit>().sendOTP(phone: _fullPhone());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state.sendOTPStatus == RequestStatus.loaded) {
          AppsFlyerService.logEvent('af_login');
          // Replace the login screen to avoid duplicate pushes.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => OtpScreen(
                isSignup: false,
                phone: _fullPhone(),
                fcmToken: fcmToken ?? "Notifications is Unaccessible",
              ),
            ),
          );
        } else if (state.sendOTPStatus == RequestStatus.failure) {
          showSnackBar(
            buildContext: context,
            message:
                state.sendOTPErrorMessage ?? translate('somethingWentWrong'),
            icon: Icons.error_outline,
            backgroundColor: KColors.of(context).error,
          );
        }
      },
      builder: (BuildContext context, AuthState state) {
        return Form(
          key: _loginFormKey,
          child: KAuthScaffold(
            title: translate(AppStrings.welcomeBack),
            subtitle: translate(AppStrings.userLoginSubtitle),
            showBack: true,
            onBack: () => pop(context),
            primaryAction: KButton(
              label: translate(AppStrings.login),
              loading: state.sendOTPStatus == RequestStatus.loading,
              onPressed: _submit,
            ),
            children: <Widget>[
              KTextField(
                label: translate(AppStrings.phoneNumber),
                controller: loginController,
                focusNode: phoneFocusNode,
                keyboardType: TextInputType.phone,
                autofillHints: const <String>[
                  AutofillHints.telephoneNumberNational,
                ],
                inputFormatters: <TextInputFormatter>[
                  PhoneDigitsFormatter(),
                ],
                validator: validatorPhone,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                prefix: TextButton(
                  onPressed: _selectCountryCode,
                  child: Text(
                    countryCode?.dialCode ?? AppConstants.defaultDialCode,
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
