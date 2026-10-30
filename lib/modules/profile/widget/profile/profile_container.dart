import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewhsherbiker/core/resources/app_styles.dart';
import 'package:thewhsherbiker/core/resources/color_manager.dart';

class ProfileContainer extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const ProfileContainer({Key? key, required this.title, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: <BoxShadow>[BoxShadow(color: ColorManager.black.withOpacity(.08), blurRadius: 6.r, offset: const Offset(0, 3))],
        ),
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        margin:  EdgeInsets.symmetric(horizontal: 24.w),
        child: ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: AppStyles.title16Regular.copyWith(color: ColorManager.darkGrey),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 15,
          ),
        ));
  }
}
