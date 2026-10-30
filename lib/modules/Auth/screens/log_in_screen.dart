import 'dart:math' as math;
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
import 'package:thewasher/layout/main_navigation_screen.dart';
import 'package:thewasher/modules/Auth/cubit/auth_cubit.dart';
import 'package:thewasher/modules/Auth/cubit/auth_state.dart';
import 'package:thewasher/modules/Auth/screens/otp_screen.dart';
import 'package:thewasher/modules/Home/widget/offer_widget.dart';
import 'package:thewasher/modules/splash/address_check_screen.dart';
import 'package:thewasher/shared/components/buttons.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/shared/components/list_tile_text_form.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:thewasher/utilties/navigator.dart';
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
    try {
      await FirebaseMessaging.instance.requestPermission();

      // Try to get FCM token directly first
      fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        print("✅ FCM Token: $fcmToken");
        return;
      }

      // If direct token fetch fails, try with APNs token
      String? apnsToken;
      int retries = 0;

      while (apnsToken == null && retries < 10) {
        await Future.delayed(const Duration(seconds: 1));
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
        retries++;
      }

      if (apnsToken != null) {
        fcmToken = await FirebaseMessaging.instance.getToken();
        print("✅ FCM Token (after APNs): $fcmToken");
      } else {
        print("❌ Failed to get APNs token after $retries seconds.");
        // Try one more time to get FCM token without APNs
        fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          print("✅ FCM Token (fallback): $fcmToken");
        } else {
          print("❌ Failed to get FCM token completely.");
        }
      }
    } catch (e) {
      print("🔥 Error initializing FCM: $e");
      // Try one final attempt to get token
      try {
        fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          print("✅ FCM Token (error recovery): $fcmToken");
        }
      } catch (e2) {
        print("🔥 Final FCM token attempt failed: $e2");
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.darkStatusBarIconsWithTransparentColorStyle,
      child: GestureDetector(
        onTap: () {
          phoneFocusNode.unfocus();
        },
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: AppSize.s60.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          onPressed: () => pop(context),
                          icon: Icon(
                            Icons.arrow_back_ios,
                            size: AppSize.s24.r,
                            color: ColorManager.primary,
                          ),
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
                                ),
                              ),
                      ],
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
                      child: SizedBox(
                        child: Image.asset(AssetsManager.logoN),
                      ),
                    ),
                    32.verticalSpace,
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
                      child: Text(
                        translate(AppStrings.login),
                        style: AppStyles.title24Bold.copyWith(
                          color: ColorManager.black,
                        ),
                      ),
                    ),
                    // ElevatedButton(
                    //     onPressed: () {
                    //       pushPage(
                    //           context,
                    //           OtpScreen(
                    //             fcmToken: "test",
                    //             isSignup: false,
                    //             phone: "+201202939672",
                    //           ));
                    //     },
                    //     child: Text("otp")),
                    SizedBox(height: AppSize.s8.h),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
                      child: Text(
                        translate(AppStrings.helloAgain),
                        style: AppStyles.titleGray16Regular,
                      ),
                    ),
                    SizedBox(height: AppSize.s60.h),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
                      child: Form(
                        key: _loginFormKey,
                        child: ListTileTextForm(
                          focusNode: phoneFocusNode,
                          validator: validatorPhone,
                          title: translate(AppStrings.phoneNumber),
                          hintText: '533720654',
                          textInputType: TextInputType.phone,
                          controller: loginController,
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
                                        style:
                                            AppStyles.title16Regular.copyWith(
                                          color: ColorManager.darkGrey,
                                        ),
                                      ),
                                      SvgPicture.asset(AssetsManager.arrowLogo),
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
                              SizedBox(width: 5.w),
                            ],
                          ),
                        ),
                      ),
                    ),
                    32.verticalSpace,
                    Center(
                      child: BlocConsumer<AuthCubit, AuthState>(
                        listener: (context, state) async {
                          if (state.sendOTPStatus == RequestStatus.loaded) {
                            setState(() {
                              islLoading = false;
                            });

                            try {
                              final AppsFlyerOptions options = AppsFlyerOptions(
                                afDevKey: "vTBNf24bS4fxnsgxuRE7nK",
                                appId: "6744847373",
                                showDebug: true,
                              );
                              final AppsflyerSdk appsFlyerSdk =
                                  AppsflyerSdk(options);
                              await appsFlyerSdk.initSdk();
                              await appsFlyerSdk.logEvent('af_login', {});
                              print("✅ af_login event sent to AppsFlyer");
                            } catch (e) {
                              print("❌ Error sending af_login event: $e");
                            }

                            // Navigate to OTP screen and replace the login screen to avoid duplicate pushes
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (BuildContext context) => OtpScreen(
                                  isSignup: false,
                                  phone: countryCode == null
                                      ? "${AppConstants.codeSaudiArabia}${loginController.text}"
                                      : "${countryCode!.dialCode}${loginController.text}",
                                  fcmToken: fcmToken ??
                                      "Notifications is Unaccessible",
                                ),
                              ),
                            );
                          } else if (state.sendOTPStatus ==
                              RequestStatus.failure) {
                            setState(() {
                              islLoading = false;
                            });
                            showSnackBar(
                              buildContext: context,
                              message: state.sendOTPErrorMessage ??
                                  'Something went wrong. Please try again.',
                              icon: Icons.error_outline,
                              backgroundColor: ColorManager.red,
                            );
                          }
                        },
                        builder: (context, state) {
                          return ButtonsShared(
                            onPressed: () async {
                              if (_loginFormKey.currentState!.validate()) {
                                context.read<AuthCubit>().sendOTP(
                                      phone: countryCode == null
                                          ? "${AppConstants.codeSaudiArabia}${loginController.text}"
                                          : "${countryCode!.dialCode}${loginController.text}",
                                    );
                              }
                            },
                            text: islLoading
                                ? "Logging in..."
                                : translate(AppStrings.login),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
