part of 'notifications_bloc.dart';

abstract class NotificationsEvent {}

class PushNotificationsEvent extends NotificationsEvent{}

class FetchAllNotifications extends NotificationsEvent {
  final bool? isRefresh;

  FetchAllNotifications({
    this.isRefresh = true,
  });
}

class ViewNotificationsPerPage extends NotificationsEvent {}

class EnableShowNotification extends NotificationsEvent {
  final String enabled;

  EnableShowNotification({required this.enabled});
}
class MakeNotificationRead extends NotificationsEvent {
  final String id;

  MakeNotificationRead({required this.id});
}