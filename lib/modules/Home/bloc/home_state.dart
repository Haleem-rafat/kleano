part of 'home_bloc.dart';

@immutable
abstract class HomeState {}

class HomeInitial extends HomeState {}

class BikerGetNewOrdersFailed extends HomeState{
  final String error;

  BikerGetNewOrdersFailed({required this.error});
}


class BikerGetOrdersLoading extends HomeState{}
class BikerGetOrdersPaginationLoading extends HomeState {}
class BikerGetOrdersSuccess extends HomeState{
  final List<OrderModel> orderList;
  final int pendingTotalLength;
  BikerGetOrdersSuccess({required this.orderList, required this.pendingTotalLength});
}
class BikerGetOrdersEmpty extends HomeState{}
class BikerGetOrdersFailed extends HomeState{
  final String error;

  BikerGetOrdersFailed({required this.error});
}

class BikerGetOrdersAcceptLoading extends HomeState{}
class BikerGetOrdersPaginationAcceptLoading extends HomeState {}
class BikerGetOrdersAcceptSuccess extends HomeState{}
class BikerGetOrdersAcceptEmpty extends HomeState{}
class BikerGetOrdersAcceptFailed extends HomeState{
  final String error;

  BikerGetOrdersAcceptFailed({required this.error});
}

class BikerGetOrdersCompleteLoading extends HomeState{}
class BikerGetOrdersPaginationCompleteLoading extends HomeState {}
class BikerGetOrdersCompleteSuccess extends HomeState{}
class BikerGetOrdersCompleteEmpty extends HomeState{}
class BikerGetOrdersCompleteFailed extends HomeState{
  final String error;

  BikerGetOrdersCompleteFailed({required this.error});
}

class BikerAcceptOrderLoading extends HomeState{}
class BikerAcceptOrderSuccess extends HomeState{
  final String orderId;
  final bool details;
  BikerAcceptOrderSuccess({required this.orderId, required this.details});
}
class BikerAcceptOrderFailed extends HomeState{
  final String error;

  BikerAcceptOrderFailed({required this.error});
}

class BikerOnTheWayOrderLoading extends HomeState{}
class BikerOnTheWayOrderSuccess extends HomeState{
  final String orderId;

  BikerOnTheWayOrderSuccess({required this.orderId});
}
class BikerOnTheWayOrderFailed extends HomeState{
  final String error;

  BikerOnTheWayOrderFailed({required this.error});
}

class BikerArrivedOrderLoading extends HomeState{}
class BikerArrivedOrderSuccess extends HomeState{
  final String orderId;

  BikerArrivedOrderSuccess({required this.orderId});
}
class BikerArrivedOrderFailed extends HomeState{
  final String error;

  BikerArrivedOrderFailed({required this.error});
}

class BikerOnWashingOrderLoading extends HomeState{}
class BikerOnWashingOrderSuccess extends HomeState{
  final String orderId;

  BikerOnWashingOrderSuccess({required this.orderId});
}
class BikerOnWashingOrderFailed extends HomeState{
  final String error;

  BikerOnWashingOrderFailed({required this.error});
}

class BikerCompleteOrderLoading extends HomeState{}
class BikerCompleteOrderSuccess extends HomeState{
  final String orderId;

  BikerCompleteOrderSuccess({required this.orderId});
}
class BikerCompleteOrderFailed extends HomeState{
  final String error;

  BikerCompleteOrderFailed({required this.error});
}

class BikerCancelOrderLoading extends HomeState{
  final String orderId;

  BikerCancelOrderLoading({required this.orderId});
}
class BikerCancelOrderSuccess extends HomeState{
  final String orderId;

  BikerCancelOrderSuccess({required this.orderId});
}
class BikerCancelOrderFailed extends HomeState{
  final String error;

  BikerCancelOrderFailed({required this.error});
}


class BikerOrderLoading extends HomeState{}
class BikerOrderSuccess extends HomeState{
  final BitmapDescriptor markerBikerLocation;
  final BitmapDescriptor markerUserLocation;

  BikerOrderSuccess({required this.markerBikerLocation , required this.markerUserLocation});
}
class BikerOrderFailed extends HomeState{
  final String error;

  BikerOrderFailed({required this.error});
}


class SocketClosed extends HomeState{}

