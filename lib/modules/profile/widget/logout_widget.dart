import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/api/shared.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/modules/Auth/bloc/auth/auth_bloc.dart';
import 'package:thewhsherbiker/modules/Auth/screens/log_in_screen.dart';
import 'package:thewhsherbiker/shared/components/loading.dart';
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
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 47.w),
          child: sl<AuthBloc>().logout
              ? LoadingWidget()
              : InkWell(
                  onTap: _logOut,
                  child: Text(
                    translate(AppStrings.logOut),
                    style: AppStyles.title16Regular.copyWith(
                      color: ColorManager.red,
                      decoration: TextDecoration.underline,
                      decorationColor: ColorManager.red,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
