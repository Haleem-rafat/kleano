import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:thewasher/core/services/fcm_token.dart';
import 'package:flutter/material.dart';
import 'package:thewasher/core/design/components/k_auth_scaffold.dart';
import 'package:thewasher/core/design/components/k_button.dart';
import 'package:thewasher/core/design/components/k_text_field.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/enums/status.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/Auth/cubit/auth_cubit.dart';
import 'package:thewasher/modules/Auth/cubit/auth_state.dart';
import 'package:thewasher/modules/Auth/screens/otp_screen.dart';
import 'package:thewasher/modules/about_us/screens/terms_and_conditions.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:thewasher/utilties/navigator.dart';
import 'package:thewasher/utilties/phone_number.dart';
import 'package:thewasher/utilties/validator.dart';
import 'package:thewasher/core/services/appsflyer_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  CountryCode? countryCode;
  bool isChecked = false;
  bool isLoading = false;
  final _signUpFormKey = GlobalKey<FormState>();
  final FlCountryCodePicker countryPicker = const FlCountryCodePicker();
  late FocusNode phoneFocusNode;
  late FocusNode nameFocusNode;
  late FocusNode emailFocusNode;
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    phoneFocusNode = FocusNode();
    nameFocusNode = FocusNode();
    emailFocusNode = FocusNode();

    _initializeFCM();
  }

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneFocusNode.dispose();
    nameFocusNode.dispose();
    emailFocusNode.dispose();
    super.dispose();
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
        input: phoneController.text,
      );

  void _submit() {
    if (!_signUpFormKey.currentState!.validate()) return;
    if (!isChecked) {
      showSnackBar(
        buildContext: context,
        message: translate(AppStrings.acceptTermsFirst),
      );
      return;
    }
    context.read<AuthCubit>().signup(
      userName: nameController.text,
      phone: _fullPhone(),
      email: emailController.text.isEmpty ? null : emailController.text,
      fcmToken: fcmToken ?? 'Notifications is Unaccessible',
    );
    isGuestUser = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state.signUpStatus == RequestStatus.loaded) {
          AppsFlyerService.logEvent("af_sign_up");
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => OtpScreen(
                isSignup: true,
                phone: _fullPhone(),
                fcmToken: fcmToken ?? "Notifications is Unaccessible",
              ),
            ),
          );
        } else if (state.signUpStatus == RequestStatus.failure) {
          showSnackBar(
            buildContext: context,
            message:
                state.signUpErrorMessage ?? translate('somethingWentWrong'),
            icon: Icons.error_outline,
            backgroundColor: KColors.of(context).error,
          );
        }
      },
      builder: (BuildContext context, AuthState state) {
        return Form(
          key: _signUpFormKey,
          child: KAuthScaffold(
            title: translate(AppStrings.createAccount),
            subtitle: translate(AppStrings.createAccountSubtitle),
            showBack: true,
            onBack: () => pop(context),
            primaryAction: KButton(
              label: translate(AppStrings.signUp),
              loading: state.signUpStatus == RequestStatus.loading,
              onPressed: _submit,
            ),
            children: <Widget>[
              AutofillGroup(
                child: Column(
                  children: <Widget>[
                    KTextField(
                      label: translate(AppStrings.name),
                      controller: nameController,
                      focusNode: nameFocusNode,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.name],
                      validator: validatorName,
                    ),
                    const SizedBox(height: KSpace.m),
                    KTextField(
                      label: translate(AppStrings.email),
                      hint: AppConstants.hintEmail,
                      controller: emailController,
                      focusNode: emailFocusNode,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.email],
                      validator: validatorEmail,
                    ),
                    const SizedBox(height: KSpace.m),
                    KTextField(
                      label: translate(AppStrings.phoneNumber),
                      controller: phoneController,
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
              ),
              const SizedBox(height: KSpace.s),
              CheckboxListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: isChecked,
                onChanged: (bool? v) => setState(() => isChecked = v ?? false),
                title: Text(translate(AppStrings.acceptTerms)),
              ),
              KButton(
                label: translate(AppStrings.termsConditions),
                variant: KButtonVariant.text,
                onPressed: () =>
                    pushPage(context, const TermsAndConditionsScreen()),
              ),
            ],
          ),
        );
      },
    );
  }
}
