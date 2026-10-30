import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/about_us/bloc/about_us_bloc.dart';
import 'package:thewasher/shared/components/app_bar.dart';
import 'package:thewasher/shared/components/empty_state_widget.dart';
import 'package:thewasher/shared/components/loading.dart';
import 'package:thewasher/shared/components/snack_bar.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(AppSize.s375, AppSize.s60.h),
          child: AppBarWhiteShared(
            titleText: translate(AppStrings.termsAndConditions),
          ),
        ),
        body: BlocProvider<AboutUsBloc>(
          create: (context) => AboutUsBloc()..add(GetTermsAndCondition()),
          child: BlocConsumer<AboutUsBloc, AboutUsState>(
              listener: (context, state) {
            if (state.status == AboutUsStateStatus.error) {
              showSnackBar(buildContext: context, message: state.errorMessage!);
            }
          }, builder: (context, state) {
            if (state.status == AboutUsStateStatus.loading) {
              return const Center(
                child: LoadingWidget(),
              );
            }

            if (state.status == AboutUsStateStatus.success) {
              // Check if content is empty or null
              if (state.termsContent == null ||
                  state.termsContent!.trim().isEmpty) {
                return EmptyStateWidget(
                  title: translate(AppStrings.noContent),
                  subtitle:
                      translate(AppStrings.termsAndConditionsEmptyMessage),
                  lottieAsset: 'assets/empty.json',
                  showRetryButton: true,
                  onRetry: () {
                    context.read<AboutUsBloc>().add(GetTermsAndCondition());
                  },
                );
              }
            }

            return _buildTermsAndConditions(state);
          }),
        ));
  }

  Widget _buildTermsAndConditions(AboutUsState state) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SingleChildScrollView(
          child: Text(
            state.termsContent ?? '',
            style: AppStyles.subtextGray14Regular
                .copyWith(color: ColorManager.darkGrey),
          ),
        ),
      );
}
