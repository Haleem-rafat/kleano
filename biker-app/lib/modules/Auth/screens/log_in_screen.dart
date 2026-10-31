// import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thewhsherbiker/core/design/components/k_auth_scaffold.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/components/k_text_field.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Auth/screens/phone_number.dart';
import 'package:thewhsherbiker/modules/Home/screens/biker_shell.dart';
import 'package:thewhsherbiker/modules/notification/helpers/notification_helper.dart';
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
      sl<AuthBloc>().add(
        BikerLogin(
          context: context,
          userName: nameController.text,
          passWord: passWordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: sl<AuthBloc>(),
      listener: (BuildContext context, AuthState state) {
        if (state is BikerLoginFailed) {
          showSnackBar(buildContext: context, message: state.error);
        } else if (state is BikerLoginSuccess) {
          sl<AuthBloc>().getUserLocation().whenComplete(() {
            if (!context.mounted) return;
            popALlAndPushPage(context, BikerShell(initialIndex: 0));
          });
        }
      },
      builder: (BuildContext context, AuthState state) {
        return Form(
          key: _loginFormKey,
          child: KAuthScaffold(
            title: translate(AppStrings.welcomeBack),
            subtitle: translate(AppStrings.bikerLoginSubtitle),
            badge: translate(AppStrings.badgeBiker),
            primaryAction: KButton(
              label: translate(AppStrings.login),
              loading: state is BikerLoginLoading,
              onPressed: _login,
            ),
            secondaryAction: KButton(
              label: translate(AppStrings.forgetPassword),
              variant: KButtonVariant.text,
              onPressed: () => pushPage(context, PhoneNumberScreen()),
            ),
            children: <Widget>[
              AutofillGroup(
                child: Column(
                  children: <Widget>[
                    KTextField(
                      label: translate(AppStrings.username),
                      controller: nameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.username],
                      validator: validatorName,
                    ),
                    const SizedBox(height: KSpace.m),
                    KTextField(
                      label: translate(AppStrings.password),
                      controller: passWordController,
                      obscure: true,
                      textInputAction: TextInputAction.done,
                      autofillHints: const <String>[AutofillHints.password],
                      validator: validatorPassword,
                      onSubmitted: (_) => _login(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KSpace.s),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(translate(AppStrings.rememberPassword)),
                value: isChecked,
                onChanged: (bool value) => setState(() => isChecked = value),
              ),
            ],
          ),
        );
      },
    );
  }
}
