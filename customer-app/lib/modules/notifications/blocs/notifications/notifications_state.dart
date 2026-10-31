part of 'notifications_bloc.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationPerPageLoading extends NotificationsState {}

class NotificationsSuccess extends NotificationsState {
  final List<Notifications> notifications;
  NotificationsSuccess({required this.notifications});
}

class NotificationsFailed extends NotificationsState {
  final ErrorModel? errorModel;
  final String? error;

  NotificationsFailed({
    this.errorModel,
    this.error,
  });
}

class NotificationsConnectionError extends NotificationsState {}

////////////////////////////
class EnableNotificationSuccess extends NotificationsState {}

class ReadNotificationSuccess extends NotificationsState {}

//////////////////////

class PushNotificationsSuccess extends NotificationsState {}

class PushNotificationsFailed extends NotificationsState {
  final String? error;

  PushNotificationsFailed({this.error});
}
