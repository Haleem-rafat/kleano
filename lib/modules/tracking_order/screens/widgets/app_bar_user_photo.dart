import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/layout/component/circle_image.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/modules/profile/screens/user_profile_screen.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/utilties/navigator.dart';

class AppBarUserPhoto extends StatelessWidget {
  const AppBarUserPhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      systemOverlayStyle: AppStyles.darkStatusBarIconsWithTransparentColorStyle,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        textBaseline: TextBaseline.alphabetic,
        children: [
          GestureDetector(
            onTap: () => pop(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 40.h,
              width: 40.w,
              padding: Localizations.localeOf(context).languageCode == 'en'
                  ? EdgeInsets.only(left: 8.w)
                  : EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorManager.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, .16),
                      blurRadius: 6.r,
                      offset: const Offset(0, 3),
                    )
                  ]),
              child: Icon(
                Icons.arrow_back_ios,
                color: ColorManager.primary,
                size: 24.w,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              pushPage(
                  context,
                  const UserProfileScreen(
                    openAnother: true,
                  ));
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorManager.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: const Color.fromRGBO(0, 0, 0, .16),
                      blurRadius: 6.r,
                      offset: const Offset(0, 3),
                    )
                  ]),
              child: CircleImageShared(
                  imageUrl:
                      sl.call<GetUserProfileBloc>.call().profile.imageLink ??
                          '',
                  radius: 20.r,
                  name: sl.call<GetUserProfileBloc>.call().profile.userName!),
            ),
          ),
        ],
      ),
    );
  }
}
