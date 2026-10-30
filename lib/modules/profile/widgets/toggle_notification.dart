import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/resources/app_styles.dart';
import 'package:thewasher/core/resources/color_manager.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/notifications/blocs/notifications/notifications_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';
import 'package:thewasher/shared/components/toggle_shared.dart';

class ToggleNotification extends StatefulWidget {
  const ToggleNotification({super.key});

  @override
  State<ToggleNotification> createState() => _ToggleNotificationState();
}

class _ToggleNotificationState extends State<ToggleNotification> {
  late bool toggleSelected;
  @override
  void initState() {
    super.initState();
    toggleSelected = isAllowedNotifications!;
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context).languageCode;
    return Container(
      height: 56.h,
      width: 328.w,
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: ColorManager.black.withValues(alpha: .05),
            blurRadius: 3.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            translate(AppStrings.notifications),
            style: AppStyles.title16Regular.copyWith(
              color: ColorManager.black,
            ),
          ),
          ToggleShared(
            toggleSelected: toggleSelected,
            onChanged: (bool? value) {
              setState(() {
                context.read<NotificationsBloc>().add(
                    EnableShowNotification(enabled: value! ? 'on' : 'off'));
                toggleSelected = value;
              });
            },
          )
        ],
      ),
    );
  }
}
