import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:thewasher/layout/services/firebase_cloud_messaging_service.dart';
import 'package:thewasher/modules/notifications/data/models/notifaction_model.dart';
import 'package:thewasher/modules/notifications/data/repo/notifications_repo.dart';
import 'package:thewasher/modules/notifications/data/responses/notifications_response.dart';
import 'package:thewasher/responses/base_response.dart';
part 'notifications_event.dart';
part 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final FirebaseCloudMessagingService firebaseCloudMessagingService =
      FirebaseCloudMessagingService();

  List<Notifications> notifacations = <Notifications>[];
  int pageNumber = 1;
  int pageTotalCount = 0;
  int totalitem = 0;
  NotificationsBloc() : super(NotificationsInitial()) {
    on<FetchAllNotifications>(
        (FetchAllNotifications event, Emitter<NotificationsState> emit) async {
      try {
        if (event.isRefresh!) {
          emit(NotificationsLoading());
        }
        pageNumber = 1;
        pageTotalCount = 0;
        final NotificationsResponse response =
            await NotificationsRepo.fetchNotifications(
          pageNumber: pageNumber,
        );
        if (response.success) {
          pageNumber++;
          pageTotalCount = response.results!.totalPages!;
          totalitem = response.results!.totalItems!;
          notifacations = <Notifications>[];
          notifacations = response.results!.data!;
          emit(NotificationsSuccess(notifications: notifacations));
        } else {
          emit(NotificationsFailed(error: response.message));
        }
      } on DioException catch (e) {
        if (e.message!.contains('SocketException')) {
          emit(NotificationsConnectionError());
        } else {
          // emit(NotificationsFailed(errorModel: e.message));
        }
      } catch (e) {
        emit(NotificationsFailed(error: e.toString()));
      }
    });

    on<ViewNotificationsPerPage>((ViewNotificationsPerPage event,
        Emitter<NotificationsState> emit) async {
      try {
        emit(NotificationPerPageLoading());
        if (pageNumber <= pageTotalCount) {
          final NotificationsResponse response =
              await NotificationsRepo.fetchNotifications(
            pageNumber: pageNumber,
          );
          if (response.success) {
            pageNumber++;
            pageTotalCount = response.results!.totalPages!;
            notifacations.addAll(response.results!.data!);
            emit(NotificationsSuccess(notifications: notifacations));
          } else {
            emit(NotificationsFailed(error: response.message.toString()));
          }
        } else {
          emit(NotificationsSuccess(notifications: <Notifications>[]));
        }
      } on DioException catch (e) {
        if (e.message!.contains('SocketException')) {
          emit(NotificationsConnectionError());
        } else {
          emit(NotificationsFailed(error: e.message));
        }
      } catch (e) {
        if (e is SocketException) {
          emit(NotificationsConnectionError());
        } else {
          emit(NotificationsFailed(error: e.toString()));
        }
      }
    });

    on<EnableShowNotification>(
        (EnableShowNotification event, Emitter<NotificationsState> emit) async {
      bool response =
          await NotificationsRepo.enableNotification(permission: event.enabled);
          
      if (response) {
        emit(EnableNotificationSuccess());
      }
    });

    on<MakeNotificationRead>(
        (MakeNotificationRead event, Emitter<NotificationsState> emit) async {
      bool response = await NotificationsRepo.readNotification(id: event.id);
      if (response) {
        emit(ReadNotificationSuccess());
      }
    });

    on<PushNotificationsEvent>(
        (PushNotificationsEvent event, Emitter<NotificationsState> emit) async {
      try {
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

          if (fcmToken != null) {
            const bool fcmTokenAdded = true;

            if (fcmTokenAdded) {
              emit(PushNotificationsSuccess());
              // ignore: dead_code
            } else {
              emit(PushNotificationsFailed(
                  error: 'Failed to send FCM token to the server'));
            }
          } else {
            emit(PushNotificationsFailed(error: 'Failed to get FCM token'));
          }
        } else {
          emit(PushNotificationsFailed(
              error: 'Push notifications permissions were denied'));
        }
      } catch (e) {
        emit(PushNotificationsFailed(error: e.toString()));
      }
    });
  }
}
