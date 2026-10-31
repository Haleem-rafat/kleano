part of 'notification_bloc.dart';

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class BikerNotificationLoading extends NotificationState {}

class BikerNotificationPaginationLoading extends NotificationState {}

class BikerNotificationSuccess extends NotificationState {}

class BikerNotificationEmpty extends NotificationState {}

class BikerNotificationFailed extends NotificationState {
  final String error;

  BikerNotificationFailed({required this.error});
}

class MakePushNotificationLoading extends NotificationState {}

class MakePushNotificationSuccess extends NotificationState {}

class MakePushNotificationFailed extends NotificationState {
  final String error;

  MakePushNotificationFailed({required this.error});
}

class MakeNotificationIsReadLoading extends NotificationState {}

class MakeNotificationIsReadSuccess extends NotificationState {}

class MakeNotificationIsReadFailed extends NotificationState {
  final String error;

  MakeNotificationIsReadFailed({required this.error});
}
