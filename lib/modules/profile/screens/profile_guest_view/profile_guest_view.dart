import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/profile/widgets/profile_guest_widgets/header_profile.dart';
import 'package:thewasher/modules/profile/widgets/profile_guest_widgets/list_guest_screens.dart';

class ProfileGuestViewScreen extends StatefulWidget {
  const ProfileGuestViewScreen({super.key});

  @override
  State<ProfileGuestViewScreen> createState() => _ProfileGuestViewScreenState();
}

class _ProfileGuestViewScreenState extends State<ProfileGuestViewScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const HeaderProfileGuestWidget(),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
            child: const ScreensInGuestProfile()),
      ],
    );
  }
}
