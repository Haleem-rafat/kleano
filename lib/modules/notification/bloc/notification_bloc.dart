import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thewhsherbiker/modules/Home/bloc/home_bloc.dart';
import 'package:thewhsherbiker/modules/notification/data/model/notification_model.dart';
import 'package:thewhsherbiker/modules/notification/data/repo/notification_repo.dart';
import 'package:thewhsherbiker/modules/notification/widget/firebase_notification.dart';
import 'package:thewhsherbiker/responses/generic_response.dart';
import 'package:thewhsherbiker/shared/services/service_locator.dart';

part 'notification_event.dart';
part 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  int notificationPageNumber = 1;
  int notificationTotalPage = 0;
  int notificationTotalLength = 0;
  int totalUnRead = 0;

  List<NotificationModel> notificationList = <NotificationModel>[];
  final FirebaseCloudMessagingService firebaseCloudMessagingService =
      FirebaseCloudMessagingService();
  NotificationBloc() : super(NotificationInitial()) {
    on<GetBikerNotification>(
        (GetBikerNotification event, Emitter<NotificationState> emit) async {
      try {
        debugPrint("Biker Get Notification");
        emit(BikerNotificationLoading());
        notificationPageNumber = 1;
        notificationTotalPage = 0;
        totalUnRead = 0;
        final GenericResponse<NotificationModel> response =
            await NotificationRepo.getNotification(notificationPageNumber);
        if (response.success) {
          notificationPageNumber++;
          notificationTotalPage = response.totalPages;
          notificationTotalLength = response.totalItems;
          totalUnRead = response.totalUnRead;
          notificationList = <NotificationModel>[];
          notificationList = response.results!;
          if (notificationList.isEmpty) {
            emit(BikerNotificationEmpty());
          } else {
            emit(BikerNotificationSuccess());
          }
        } else {
          emit(BikerNotificationFailed(error: response.error!.first.message));
        }
      } catch (e) {
        emit(BikerNotificationFailed(error: e.toString()));
      }
    });

    on<GetBikerNotificationPagination>((GetBikerNotificationPagination event,
        Emitter<NotificationState> emit) async {
      try {
        debugPrint("Biker Get Notification Pagination");
        emit(BikerNotificationPaginationLoading());
        if (notificationPageNumber <= notificationTotalPage) {
          final GenericResponse<NotificationModel> response =
              await NotificationRepo.getNotification(
            notificationPageNumber,
          );
          if (response.success) {
            notificationPageNumber++;
            notificationTotalLength = response.totalItems;
            notificationList.addAll(response.results!);
            emit(BikerNotificationSuccess());
          } else {
            emit(BikerNotificationFailed(error: response.error!.first.message));
          }
        } else {
          emit(BikerNotificationSuccess());
        }
      } catch (e) {
        emit(BikerNotificationFailed(error: e.toString()));
      }
    });

    on<MakePushNotification>(
        (MakePushNotification event, Emitter<NotificationState> emit) async {
      try {
        debugPrint("Send now Notification ...");
        emit(MakePushNotificationLoading());

        final NotificationSettings notificationSettings =
            await firebaseCloudMessagingService.requestPermission();

        if (notificationSettings.authorizationStatus !=
            AuthorizationStatus.denied) {
          const AndroidNotificationChannel channel = AndroidNotificationChannel(
            'high_importance_channel', // id
            'High Importance Notifications', // title
            description:
                'This channel is used for important notifications.', // description
            importance: Importance.max,
          );

          final FlutterLocalNotificationsPlugin
              flutterLocalNotificationsPlugin =
              FlutterLocalNotificationsPlugin();

          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.createNotificationChannel(channel);
          await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              );

          final String? fcmToken =
              await firebaseCloudMessagingService.getFcmToken();
          debugPrint('FCM Token: $fcmToken');

          if (fcmToken != null) {
            //final bool fcmTokenAdded = await NotificationsRepository.addFCMToken(fcmToken: fcmToken);
            final bool fcmTokenAdded = true;

            if (fcmTokenAdded) {
              emit(MakePushNotificationSuccess());
              // ignore: dead_code
            } else {
              emit(MakePushNotificationFailed(
                  error: 'Failed to send FCM token to the server'));
            }
          } else {
            emit(MakePushNotificationFailed(error: 'Failed to get FCM token'));
          }
        } else {
          emit(MakePushNotificationFailed(
              error: 'Push notifications permissions were denied'));
        }
      } catch (e) {
        emit(MakePushNotificationFailed(error: e.toString()));
      }
    });

    on<MakeNotificationIsRead>(
        (MakeNotificationIsRead event, Emitter<NotificationState> emit) async {
      try {
        debugPrint("Make Notification IsRead ... ");
        emit(MakeNotificationIsReadLoading());
        final bool response = await NotificationRepo.makeNotificationIsRead(
          event.notificationId,
        );
        if (response) {
          notificationList[event.notificationIndex].isRead = true;
          totalUnRead--;
          if (event.context.mounted) {
            sl<HomeBloc>().add(BikerOrder(
            orderId: notificationList[event.notificationIndex].clickableItem!,
            context: event.context,
          ));
          }
          emit(MakeNotificationIsReadSuccess());
        } else {
          emit(MakeNotificationIsReadFailed(error: "Error"));
        }
      } catch (e) {
        emit(MakeNotificationIsReadFailed(error: e.toString()));
      }
    });
  }
}
