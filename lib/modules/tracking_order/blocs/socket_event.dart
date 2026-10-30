part of 'socket_bloc.dart';

class SocketEvent {}
class OpenSocketIo extends SocketEvent{}
class SocketConnectedEvent extends SocketEvent {}

class NotifyBikerAcceptedOrder extends SocketEvent {
  final AcceptedOrderByBikerModel? orderAcceptedModel;
  NotifyBikerAcceptedOrder({required this.orderAcceptedModel});
}

class NotifySocketIoListenersOfEvent extends SocketEvent {
  final AcceptedOrderByBikerModel? orderAcceptedModel;
  final BaseModelSocketStatus? baseModelSocketStatus;
  NotifySocketIoListenersOfEvent({
    this.orderAcceptedModel,
    this.baseModelSocketStatus,
  });
}

class NotifyEventBikerOnTheWay extends SocketEvent {
  final CameraPosition? cameraPosition;
  NotifyEventBikerOnTheWay({required this.cameraPosition});
}
class RatingYourWash extends SocketEvent {
  final String? orderId;
  RatingYourWash({required this.orderId});
}
