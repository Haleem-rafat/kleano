import 'package:flutter/material.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/modules/notifications/blocs/notifications/notifications_bloc.dart';
import 'package:thewasher/modules/notifications/data/models/notifaction_model.dart';
import 'package:thewasher/modules/notifications/screens/methods/select_notification_type.dart';
import 'package:thewasher/modules/notifications/widgets/notification_card.dart';

/// The lazy list of notifications. A function, not a widget: `SmartRefresher`
/// only keeps a list lazy when the `ScrollView` is its direct child.
ListView buildNotificationsList({
  required BuildContext context,
  required NotificationsBloc notificationsBloc,
  required ValueChanged<bool> onCompletedOrderChanged,
}) {
  void performTapAction(int index) {
    final Notifications notification = notificationsBloc.notifacations[index];
    if (notification.isRead!) {
      selectActionNotificationType(notification, context);
    } else {
      selectActionNotificationType(notification, context);
      notificationsBloc.add(MakeNotificationRead(id: notification.sId!));
    }
  }

  return ListView.separated(
    padding: const EdgeInsets.all(KSpace.xl),
    itemCount: notificationsBloc.notifacations.length,
    separatorBuilder: (BuildContext context, int index) =>
        const SizedBox(height: KSpace.m),
    itemBuilder: (BuildContext context, int index) {
      final Notifications notification = notificationsBloc.notifacations[index];
      return NotificationCard(
        notification: notification,
        onTap: () {
          onCompletedOrderChanged(
            notification.type == AppConstants.completedOrder,
          );
          performTapAction(index);
        },
      );
    },
  );
}
