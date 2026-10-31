import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:thewasher/core/design/components/k_list_row.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/notifications/blocs/notifications/notifications_bloc.dart';
import 'package:thewasher/modules/profile/blocs/get_user_profile/get_user_profile_bloc.dart';

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
    toggleSelected = isAllowedNotifications ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context).languageCode;
    return KListRow(
      title: translate(AppStrings.notifications),
      trailing: Switch.adaptive(
        value: toggleSelected,
        onChanged: (bool value) {
          setState(() {
            context.read<NotificationsBloc>().add(
              EnableShowNotification(enabled: value ? 'on' : 'off'),
            );
            toggleSelected = value;
          });
        },
      ),
    );
  }
}
