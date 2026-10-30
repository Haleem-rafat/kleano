import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/design/components/k_auth_scaffold.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_text_field.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Auth/screens/log_in_screen.dart';
import 'package:thewhsherbiker/shared/components/snack_bar.dart';
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
        sl<AuthBloc>().add(
          BikerUpdatePassword(
            oldPassword: oldPasswordController.text,
            newPassword: passwordController.text,
            context: context,
          ),
        );
      } else {
        sl<AuthBloc>().add(
          BikerResetPassword(
            newPassword: passwordController.text.trim(),
            token: sl<AuthBloc>().token,
          ),
        );
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
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: sl<AuthBloc>(),
      listener: (BuildContext context, AuthState state) {
        if (state is BikerResetPasswordFailed) {
          showSnackBar(buildContext: context, message: state.error);
        } else if (state is BikerUpdatePasswordFailed) {
          showSnackBar(buildContext: context, message: state.error);
        } else if (state is BikerResetPasswordSuccess ||
            state is BikerUpdatePasswordSuccess) {
          widget.profile
              ? pop(context)
              : popALlAndPushPage(context, LogInScreen());
        }
      },
      builder: (BuildContext context, AuthState state) {
        return Form(
          key: _updateFormKey,
          child: KAuthScaffold(
            title: translate(
              widget.profile
                  ? AppStrings.editPassword
                  : AppStrings.newPasswordTitle,
            ),
            subtitle: translate(AppStrings.newPasswordSubtitle),
            badge: translate(AppStrings.badgeBiker),
            showBack: true,
            onBack: () => pop(context),
            primaryAction: KButton(
              label: translate(AppStrings.resetPassword),
              loading:
                  state is BikerResetPasswordLoading ||
                  state is BikerUpdatePasswordLoading,
              onPressed: _updatePassword,
            ),
            children: <Widget>[
              AutofillGroup(
                child: Column(
                  children: <Widget>[
                    if (widget.profile) ...<Widget>[
                      KTextField(
                        label: translate(AppStrings.oldPassword),
                        controller: oldPasswordController,
                        obscure: true,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.password],
                        validator: validatorPassword,
                      ),
                      const SizedBox(height: KSpace.m),
                    ],
                    KTextField(
                      label: translate(AppStrings.newPassword),
                      controller: passwordController,
                      obscure: true,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.newPassword],
                      validator: validatorPassword,
                    ),
                    const SizedBox(height: KSpace.m),
                    KTextField(
                      label: translate(AppStrings.reEnterNewPassword),
                      controller: rePasswordController,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[AutofillHints.newPassword],
                      validator: (String? value) =>
                          validatorRePassword(passwordController.text, value),
                      onSubmitted: (_) => _updatePassword(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
