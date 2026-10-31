part of 'notification_bloc.dart';

@immutable
abstract class NotificationEvent {}

class GetBikerNotification extends NotificationEvent {}

class GetBikerNotificationPagination extends NotificationEvent {}

class MakePushNotification extends NotificationEvent {}

class MakeNotificationIsRead extends NotificationEvent {
  final String notificationId;
  final int notificationIndex;
  final BuildContext context;

  MakeNotificationIsRead(
      {required this.notificationId,
      required this.notificationIndex,
      required this.context});
}
