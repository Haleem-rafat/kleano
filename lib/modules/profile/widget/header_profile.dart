import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/components/circle_image.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';
import 'package:thewhsherbiker/core/resources/strings_manager.dart';
import 'package:thewhsherbiker/core/resources/values_manager.dart';
import 'package:thewhsherbiker/modules/profile/bloc/profile_bloc.dart';
import 'package:thewhsherbiker/modules/profile/data/model/profile_model.dart';
import 'package:thewhsherbiker/utilties/navigator.dart';

class HeaderProfileWidget extends StatelessWidget {
  const HeaderProfileWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ProfileModel profile = context.read<ProfileBloc>().profile;
    return Container(
        height: 130.h,
        width: 375.w,
        color: Colors.transparent,
        child: Stack(
          children: <Widget>[
            Container(
              height: 90.h,
              width: 375.w,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(12),
                ),
                boxShadow: <BoxShadow>[BoxShadow(color: ColorManager.black.withOpacity(.05), blurRadius: 3.r, offset: const Offset(0, 6))],
                color: ColorManager.primary,
              ),
            ),
            Positioned(
              top: 50.h,
              left: Localizations.localeOf(context).languageCode == 'en' ? 20.w : null,
              right: Localizations.localeOf(context).languageCode == 'ar' ? 20.w : null,
              child: GestureDetector(
                onTap: () => pop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: ColorManager.white,
                  size: AppSize.s24,
                ),
              ),
            ),
            Positioned(
              bottom: 5.h,
              left: 150.w,
              right: 150.w,
              child: SizedBox(
                height: 73.25.h,
                width: 73.25.w,
                child: CircleImageShared(
                  imageUrl: profile.imageLink ?? '',
                  radius: 37.r,
                  name: profile.userName ?? AppStrings.noName,
                ),
              ),
            ),
          ],
        ));
  }
}
