part of 'home_bloc.dart';

@immutable
abstract class HomeEvent {}

class BikerGetNewOrders extends HomeEvent {}

class BikerGetOrdersPending extends HomeEvent {}

class BikerGetOrdersPendingPagination extends HomeEvent {}

class BikerGetOrdersAccept extends HomeEvent {}

class BikerGetOrdersAcceptPagination extends HomeEvent {}

class BikerGetOrdersComplete extends HomeEvent {}

class BikerGetOrdersCompletePagination extends HomeEvent {}

class BikerCloseSocket extends HomeEvent {}

class BikerAcceptOrder extends HomeEvent {
  final String orderId;
  final String lat;
  final String lng;
  final String streetName;
  final String subAdministrativeArea;
  final bool details;
  final BuildContext context;
  final int orderIndex;

  BikerAcceptOrder(
      {required this.orderId,
      required this.context,
      required this.orderIndex,
      required this.lat,
      required this.lng,
      required this.streetName,
      required this.subAdministrativeArea,
      required this.details});
}

class BikerOnTheWayOrder extends HomeEvent {
  final String orderId;
  final BuildContext context;
  final int orderIndex;

  BikerOnTheWayOrder(
      {required this.orderId, required this.context, required this.orderIndex});
}

class BikerArrivedOrder extends HomeEvent {
  final String orderId;
  final BuildContext context;
  final int orderIndex;

  BikerArrivedOrder(
      {required this.orderId, required this.context, required this.orderIndex});
}

class BikerOnWashingOrder extends HomeEvent {
  final String orderId;
  final BuildContext context;
  final int orderIndex;
  final String? beforeWashImagePath;

  BikerOnWashingOrder(
      {required this.orderId,
      required this.context,
      required this.orderIndex,
      this.beforeWashImagePath});
}

class BikerCompleteOrder extends HomeEvent {
  final String orderId;
  final BuildContext context;
  final int orderIndex;
  final String? afterWashImagePath;

  BikerCompleteOrder(
      {required this.orderId,
      required this.context,
      required this.orderIndex,
      this.afterWashImagePath});
}

class BikerCancelOrder extends HomeEvent {
  final String orderId;
  final BuildContext context;
  final int orderIndex;

  BikerCancelOrder(
      {required this.orderId,
      required this.context,
      required this.orderIndex});
}

class BikerOrder extends HomeEvent {
  final String orderId;
  final BuildContext context;

  BikerOrder({required this.orderId, required this.context});
}
