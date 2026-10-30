// import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Auth/screens/phone_number.dart';
import 'package:thewhsherbiker/modules/Home/screens/home_screen.dart';
import 'package:thewhsherbiker/modules/notification/helpers/notification_helper.dart';
import 'package:thewhsherbiker/shared/components/buttons.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';
import 'package:thewhsherbiker/utilties/validator.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passWordController = TextEditingController();

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  bool isChecked = false;
  bool _showPassword = false;

  Future<void> checkFirstSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('FirstTime')) {
      prefs.setBool('FirstTime', true);
    }
  }

  @override
  void initState() {
    checkFirstSeen();
    _initializeNotifications();
    super.initState();
  }

  Future<void> _initializeNotifications() async {
    try {
      // Initialize notification service to get FCM token ready for login
      await NotificationHelper.initialize(context);
      debugPrint('✅ Notifications initialized in login screen');
    } catch (e) {
      debugPrint('⚠️ Error initializing notifications: $e');
      // Don't block login if notification initialization fails
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    passWordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loginFormKey.currentState!.validate()) {
      if (isChecked) {
        TextInput.finishAutofillContext();
      }
      sl<AuthBloc>().add(BikerLogin(
        context: context,
        userName: nameController.text,
        passWord: passWordController.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: AppStyles.darkStatusBarIconsWithTransparentColorStyle,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                20.verticalSpace,
                Align(
                  alignment:
                      Localizations.localeOf(context).languageCode == 'ar'
                          ? Alignment.topLeft
                          : Alignment.topRight,
                  child: SvgPicture.asset(
                    ImageAssets.animateRegister,
                    width: 132.w,
                    height: 174.h,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        ImageAssets.logoN,
                      ),
                      SizedBox(
                        height: AppSize.s47.h,
                      ),
                      Text(
                        translate(AppStrings.login),
                        style: AppStyles.title24Bold.copyWith(
                          color: ColorManager.darkGrey,
                        ),
                      ),
                      SizedBox(
                        height: AppSize.s8.h,
                      ),
                      Text(translate(AppStrings.helloAgain),
                          style: AppStyles.titleGray16Regular),
                      SizedBox(
                        height: AppSize.s28.h,
                      ),
                      Form(
                        key: _loginFormKey,
                        child: AutofillGroup(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p16.w,
                                    vertical: 8.h),
                                child: Text(
                                  translate(AppStrings.name),
                                  style: AppStyles.title16Regular
                                      .copyWith(color: ColorManager.darkGrey),
                                ),
                              ),
                              TextFormField(
                                textInputAction: TextInputAction.next,
                                autofillHints: [AutofillHints.email],
                                validator: validatorName,
                                keyboardType: TextInputType.name,
                                controller: nameController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: AppPadding.p16.w,
                                      vertical: AppPadding.p18.h),
                                  hintText: translate(AppStrings.username),
                                  hintStyle: AppStyles.titleGray16Regular,
                                  border: OutlineInputBorder(
                                    gapPadding: 0,
                                    borderSide: BorderSide(
                                      color: ColorManager.medGray,
                                    ),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    gapPadding: 0,
                                    borderSide: const BorderSide(
                                      color: ColorManager.red,
                                    ),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    gapPadding: 0,
                                    borderSide: BorderSide(
                                      color: ColorManager.secondary,
                                    ),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p16.w,
                                    vertical: 8.h),
                                child: Text(
                                  translate(AppStrings.password),
                                  style: AppStyles.title16Regular
                                      .copyWith(color: ColorManager.darkGrey),
                                ),
                              ),
                              TextFormField(
                                autofillHints: [AutofillHints.password],
                                validator: validatorPassword,
                                obscureText: _showPassword,
                                keyboardType: TextInputType.text,
                                controller: passWordController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: AppPadding.p16.w,
                                      vertical: AppPadding.p18.h),
                                  hintText: translate(AppStrings.password),
                                  hintStyle: AppStyles.titleGray16Regular,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: ColorManager.medGray,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    gapPadding: 0,
                                    borderSide: BorderSide(
                                      color: ColorManager.medGray,
                                    ),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    gapPadding: 0,
                                    borderSide: const BorderSide(
                                      color: ColorManager.red,
                                    ),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    gapPadding: 0,
                                    borderSide: BorderSide(
                                      color: ColorManager.secondary,
                                    ),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppSize.s8.h,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 24.w,
                            height: 24.h,
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
                          SizedBox(
                            width: 6.w,
                          ),
                          SizedBox(
                            width: 273.w,
                            child: Text(
                              translate(AppStrings.rememberPassword),
                              style: AppStyles.titleGray16Regular,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSize.s60.h,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    pushPage(context, PhoneNumberScreen());
                  },
                  child: Center(
                    child: Text(
                      translate(AppStrings.forgetPassword),
                      style: AppStyles.title16Regular.copyWith(
                        color: ColorManager.darkGrey,
                        decoration: TextDecoration.underline,
                        decorationColor: ColorManager.darkGrey,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: AppSize.s28.h,
                ),
                BlocConsumer<AuthBloc, AuthState>(
                  bloc: sl<AuthBloc>(),
                  listener: (BuildContext context, AuthState state) {
                    if (state is BikerLoginFailed) {
                      showSnackBar(
                        buildContext: context,
                        message: state.error,
                      );
                    } else if (state is BikerLoginSuccess) {
                      sl<AuthBloc>().getUserLocation().whenComplete(() {
                        if (!context.mounted) return;
                        popALlAndPushPage(
                            context,
                            HomeScreen(
                              initialIndex: 0,
                            ));
                      });
                    }
                  },
                  builder: (BuildContext context, AuthState state) {
                    if (state is BikerLoginLoading) {
                      return Center(
                        child: LoadingWidget(),
                      );
                    } else {
                      return Center(
                        child: ButtonsShared(
                          onPressed: _login,
                          text: translate(AppStrings.login),
                          borderRadius: 8,
                          textStyle: AppStyles.title16Bold,
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: AppSize.s24.h,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
