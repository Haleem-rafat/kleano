import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/constant_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/phone_auth/phone_number_verification_cubit.dart';
import 'package:thewhsherbiker/modules/Auth/screens/otp_screen.dart';
import 'package:thewhsherbiker/shared/components/arrow_back.dart';
import 'package:thewhsherbiker/shared/components/buttons.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/components/test-screen.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';
import 'package:thewhsherbiker/utilties/validator.dart';

class PhoneNumberScreen extends StatefulWidget {
  PhoneNumberScreen({Key? key}) : super(key: key);

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
      sl<AuthBloc>().add(BikerCheckPhone(
        phoneNumber: countryCode == null
            ? "${AppConstants.codeEgypt}${phoneController.text}"
            : "${countryCode!.dialCode}${phoneController.text}",
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size(AppSize.s375, 60.h),
          child: AppBar(
            systemOverlayStyle:
                AppStyles.darkStatusBarIconsWithTransparentColorStyle,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(
              color: ColorManager.white,
            ),
            leading: InkWell(
              onTap: () {
                pop(context);
              },
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: const ArrowBackShared()),
            ),
          )),
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
              child: Form(
                key: _loginFormKey,
                child: ListTileTextForm(
                  validator: validatorPhone,
                  obscure: false,
                  title: translate(AppStrings.phoneNumber),
                  hintText: translate(AppStrings.enterPhoneNumber),
                  textInputType: TextInputType.phone,
                  controller: phoneController,
                  textInputFormatter: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  prefix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: InkWell(
                            onTap: _selectCountryCode,
                            child: Row(
                              children: <Widget>[
                                countryCode != null
                                    ? Text(
                                        "(${countryCode!.dialCode}) ",
                                        style: AppStyles.title16Regular
                                            .copyWith(
                                                color: ColorManager.darkGrey),
                                      )
                                    : Text(
                                        "(${AppConstants.codeEgypt}) ",
                                        style: AppStyles.title16Regular
                                            .copyWith(
                                                color: ColorManager.darkGrey),
                                      ),
                                SvgPicture.asset(ImageAssets.arrowLogo),
                              ],
                            )),
                      ),
                      Container(
                        height: 23.h,
                        width: 1.w,
                        color: ColorManager.medGray,
                        margin: const EdgeInsets.only(top: 2),
                      ),
                      SizedBox(
                        width: 5.w,
                      )
                    ],
                  ),
                ),
              )),
          Spacer(),
          BlocConsumer<PhoneNumberVerificationCubit,
              PhoneNumberVerificationState>(
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
                    ));
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
              } else if (state
                  is PhoneNumberHasBeenBlockedForTooManyRequestsState) {
                pop(context);
                showSnackBar(
                  buildContext: context,
                  message:
                      translate("PhoneNumberHasBeenBlockedForTooManyRequests"),
                );
              } else if (state is RequestOTPUnknownErrorState) {
                pop(context);
                showSnackBar(
                  buildContext: context,
                  message: state.error!,
                );
              }
            },
            builder: (context, state) {
              return BlocConsumer<AuthBloc, AuthState>(
                bloc: sl<AuthBloc>(),
                listener: (context, state) {
                  if (state is BikerCheckPhoneFailed) {
                    showSnackBar(
                      buildContext: context,
                      message: state.error,
                    );
                  }
                  if (state is BikerCheckPhoneSuccess) {
                    phoneNumberVerificationCubit.requestOTP(
                      phoneNumber: countryCode == null
                          ? "${AppConstants.codeEgypt}${phoneController.text}"
                          : "${countryCode!.dialCode}${phoneController.text}",
                    );
                  }
                },
                builder: (context, state) {
                  if (state is BikerCheckPhoneLoading) {
                    return LoadingWidget();
                  } else if (state is BikerCheckPhoneSuccess) {
                    return LoadingWidget();
                  } else {
                    return Center(
                      child: ButtonsShared(
                        onPressed: _resetPassword,
                        borderRadius: 8,
                        text: translate(AppStrings.resetPassword),
                        textStyle: AppStyles.title16Bold,
                      ),
                    );
                  }
                },
              );
            },
          ),
          SizedBox(
            height: AppSize.s24.h,
          )
        ],
      ),
    );
  }
}
