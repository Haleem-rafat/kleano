import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewhsherbiker/core/components/circle_image.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/assets_manager.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/Auth/screens/update_password.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';
import 'package:thewhsherbiker/modules/profile/screens/update_biker_data.dart';
import 'package:thewhsherbiker/modules/profile/widget/profile/edit_account_container.dart';
import 'package:thewhsherbiker/shared/components/app_bar.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileBloc profileBloc = context.read<ProfileBloc>();
    final ProfileModel profile = profileBloc.profile;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(AppSize.s375, AppSize.s60.h),
        child: AppBarWhiteShared(
          titleText: translate(AppStrings.account),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 22.h,
              ),
              BlocBuilder<ProfileBloc, ProfileState>(
                bloc: sl<ProfileBloc>(),
                builder: (BuildContext context, ProfileState state) {
                  return GestureDetector(
                    onTap: () {
                      pushPage(context, UpdateBikerData());
                    },
                    child: Center(
                      child: CircleImageShared(
                        imageUrl: profile.imageLink ?? '',
                        radius: 42.r,
                        name: profile.userName ?? AppStrings.noName,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 56.h,
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  pushPage(context, UpdateBikerData());
                },
                child: EditAccountContainer(
                  edit: true,
                  title: translate(AppStrings.username),
                ),
              ),
              SizedBox(
                height: 16.h,
              ),
              BlocBuilder<ProfileBloc, ProfileState>(
                bloc: sl<ProfileBloc>(),
                builder: (BuildContext context, ProfileState state) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      profile.userName!,
                      style: AppStyles.titleGray16Regular,
                    ),
                  );
                },
              ),
              SizedBox(
                height: 16.h,
              ),
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  pushPage(context, UpdatePassword(profile: true));
                },
                child: EditAccountContainer(
                  edit: true,
                  title: translate(AppStrings.password),
                ),
              ),
              SizedBox(
                height: 16.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 40.w,
                ),
                child: Text(
                  "********",
                  style: AppStyles.titleGray16Regular,
                ),
              ),
              SizedBox(
                height: 16.h,
              ),
              EditAccountContainer(
                edit: false,
                title: translate(AppStrings.phoneNumber),
              ),
              SizedBox(
                height: 16.h,
              ),
              if (profile.phone != null)
                buildFormattedPhoneNumber(profile.phone!),
              SizedBox(
                height: 102.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: Text(
                  translate(AppStrings.deleteAccount),
                  style: AppStyles.titleGray16Regular.copyWith(
                    color: ColorManager.red,
                    decoration: TextDecoration.underline,
                    decorationColor: ColorManager.red,
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 80.h,
            right: 150.w,
            child: SvgPicture.asset(
              ImageAssets.cameraLogo,
              height: 24.h,
              width: 24.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildFormattedPhoneNumber(String phoneNumber) {
    String countryCode = phoneNumber.substring(0, 3);
    String restOfNumber = phoneNumber.substring(3);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Text.rich(
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: '($countryCode) ',
                style: AppStyles.titleGray16Regular
                    .copyWith(color: ColorManager.darkGrey),
              ),
              TextSpan(
                text: restOfNumber,
                style: AppStyles.titleGray16Regular,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
