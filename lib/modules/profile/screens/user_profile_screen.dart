import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/enums/status.dart';
import 'package:thewasher/core/resources/app_sized_box.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/Auth/cubit/auth_cubit.dart';
import 'package:thewasher/modules/Auth/cubit/auth_state.dart';
import 'package:thewasher/modules/on_boarding/choose_register.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/screens/profile_guest_view/profile_guest_view.dart';
import 'package:thewasher/modules/profile/widgets/header_profile.dart';
import 'package:thewasher/modules/profile/widgets/list_of_screens_in_profile.dart';
import 'package:thewasher/modules/profile/widgets/my_points.dart';
import 'package:thewasher/modules/profile/widgets/my_wallet.dart';
import 'package:thewasher/modules/profile/widgets/profile_shimmering_screen.dart';
import 'package:thewasher/shared/components/connection_error/connection_error_screen.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/utilties/navigator.dart';

class UserProfileScreen extends StatefulWidget {
  final bool? openAnother;
  const UserProfileScreen({
    super.key,
    this.openAnother = false,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late GetUserProfileBloc getUserProfileBloc;
  late AuthCubit authCubit;

  @override
  void initState() {
    super.initState();
    if (AppShared.token.isNotEmpty) {
      getUserProfileBloc = BlocProvider.of<GetUserProfileBloc>(context);
      getUserProfileBloc.add(GetUserProfileEvent());
    }
    authCubit = BlocProvider.of<AuthCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.logoutStatus == RequestStatus.loaded) {
          // Navigate to choose register screen on successful logout
          popALlAndPushPage(context, ChooseRegisterView());
        } else if (state.logoutStatus == RequestStatus.failure) {
          // Show error message on failure
          showSnackBar(
            buildContext: context,
            message: state.logoutErrorMessage ??
                'Failed to logout. Please try again.',
            icon: Icons.error_outline,
            backgroundColor: ColorManager.red,
          );
        }
      },
      builder: (context, authState) {
        final isLoggingOut = authState.logoutStatus == RequestStatus.loading;

        return Scaffold(
          backgroundColor: ColorManager.white,
          body: isGuestUser
              ? const ProfileGuestViewScreen()
              : AnnotatedRegion(
                  value: AppStyles.lightStatusBarIconsWithTransparentColorStyle,
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        if (AppShared.token.isNotEmpty)
                          BlocBuilder<GetUserProfileBloc, GetUserProfileState>(
                            builder: (BuildContext context,
                                GetUserProfileState state) {
                              if (state is GetUserProfileLoading) {
                                return const ProfileShimmiring();
                              } else if (state
                                  is GetUserProfileConnectionError) {
                                return Center(
                                  child: ConnectionErrorSharedScreen(
                                    onPressed: () {
                                      getUserProfileBloc
                                          .add(GetUserProfileEvent());
                                    },
                                  ),
                                );
                              } else if (state is GetUserProfileSuccess) {
                                return Column(
                                  children: <Widget>[
                                    HeaderProfileWidget(
                                      userProfile: state.userProfile.data!,
                                      comeAnotherScreen: widget.openAnother,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: AppPadding.p24.w),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              MyPointsWidget(
                                                  numberOfPoints: state
                                                      .userProfile.data!.points
                                                      .toString()),
                                              AppPadding.p16.pw,
                                              MyWalletWidget(
                                                  money: state.userProfile.data!
                                                          .walletBalance ??
                                                      0.0)
                                            ],
                                          ),
                                          ScreensInProfile(
                                              profile: state.userProfile.data!),
                                          GestureDetector(
                                            onTap: isLoggingOut
                                                ? null
                                                : () => authCubit.logout(),
                                            child: Opacity(
                                              opacity: isLoggingOut ? 0.6 : 1.0,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: AppPadding.p20.w,
                                                  vertical: AppPadding.p16.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: ColorManager.red
                                                      .withValues(alpha: 0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.r),
                                                  border: Border.all(
                                                    color: ColorManager.red
                                                        .withValues(alpha: 0.2),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(8.r),
                                                      decoration: BoxDecoration(
                                                        color: ColorManager.red
                                                            .withValues(alpha: 0.15),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.r),
                                                      ),
                                                      child: isLoggingOut
                                                          ? SizedBox(
                                                              width: 20.r,
                                                              height: 20.r,
                                                              child:
                                                                  CircularProgressIndicator(
                                                                color:
                                                                    ColorManager
                                                                        .red,
                                                                strokeWidth: 2,
                                                              ),
                                                            )
                                                          : Icon(
                                                              Icons
                                                                  .logout_rounded,
                                                              color:
                                                                  ColorManager
                                                                      .red,
                                                              size: 20.r,
                                                            ),
                                                    ),
                                                    SizedBox(width: 16.w),
                                                    Text(
                                                      translate(
                                                          AppStrings.logout),
                                                      style: AppStyles
                                                          .title16Bold
                                                          .copyWith(
                                                        color: ColorManager.red,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 15.sp,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          AppSize.s100.ph
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox();
                            },
                          )
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
