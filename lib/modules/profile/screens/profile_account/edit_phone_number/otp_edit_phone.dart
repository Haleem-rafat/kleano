import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/modules/Auth/widgets/pin_code.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/assets_manager.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/blocs/update_phone/update_phone_bloc.dart';
import 'package:thewasher/modules/profile/blocs/update_profile/update_profile_bloc.dart';
import 'package:thewasher/shared/components/buttons.dart';
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
  CountryCode? countryCode;
  bool login = false;
  late UpdateProfileBloc updateProfileBloc;
  String fcmToken = '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle:
            AppStyles.darkStatusBarIconsWithTransparentColorStyle,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: ColorManager.primary,
        ),
        leading: !countdownTimerController.isRunning
            ? GestureDetector(
                onTap: () => pop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  size: 24,
                ),
              )
            : null,
      ),
      body: PopScope(
        canPop: !countdownTimerController.isRunning,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Localizations.localeOf(context).languageCode == "en"
                      ? SvgPicture.asset(AssetsManager.logoImg)
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: SvgPicture.asset(AssetsManager.logoImg),
                        )
                ],
              ),
              Text(translate("verification"),
                  style: AppStyles.title24Bold
                      .copyWith(color: ColorManager.darkGrey)),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    55.w, AppSize.s12.h, 55.w, AppSize.s54.h),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: translate("sentVerificationCode"),
                    style: AppStyles.title16Regular.copyWith(
                      color: ColorManager.darkGrey,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: " ${widget.phone}",
                        style: AppStyles.title16Regular.copyWith(
                          color: ColorManager.darkGrey,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Form(
                key: pinKey,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.h, horizontal: 30.w),
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
              ),
              AppSize.s40.ph,
              Column(
                children: [
                  AppPadding.p18.ph,
                  CountdownTimer(
                    controller: countdownTimerController,
                    widgetBuilder: (BuildContext context,
                        CurrentRemainingTime? currentRemainingTime) {
                      return InkWell(
                        onTap: currentRemainingTime == null ? () {} : null,
                        child: currentRemainingTime != null
                            ? Text(
                                "${translate('ReceiveTheCode?ResendAfter')} 0${currentRemainingTime.min ?? '0'}:${currentRemainingTime.sec != null ? currentRemainingTime.sec! < 10 ? '0${currentRemainingTime.sec}' : currentRemainingTime.sec : ''}",
                                style: AppStyles.title16Regular.copyWith(
                                  color: ColorManager.darkGrey,
                                ),
                              )
                            : RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: translate("DidReceiveCode"),
                                  style: AppStyles.title16Regular.copyWith(
                                    color: ColorManager.darkGrey,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: translate("resendCode"),
                                      style: AppStyles.title16Regular.copyWith(
                                        color: ColorManager.darkGrey,
                                        decoration: TextDecoration.underline,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
                  AppSize.s40.ph,
                  ButtonsShared(
                    onPressed: () {},
                    text: translate("verify"),
                    colorButton: pinComplete || login
                        ? ColorManager.primary
                        : ColorManager.primaryLight.withValues(alpha: .5),
                    colorBorder: pinComplete || login
                        ? ColorManager.primary
                        : ColorManager.primaryLight.withValues(alpha: .05),
                  ),
                  AppSize.s40.ph,
                  Text(
                    translate(AppStrings.codeIsInvalid),
                    style: AppStyles.title16Regular
                        .copyWith(color: ColorManager.red),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
