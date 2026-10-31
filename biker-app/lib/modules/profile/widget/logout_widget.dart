import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/core/design/components/k_button.dart';
import 'package:thewhsherbiker/core/design/tokens.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Auth/screens/log_in_screen.dart';
import 'package:thewhsherbiker/modules/Home/widget/home_order_parts.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class LogOutWidget extends StatelessWidget {
  const LogOutWidget({super.key});
  Future<void> _logOut() async {
    sl<AuthBloc>().add(BikerLogOut());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      bloc: sl<AuthBloc>(),
      listener: (BuildContext context, AuthState state) {
        if (state is BikerLogOutSuccess) {
          AppShared.setToken('');
          popALlAndPushPage(context, LogInScreen());
        }
      },
      builder: (BuildContext context, AuthState state) {
        return KButton(
          label: tr(context, AppStrings.logOut),
          variant: KButtonVariant.text,
          color: KColors.of(context).error,
          loading: sl<AuthBloc>().logout,
          onPressed: _logOut,
        );
      },
    );
  }
}
