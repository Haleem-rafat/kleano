import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as socket;
import 'package:thewasher/api/app_config.dart';
import 'package:thewasher/api/shared.dart';
import 'package:thewasher/core/resources/constant_manager.dart';
import 'package:thewasher/modules/my_booking/blocs/my_booking/my_booking_bloc.dart';
import 'package:thewasher/modules/tracking_order/data/models/accepted_biker_model.dart';
import 'package:thewasher/modules/tracking_order/data/models/base_model_socket.dart';
import 'package:thewasher/modules/tracking_order/services/wash_live_status.dart';
import 'package:thewasher/shared/services/service_locator.dart';
import 'package:thewasher/shared/singleton.dart';
import 'package:thewasher/utilties/app_date_formatter.dart';

part 'socket_event.dart';
part 'socket_state.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  static socket.Socket? socketIo;
  final String url = AppConfig.socketUrl;
  BaseModelSocketStatus baseModelSocketStatus = BaseModelSocketStatus();
  GeneralSingleton generalSingleton = GeneralSingleton();

  SocketBloc() : super(SocketInitial()) {
    on<OpenSocketIo>((OpenSocketIo event, Emitter<SocketState> emit) async {
      try {
        socketIo = socket.io(
          url,
          socket.OptionBuilder()
              .setTransports(['websocket'])
              .disableAutoConnect()
              .setExtraHeaders({"authorization": "Bearer ${AppShared.token}"})
              .build(),
        );
        socketIo!.connect();
        socketIo!.onConnect((_) {
          debugPrint('Connection established ${socketIo!.connected}');
        });
        socketIo!.onDisconnect((_) => debugPrint('Connection Disconnection'));
        socketIo!.onConnectError((err) => debugPrint("asdasdsa $err"));
        socketIo!.onError((err) => debugPrint("eeeeee $err"));

        socketIo!.onAny((String event, dynamic data) {
          WashLiveStatus.instance.onSocketEvent(event, data);
          if (event == AppConstants.orderAccepted) {
            if (generalSingleton.orderId == data['_id']) {
              add(
                NotifyBikerAcceptedOrder(
                  orderAcceptedModel: AcceptedOrderByBikerModel.fromJson(data),
                ),
              );
            }
          } else if (event == AppConstants.orderOnTheWay) {
            if (generalSingleton.orderId == data['_id']) {
              baseModelSocketStatus = BaseModelSocketStatus.fromJson(data);
              add(
                NotifySocketIoListenersOfEvent(
                  baseModelSocketStatus: baseModelSocketStatus,
                ),
              );
              generalSingleton.timeOnTheWay =
                  AppDateFormatter.dateToStringHHMMA(
                    DateTime.parse(baseModelSocketStatus.time!).toLocal(),
                  );
            }
          } else if (event == AppConstants.bikerMove) {
            CameraPosition cameraPosition = CameraPosition(
              target: LatLng(data['latitude'], data['longitude']),
              zoom: 14,
            );
            add(NotifyEventBikerOnTheWay(cameraPosition: cameraPosition));
          } else if (event == AppConstants.orderArrived) {
            if (generalSingleton.orderId == data['_id']) {
              baseModelSocketStatus = BaseModelSocketStatus.fromJson(data);
              add(
                NotifySocketIoListenersOfEvent(
                  baseModelSocketStatus: baseModelSocketStatus,
                ),
              );
              generalSingleton.timeArrived = baseModelSocketStatus.duration!
                  .toString();
            }
          } else if (event == AppConstants.orderOnWashing) {
            if (generalSingleton.orderId == data['_id']) {
              baseModelSocketStatus = BaseModelSocketStatus.fromJson(data);
              add(
                NotifySocketIoListenersOfEvent(
                  baseModelSocketStatus: baseModelSocketStatus,
                ),
              );
              generalSingleton.timeWashing = AppDateFormatter.dateToStringHHMMA(
                DateTime.parse(baseModelSocketStatus.time!).toLocal(),
              );
            }
          } else if (event == AppConstants.orderCompleted) {
            if (generalSingleton.orderId == data['_id']) {
              baseModelSocketStatus = BaseModelSocketStatus.fromJson(data);
              add(
                NotifySocketIoListenersOfEvent(
                  baseModelSocketStatus: baseModelSocketStatus,
                ),
              );
              generalSingleton.timeComplete =
                  AppDateFormatter.dateToStringHHMMA(
                    DateTime.parse(baseModelSocketStatus.time!).toLocal(),
                  );
              sl.call<MyBookingBloc>.call().add(
                FetchMyBookingActive(isRefresh: false),
              );
              add(RatingYourWash(orderId: data['_id']));
            }
          }
        });
      } catch (e) {
        emit(SocketFailed(error: e.toString()));
      }
    });
    on<NotifyBikerAcceptedOrder>((
      NotifyBikerAcceptedOrder event,
      Emitter<SocketState> emit,
    ) {
      emit(
        BikerAcceptedSuccess(
          acceptedOrderByBikerModel: event.orderAcceptedModel,
        ),
      );
    });
    on<NotifySocketIoListenersOfEvent>((
      NotifySocketIoListenersOfEvent event,
      Emitter<SocketState> emit,
    ) {
      emit(
        SocketIoReceivedAnUpdateState(
          baseModelSocketStatus: event.baseModelSocketStatus,
          acceptedOrderByBikerModel: event.orderAcceptedModel,
        ),
      );
    });
    on<NotifyEventBikerOnTheWay>((
      NotifyEventBikerOnTheWay event,
      Emitter<SocketState> emit,
    ) {
      emit(
        ReceivedAnUpdateBikerOnTheWayState(
          cameraPosition: event.cameraPosition,
        ),
      );
    });

    on<RatingYourWash>((RatingYourWash event, Emitter<SocketState> emit) {
      emit(ReceivedOrderCompletedSuccess(orderId: event.orderId!));
    });
  }
}
