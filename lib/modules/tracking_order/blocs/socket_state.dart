part of 'socket_bloc.dart';

class SocketState {}

class SocketInitial extends SocketState {}

class SocketConnectingSuccess extends SocketState {}

class SocketFailed extends SocketState {
  final String error;
  SocketFailed({required this.error});
}

class BikerAcceptedSuccess extends SocketState {
  final AcceptedOrderByBikerModel? acceptedOrderByBikerModel;
  BikerAcceptedSuccess({this.acceptedOrderByBikerModel});
}

class SocketIoReceivedAnUpdateState extends SocketState {
  final BaseModelSocketStatus? baseModelSocketStatus;
  final AcceptedOrderByBikerModel? acceptedOrderByBikerModel;

  SocketIoReceivedAnUpdateState({
    this.baseModelSocketStatus,
    this.acceptedOrderByBikerModel,
  });
}

class ReceivedAnUpdateBikerOnTheWayState extends SocketState {
  final CameraPosition? cameraPosition;

  ReceivedAnUpdateBikerOnTheWayState({this.cameraPosition});
}

class ReceivedOrderCompletedSuccess extends SocketState {
  final String orderId;
  ReceivedOrderCompletedSuccess({required this.orderId});
}
