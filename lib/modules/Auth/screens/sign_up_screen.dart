import 'dart:math' as math;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:thewasher/core/services/fcm_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/enums/status.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Auth/cubit/auth_cubit.dart';
import 'package:thewasher/modules/Auth/cubit/auth_state.dart';
import 'package:thewasher/modules/Auth/screens/otp_screen.dart';
import 'package:thewasher/modules/about_us/screens/terms_and_conditions.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/components/list_tile_text_form.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:thewasher/utilties/navigator.dart';
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
    await FirebaseMessaging.instance.requestPermission();
    fcmToken = await FcmToken.get();
  }

  void _selectCountryCode() async {
    final CountryCode? code = await countryPicker.showPicker(context: context);
    setState(() {
      countryCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        phoneFocusNode.unfocus();
        emailFocusNode.unfocus();
        nameFocusNode.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle:
              AppStyles.darkStatusBarIconsWithTransparentColorStyle,
          automaticallyImplyLeading: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 30.h,
          leading: IconButton(
            onPressed: () => pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              size: AppSize.s24.r,
              color: ColorManager.primary,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 50.h),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p24.w),
                          child: SvgPicture.asset(AssetsManager.logo)),
                      SizedBox(height: 37.h),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
                        child: Text(
                          translate(AppStrings.signUp),
                          style: AppStyles.title24Bold.copyWith(
                            color: ColorManager.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Localizations.localeOf(context).languageCode == "en"
                      ? Image.asset(
                          AssetsManager.registerAnimate,
                          width: 132.w,
                          height: 174.h,
                        )
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Image.asset(
                            AssetsManager.registerAnimate,
                            width: 132.w,
                            height: 174.h,
                          ))
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p23.w),
                child: Form(
                  key: _signUpFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ListTileTextForm(
                        focusNode: nameFocusNode,
                        validator: validatorName,
                        title: translate(AppStrings.name),
                        hintText: translate(AppStrings.username),
                        textInputType: TextInputType.name,
                        controller: nameController,
                      ),
                      SizedBox(height: AppSize.s8.h),
                      ListTileTextForm(
                        focusNode: emailFocusNode,
                        isOptional: true,
                        title: translate(AppStrings.email),
                        hintText: AppConstants.hintEmail,
                        textInputType: TextInputType.emailAddress,
                        controller: emailController,
                      ),
                      SizedBox(height: AppSize.s8.h),
                      ListTileTextForm(
                        focusNode: phoneFocusNode,
                        validator: validatorPhone,
                        title: translate(AppStrings.phoneNumber),
                        hintText: '533720654',
                        textInputType: TextInputType.phone,
                        controller: phoneController,
                        textInputFormatter: [
                          FilteringTextInputFormatter.deny(RegExp(r'^0+')),
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
                                    Text(
                                      "(${countryCode?.dialCode ?? AppConstants.codeSaudiArabia}) ",
                                      style: AppStyles.title16Regular
                                          .copyWith(color: ColorManager.black),
                                    ),
                                    SvgPicture.asset(AssetsManager.arrowLogo)
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 23.h,
                              width: 1.w,
                              color: ColorManager.medGray,
                              margin: const EdgeInsets.only(top: 2),
                            ),
                            SizedBox(width: 5.w)
                          ],
                        ),
                      ),
                      SizedBox(height: AppSize.s8.h),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            height: 24.h,
                            width: 24.w,
                            child: Checkbox(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.r)),
                              checkColor: ColorManager.white,
                              activeColor: ColorManager.primary,
                              value: isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isChecked = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 6.w),
                          SizedBox(
                            width: 273.w,
                            child: TextButton(
                              onPressed: () {
                                pushPage(
                                    context, const TermsAndConditionsScreen());
                              },
                              child: Text(
                                translate(AppStrings.termsConditions),
                                style: AppStyles.titleGray16Regular.copyWith(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSize.s28.h),
                      Center(
                        child: BlocConsumer<AuthCubit, AuthState>(
                          listener: (context, state) async {
                            if (state.signUpStatus == RequestStatus.loading) {
                              setState(() => isLoading = true);
                            } else {
                              setState(() => isLoading = false);
                            }

                            if (state.signUpStatus == RequestStatus.loaded) {
                              AppsFlyerService.logEvent("af_sign_up");

                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (BuildContext context) => OtpScreen(
                                    isSignup: true,
                                    phone: countryCode == null
                                        ? "${AppConstants.codeSaudiArabia}${phoneController.text}"
                                        : "${countryCode!.dialCode}${phoneController.text}",
                                    fcmToken: fcmToken ??
                                        "Notifications is Unaccessible",
                                  ),
                                ),
                              );
                            } else if (state.signUpStatus ==
                                RequestStatus.failure) {
                              showSnackBar(
                                buildContext: context,
                                message: state.signUpErrorMessage ??
                                    'Something went wrong. Please try again.',
                                icon: Icons.error_outline,
                                backgroundColor: ColorManager.red,
                              );
                            }
                          },
                          builder: (context, state) {
                            return ButtonsShared(
                              onPressed: () async {
                                if (_signUpFormKey.currentState!.validate() &&
                                    isChecked) {
                                  context.read<AuthCubit>().signup(
                                        userName: nameController.text,
                                        phone: countryCode == null
                                            ? "${AppConstants.codeSaudiArabia}${phoneController.text}"
                                            : "${countryCode!.dialCode}${phoneController.text}",
                                        email: emailController.text.isEmpty
                                            ? null
                                            : emailController.text,
                                        fcmToken: fcmToken ??
                                            'Notifications is Unaccessible',
                                      );
                                }

                                isGuestUser = false;
                              },
                              text: isLoading
                                  ? "Signing up..."
                                  : translate(AppStrings.signUp),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: AppSize.s12.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
