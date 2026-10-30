import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/core/resources/values_manager.dart';
import 'package:thewasher/modules/notifications/blocs/notifications/notifications_bloc.dart';
import 'package:thewasher/modules/notifications/data/models/notifaction_model.dart';
import 'package:thewasher/modules/notifications/screens/methods/select_notification_type.dart';
import 'package:thewasher/modules/notifications/widgets/notification_card.dart';
import 'package:thewasher/modules/notifications/widgets/loading_and_listen_when_get_order.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';

class NotificationsList extends StatefulWidget {
  const NotificationsList({
    super.key,
  });

  @override
  State<NotificationsList> createState() => _NotificationsListState();
}

class _NotificationsListState extends State<NotificationsList> {
  late NotificationsBloc notificationsBloc;
  late Notifications notification;
  late GeneralSingleton generalSingleton;
  @override
  void initState() {
    super.initState();
    notificationsBloc = sl<NotificationsBloc>();
    notification = Notifications();
    generalSingleton = GeneralSingleton();
  }

  void performTapAction(int index) {
    notification = notificationsBloc.notifacations[index];
    if (notification.isRead!) {
      selectActionNotificationType(notification, context);
    } else {
      selectActionNotificationType(notification, context);
      notificationsBloc.add(
        MakeNotificationRead(id: notification.sId!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationsBloc, NotificationsState>(
      builder: (context, state) {
        return Stack(
          children: <Widget>[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.p18.w,
                vertical: AppPadding.p12.h,
              ),
              itemCount: notificationsBloc.notifacations.length,
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Color(0xFFCCCCCC),
                );
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (notificationsBloc.notifacations[index].type == AppConstants.completedOrder) {
                      setState(() {
                        generalSingleton.completedOrder = true;
                      });
                    } else {
                      setState(() {
                       generalSingleton.completedOrder = false;
                      });
                    }
                    performTapAction(index);
                  },
                  behavior: HitTestBehavior.opaque,
                  child: NotificationCard(
                    notification: notificationsBloc.notifacations[index],
                  ),
                );
              },
            ),
            if ( !generalSingleton.completedOrder) LoadingAndListenWhenGetOrder()
          ],
        );
      },
    );
  }
}
