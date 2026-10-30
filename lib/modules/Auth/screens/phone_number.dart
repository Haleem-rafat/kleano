import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/design/components/k_auth_scaffold.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_text_field.dart';
import 'package:thewhsherbiker/core/resources/constant_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/phone_auth/phone_number_verification_cubit.dart';
import 'package:thewhsherbiker/modules/Auth/screens/otp_screen.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';
import 'package:thewhsherbiker/utilties/validator.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  late final PhoneNumberVerificationCubit phoneNumberVerificationCubit;
  TextEditingController phoneController = TextEditingController();
  CountryCode? countryCode;
  final FlCountryCodePicker countryPicker = const FlCountryCodePicker();
  final _loginFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    phoneNumberVerificationCubit =
        BlocProvider.of<PhoneNumberVerificationCubit>(context);
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void _selectCountryCode() async {
    final CountryCode? code = await countryPicker.showPicker(context: context);
    setState(() {
      countryCode = code;
    });
  }

  void _resetPassword() {
    if (_loginFormKey.currentState!.validate()) {
      sl<AuthBloc>().add(
        BikerCheckPhone(
          phoneNumber: countryCode == null
              ? "${AppConstants.codeEgypt}${phoneController.text}"
              : "${countryCode!.dialCode}${phoneController.text}",
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      PhoneNumberVerificationCubit,
      PhoneNumberVerificationState
    >(
      bloc: phoneNumberVerificationCubit,
      listener: (context, state) {
        if (state is AskUserForOTPCodeState) {
          pushPage(
            context,
            OtpScreen(
              phone: countryCode == null
                  ? "${AppConstants.codeEgypt}${phoneController.text}"
                  : "${countryCode!.dialCode}${phoneController.text}",
              verificationId: state.verificationId,
            ),
          );
        } else if (state is PhoneNumberAlreadyExistsState) {
          pop(context);
          showSnackBar(
            buildContext: context,
            message: translate("PhoneNumberAlreadyExists"),
          );
        } else if (state is PhoneNumberIsInvalidState) {
          pop(context);
          showSnackBar(
            buildContext: context,
            message: translate("PhoneNumberIsInvalid"),
          );
        } else if (state is PhoneNumberHasBeenBlockedForTooManyRequestsState) {
          pop(context);
          showSnackBar(
            buildContext: context,
            message: translate("PhoneNumberHasBeenBlockedForTooManyRequests"),
          );
        } else if (state is RequestOTPUnknownErrorState) {
          pop(context);
          showSnackBar(buildContext: context, message: state.error!);
        }
      },
      child: BlocConsumer<AuthBloc, AuthState>(
        bloc: sl<AuthBloc>(),
        listener: (context, state) {
          if (state is BikerCheckPhoneFailed) {
            showSnackBar(buildContext: context, message: state.error);
          }
          if (state is BikerCheckPhoneSuccess) {
            phoneNumberVerificationCubit.requestOTP(
              phoneNumber: countryCode == null
                  ? "${AppConstants.codeEgypt}${phoneController.text}"
                  : "${countryCode!.dialCode}${phoneController.text}",
            );
          }
        },
        builder: (BuildContext context, AuthState state) {
          return Form(
            key: _loginFormKey,
            child: KAuthScaffold(
              title: translate(AppStrings.resetPasswordTitle),
              subtitle: translate(AppStrings.resetPasswordSubtitle),
              badge: translate(AppStrings.badgeBiker),
              showBack: true,
              onBack: () => pop(context),
              primaryAction: KButton(
                label: translate(AppStrings.resetPassword),
                loading:
                    state is BikerCheckPhoneLoading ||
                    state is BikerCheckPhoneSuccess,
                onPressed: _resetPassword,
              ),
              children: <Widget>[
                KTextField(
                  label: translate(AppStrings.phoneNumber),
                  hint: translate(AppStrings.enterPhoneNumber),
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  autofillHints: const <String>[
                    AutofillHints.telephoneNumberNational,
                  ],
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: validatorPhone,
                  onSubmitted: (_) => _resetPassword(),
                  prefix: TextButton(
                    onPressed: _selectCountryCode,
                    child: Text(
                      countryCode?.dialCode ?? AppConstants.codeEgypt,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
