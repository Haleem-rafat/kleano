import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Auth/screens/log_in_screen.dart';
import 'package:thewhsherbiker/shared/components/app_bar.dart';
import 'package:thewhsherbiker/shared/components/buttons.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
import 'package:thewhsherbiker/shared/components/test-screen.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';
import 'package:thewhsherbiker/utilties/validator.dart';

class UpdatePassword extends StatefulWidget {
  final bool profile;
  const UpdatePassword({super.key, required this.profile});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  final _updateFormKey = GlobalKey<FormState>();

  void _updatePassword() {
    if (_updateFormKey.currentState!.validate()) {
      if (widget.profile) {
        sl<AuthBloc>().add(BikerUpdatePassword(
          oldPassword: oldPasswordController.text,
          newPassword: passwordController.text,
          context: context,
        ));
      } else {
        sl<AuthBloc>().add(BikerResetPassword(
            newPassword: passwordController.text.trim(),
            token: sl<AuthBloc>().token));
      }
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    rePasswordController.dispose();
    oldPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: AppBarWhiteShared(
          titleText: translate(AppStrings.editPassword),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 33.h,
            ),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
                child: Form(
                  key: _updateFormKey,
                  child: Column(
                    children: <Widget>[
                      Visibility(
                        visible: widget.profile,
                        child: Column(
                          children: <Widget>[
                            ListTileTextForm(
                              validator: validatorPassword,
                              title: translate(AppStrings.oldPassword),
                              obscure: false,
                              hintText: "",
                              textInputType: TextInputType.name,
                              controller: oldPasswordController,
                            ),
                            SizedBox(
                              height: AppSize.s28.h,
                            ),
                          ],
                        ),
                      ),
                      ListTileTextForm(
                        validator: validatorPassword,
                        title: translate(AppStrings.newPassword),
                        obscure: false,
                        hintText: "",
                        textInputType: TextInputType.name,
                        controller: passwordController,
                      ),
                      SizedBox(
                        height: AppSize.s28.h,
                      ),
                      ListTileTextForm(
                        validator: (value) => validatorRePassword(
                          passwordController.text,
                          value,
                        ),
                        obscure: false,
                        title: translate(AppStrings.reEnterNewPassword),
                        hintText: "",
                        textInputType: TextInputType.text,
                        controller: rePasswordController,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
      bottomNavigationBar: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is BikerResetPasswordFailed) {
            showSnackBar(
              buildContext: context,
              message: state.error,
            );
          } else if (state is BikerUpdatePasswordFailed) {
            showSnackBar(
              buildContext: context,
              message: state.error,
            );
          } else if (state is BikerResetPasswordSuccess ||
              state is BikerUpdatePasswordSuccess) {
            widget.profile
                ? pop(context)
                : popALlAndPushPage(context, LogInScreen());
          }
        },
        builder: (context, state) {
          if (state is BikerResetPasswordLoading ||
              state is BikerUpdatePasswordLoading) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
              child: SizedBox(
                height: 50.h,
                child: const LoadingWidget(),
              ),
            );
          } else {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
              child: ButtonsShared(
                onPressed: _updatePassword,
                text: translate(AppStrings.resetPassword),
                borderRadius: 8,
                textStyle: AppStyles.title16Bold,
              ),
            );
          }
        },
      ),
    );
  }
}
